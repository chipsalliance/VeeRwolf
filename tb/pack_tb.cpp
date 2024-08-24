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
// Function: Verilator testbench for VeeRwolf
// Comments:
//
//********************************************************************************

#include <stdint.h>
#include <signal.h>

#include "Vveerwolf_pack_top.h"

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

using namespace std;

static bool done;

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
  bool ready_to_read; // flag to keep track of whether we wrote to UART before reading
} uart_context_t;

void uart_init(volatile uart_context_t *context, uint32_t baud_rate) {
  context->baud_t = 1000*1000*1000/baud_rate;
  context->state = 0;
  context->ready_to_read = false;
}

// FSM to read a byte from UART
int read_uart(volatile uart_context_t *context, uint64_t main_time, bool rx) {
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

// FSM to write a byte to UART
int write_uart(volatile uart_context_t *context, vluint64_t main_time, uint8_t *tx) {
  if (context->state == 0) {
    *tx = 1;
    context->state++;
  }
  else if (context->state == 1) {
    *tx = 0;
    context->last_update = main_time + context->baud_t/2;
    context->state++;
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
      *tx = context->ch & 1;
      context->ch >>= 1;
      context->state++;
    }
  }
  else {
    if (main_time > context->last_update) {
      context->last_update += context->baud_t;
      context->state=0;
      context->ready_to_read = true;
      *tx = 1;
      return 1;
    }
  }
  return 0;
}

int main(int argc, char **argv, char **env)
{
  const unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->commandArgs(argc, argv);

  // Set debug level, 0 is off, 9 is highest presently used
  // May be overridden by commandArgs argument parsing
  contextp->debug(0);

  uint16_t gpios[2] = {0, 0};
  const unique_ptr<Vveerwolf_pack_top> top{new Vveerwolf_pack_top{contextp.get(), "TOP"}};

  volatile uart_context_t uart_context;
  int baud_rate = 115200;

  uart_init(&uart_context, baud_rate);

  vluint64_t timeout = 0;
  const vluint64_t incr_gpio = 10000000;
  const char *arg_timeout = contextp->commandArgsPlusMatch("timeout=");

  if (arg_timeout[0])
    timeout = atoi(arg_timeout+9);

  signal(SIGINT, INThandler);

  top->clk = 1;
  top->rstn = 0;
  top->i_sw = gpios[0];

  while (!(done || contextp->gotFinish())) {
    if (contextp->time() == 100) {
      printf("Releasing reset\n");
      top->rstn = 1;
    }

    top->eval();

    if(!uart_context.ready_to_read && write_uart(&uart_context, contextp->time(), &top->i_uart_rx)){
      printf("%lu: Successfully sent a byte through UART!\n", contextp->time());
    }

    if (uart_context.ready_to_read && read_uart(&uart_context, contextp->time(), top->o_uart_tx)){
      printf("%lu: Read \"%d\" from UART\n", contextp->time(), uart_context.ch);
      fflush(stdout);
    }

    if (gpios[1] != (top->o_led)) {
      gpios[1] = top->o_led;
      printf("%lu: gpio output is %u\n", contextp->time(), gpios[1]);
    }

    if (timeout && (contextp->time() >= timeout)) {
      printf("Timeout: Exiting at time %lu\n", contextp->time());
      done = true;
    }

    top->clk = !top->clk;
    contextp->timeInc(10);

    if(contextp->time() % incr_gpio == 0){
      printf("%lu: Incrementing GPIO input\n");
      top->i_sw = ++gpios[0];
    }
  }

  return 0;
}
