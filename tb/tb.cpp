// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Verilator testbench for SweRVolf
// Comments:
//
//********************************************************************************

#include <stdint.h>
#include <signal.h>

#include <jtagServer.h>

#include "verilated_vcd_c.h"
#include "Vswervolf_core_tb.h"

#include "vidbo.h"

using namespace std;

static bool done;

const int JTAG_VPI_SERVER_PORT = 5555;
const int JTAG_VPI_USE_ONLY_LOOPBACK = true;

vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

double sc_time_stamp () {       // Called by $time in Verilog
  return main_time;           // converts to double, to match
  // what SystemC does
}

void INThandler(int signal)
{
	printf("\nCaught ctrl-c\n");
	done = true;
}

typedef struct {
  uint8_t state;
  char ch;
  uint32_t baud_t;
  vluint64_t last_update;
} uart_context_t;

void uart_init(uart_context_t *context, uint32_t baud_rate) {
  context->baud_t = 1000*1000*1000/baud_rate;
  context->state = 0;
}

int do_uart(uart_context_t *context, bool rx) {
  if (context->state == 0) {
    if (rx)
      context->state++;
  }
  else if (context->state == 1) {
    if (!rx) {
      context->last_update = main_time + context->baud_t/2;
      context->state++;
    }
  }
  else if(context->state == 2) {
    if (main_time > context->last_update) {
      context->last_update += context->baud_t;
      context->ch = 0;
      context->state++;
    }
  }
  else if (context->state < 11) {
    if (main_time > context->last_update) {
      context->last_update += context->baud_t;
      context->ch |= rx << (context->state-3);
      context->state++;
    }
  }
  else {
    if (main_time > context->last_update) {
      context->last_update += context->baud_t;
      context->state=1;
      return 1;
    }
  }
  return 0;
}

int main(int argc, char **argv, char **env)
{
  Verilated::commandArgs(argc, argv);
  bool gpio0 = false;
  Vswervolf_core_tb* top = new Vswervolf_core_tb;

  VerilatedVcdC * tfp = 0;
  const char *vcd = Verilated::commandArgsPlusMatch("vcd=");
  if (vcd[0]) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("trace.vcd");
  }

  const char *arg_jtag = Verilated::commandArgsPlusMatch("jtag_vpi_enable=");
  VerilatorJtagServer* jtag = NULL;
  if (arg_jtag[0]) {
    jtag = new VerilatorJtagServer(10); /* Jtag clock is 10 period */
    if (jtag->init_jtag_server(JTAG_VPI_SERVER_PORT, JTAG_VPI_USE_ONLY_LOOPBACK) 
		!= VerilatorJtagServer::SUCCESS) {
      printf("Could not initialize jtag_vpi server. Ending simulation.\n");
      exit(1);
    }    
  }

  uart_context_t uart_context;
  int baud_rate = 115200;
  uart_init(&uart_context, baud_rate);
  vluint64_t timeout = 0;
  const char *arg_timeout = Verilated::commandArgsPlusMatch("timeout=");
  if (arg_timeout[0])
    timeout = atoi(arg_timeout+9);

  vidbo_context_t vidbo_context;
  bool vidbo = false;
  int *input_vals = NULL;
  int num_inputs = 0;
  const char *arg_vidbo = Verilated::commandArgsPlusMatch("vidbo=");
  if (true /*arg_vidbo[0]*/) {
    vidbo = true;
    /* TODO: set address/port from argument? */
    vidbo_init(&vidbo_context, 8081);
    const char * const inputs[] =
      {"gpio.SW0" ,"gpio.SW1" ,"gpio.SW2" ,"gpio.SW3",
       "gpio.SW4" ,"gpio.SW5" ,"gpio.SW6" ,"gpio.SW7",
       "gpio.SW8" ,"gpio.SW9" ,"gpio.SW10","gpio.SW11",
       "gpio.SW12","gpio.SW13","gpio.SW14","gpio.SW15"};

    num_inputs = sizeof(inputs) / sizeof(inputs[0]);
    input_vals = (int *)calloc(num_inputs, sizeof(int));
    vidbo_register_inputs(inputs, num_inputs);
  }

  signal(SIGINT, INThandler);

  top->clk = 1;
  top->rst = 1;
  unsigned int last_o_gpio = 0;
  while (!(done || Verilated::gotFinish())) {
    if (main_time == 100) {
      printf("Releasing reset\n");
      top->rst = 0;
    }
    if (main_time == 200)
      top->i_jtag_trst_n = true;

    top->eval();
    if (tfp)
      tfp->dump(main_time);
    if (baud_rate && do_uart(&uart_context, top->o_uart_tx)) {
      if (vidbo)
	vidbo_send(&vidbo_context, main_time, "serial", "uart", uart_context.ch);
      else
	putchar(uart_context.ch);
    }
    if (jtag && (main_time > 300)) {
      int ret = jtag->doJTAG(main_time/20, //doJtag requires t to only increment by one
		   &top->i_jtag_tms,
		   &top->i_jtag_tdi,
		   &top->i_jtag_tck,
		   top->o_jtag_tdo);
      if (ret != VerilatorJtagServer::SUCCESS) {
        if (ret == VerilatorJtagServer::CLIENT_DISCONNECTED) {
          printf("Ending simulation. Reason: jtag_vpi client disconnected.\n");
          done = true;
        }
        else {
          printf("Ending simulation. Reason: jtag_vpi error encountered.\n");
          done = true;
        }
      }
    }
    if (last_o_gpio != top->o_gpio) {
      last_o_gpio = top->o_gpio;
      if (vidbo) {
	char item[5] = {0}; //Space for LD??\0
	for (int i=0 ; i<16 ; i++) {
	  snprintf(item, 5, "LD%d", i);
	  vidbo_send(&vidbo_context, main_time, "gpio", item, (top->o_gpio>>i) & 0x1);
	}
      }
      else
	printf("%lu: o_gpio is %08x\n", main_time, last_o_gpio);
    }
    if (timeout && (main_time >= timeout)) {
      printf("Timeout: Exiting at time %lu\n", main_time);
      done = true;
    }
    if (vidbo && !(main_time % 10000))
      if (vidbo_recv(&vidbo_context, input_vals)) {
	top->i_gpio = 0;
	for (int i=0 ; i<num_inputs ; i++)
	  top->i_gpio |= ((!!input_vals[i]) << (i+16));
      }
    top->clk = !top->clk;
    main_time+=10;
  }

  if (tfp)
    tfp->close();

  exit(0);
}
