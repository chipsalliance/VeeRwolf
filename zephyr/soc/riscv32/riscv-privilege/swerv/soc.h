/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __RISCV32_SWERVOLF_SOC_H_
#define __RISCV32_SWERVOLF_SOC_H_

#include <soc_common.h>

#define DT_UART_NS16550_PORT_0_NAME      "uart0"
#define DT_UART_NS16550_PORT_0_BASE_ADDR 0x80002000
#define DT_UART_NS16550_PORT_0_BAUD_RATE (115200/16)
#define DT_UART_NS16550_PORT_0_CLK_FREQ 25000000
/* Following defines are needed for LED support until there is
   devices trees are in place. LED controller is defined in soc.c */
#define LED0_GPIO_CONTROLLER "LED0"
#define LED0_GPIO_PIN 0

/* Hard code memory info here until we have device tree support */
#define DT_SRAM_BASE_ADDRESS 0x00000000
#define DT_SRAM_SIZE         0x00800000

#define RISCV_MTIME_BASE    0x80001020
#define RISCV_MTIMECMP_BASE 0x80001028

/* Also define the following for Zephyr 1.14 compatibility */
#define CONFIG_RISCV_RAM_BASE_ADDR DT_SRAM_BASE_ADDRESS
#define CONFIG_RISCV_RAM_SIZE      DT_SRAM_SIZE

/* Timer configuration */
#define SERV_TIMER_BASE             0x80001018
#define SERV_TIMER_IRQ              7

/* lib-c hooks required RAM defined variables */
#define RISCV_RAM_BASE               DT_SRAM_BASE_ADDRESS
#define RISCV_RAM_SIZE               KB(DT_SRAM_SIZE)

#endif /* __RISCV32_SERV_SOC_H_ */
