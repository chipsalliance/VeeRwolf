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
