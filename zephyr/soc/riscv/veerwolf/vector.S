/*
 * Copyright (c) 2017 Jean-Paul Etienne <fractalclone@gmail.com>
 * Contributors: 2018 Antmicro <www.antmicro.com>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <toolchain.h>

/* exports */
GTEXT(__start)

/* imports */
GTEXT(__initialize)
GTEXT(__irq_wrapper)

SECTION_FUNC(vectors, __start)
	.option norvc;

	/*
	 * Set mtvec (Machine Trap-Vector Base-Address Register)
	 * to __irq_wrapper.
	 */
	la t0, __irq_wrapper
	csrw mtvec, t0
	/*
	* To avoid having to hardcode the main clock frequency,
	* we read the actual value from register 0x8000103c
	* and store to z_clock_hw_cycles_per_sec
	*/
	li	t0, 0x80001000
	lw	t1, 0x3c(t0)
	la	t0, z_clock_hw_cycles_per_sec
	sw	t1, 0(t0)

	/* Jump to __initialize */
	tail __initialize
