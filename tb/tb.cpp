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

void do_uart(uart_context_t *context, bool rx) {
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
      putchar(context->ch);
      context->state=1;
    }
  }
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

  signal(SIGINT, INThandler);

  top->clk = 1;
  top->rst = 1;
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
    if (baud_rate) do_uart(&uart_context, top->o_uart_tx);
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
    if (gpio0 != (top->o_gpio & 0x1)) {
      gpio0 = top->o_gpio & 0x1;
      printf("%lu: gpio0 is %s\n", main_time, gpio0 ? "on" : "off");
    }
    if (timeout && (main_time >= timeout)) {
      printf("Timeout: Exiting at time %lu\n", main_time);
      done = true;
    }
    top->clk = !top->clk;
    main_time+=10;
  }

  if (tfp)
    tfp->close();

  exit(0);
}
