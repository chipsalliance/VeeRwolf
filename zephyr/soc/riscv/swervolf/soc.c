/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <drivers/gpio/gpio_mmio32.h>
#include "soc.h"

GPIO_MMIO32_INIT(led0,
		 DT_ALIAS_LED0_GPIOS_CONTROLLER,
		 DT_ALIAS_LED0_GPIOS_ADDRESS,
		 DT_ALIAS_LED0_GPIOS_MASK);

/* The SweRVolf SoC can run at various CPU clock frequencies depending on which
   CPU is used and which hardware it runs on. The actual clock frequency is
   stored at synthesis time in register 0x8000103C. This value is used to set
   e.g. timer frequency but unfortunately the Zephyr UART driver does not handle
   dynamic clock frequencies and instead always reads the value from the device
   tree.

   This function works around this by setting a baud rate based on the actual
   clock frequency after the UART driver has initialized. This however has the
   limitation that the UART base address (and clock freq reg) is hard-coded.
   Long-term solution is to fix this limitation in the Zephyr UART driver.
*/
static int fix_baud_rate(const struct device *arg)
{
	ARG_UNUSED(arg);

	uint32_t divisor; /* baud rate divisor */
	uint8_t lcr_cache;

	uint32_t UART_BASE = 0x80002000;
	uint32_t REG_LCR  = UART_BASE+4*3;
	uint8_t LCR_DLAB = 0x80;
	uint32_t REG_BRDL = UART_BASE+4*0;
	uint32_t REG_BRDH = UART_BASE+4*1;
	uint32_t baud_rate = DT_PROP(DT_PATH(soc, uart_80002000), current_speed);
	uint32_t sys_clk_freq = sys_read32(0x8000103c);

	/*
	 * calculate baud rate divisor. a variant of
	 * (uint32_t)(dev_cfg->sys_clk_freq / (16.0 * baud_rate) + 0.5)
	 */
	divisor = ((sys_clk_freq + (baud_rate << 3))
		   / baud_rate) >> 4;

	/* set the DLAB to access the baud rate divisor registers */
	lcr_cache = sys_read8(REG_LCR);
	sys_write8(lcr_cache | LCR_DLAB, REG_LCR);
	sys_write8( divisor       & 0xff, REG_BRDL);
	sys_write8((divisor >> 8) & 0xff, REG_BRDH);

	sys_write8(lcr_cache, REG_LCR);

	return 0;
}

SYS_INIT(fix_baud_rate, POST_KERNEL, 0);
