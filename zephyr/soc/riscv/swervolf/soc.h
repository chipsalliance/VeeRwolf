/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __RISCV32_SWERVOLF_SOC_H_
#define __RISCV32_SWERVOLF_SOC_H_

#include "soc_common.h"
#include <devicetree.h>

#define DT_ALIAS_LED0_GPIOS_CONTROLLER "LED0"
#define DT_ALIAS_LED0_GPIOS_PIN        0
#define DT_ALIAS_LED0_GPIOS_ADDRESS    0x80001010
#define DT_ALIAS_LED0_GPIOS_MASK       0x00000001

#define RISCV_MTIME_BASE             0x80001020
#define RISCV_MTIMECMP_BASE          0x80001028

/* lib-c hooks required RAM defined variables */
#define RISCV_RAM_BASE               DT_SRAM_BASE_ADDRESS
#define RISCV_RAM_SIZE               KB(DT_SRAM_SIZE)

#endif /* __RISCV32_SERV_SOC_H_ */
