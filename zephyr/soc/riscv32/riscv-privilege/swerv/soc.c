/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <gpio/gpio_mmio32.h>
#include "soc.h"

GPIO_MMIO32_INIT(led0, LED0_GPIO_CONTROLLER,
		 0x80001010, 0x00000001);
