/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>

void main(void)
{
  u8_t ver_rev   = sys_read8(0x80001000);
  u8_t ver_minor = sys_read8(0x80001001);
  u8_t ver_major = sys_read8(0x80001002);
  u8_t ver_dirty = sys_read8(0x80001003);

  u32_t ver_sha = sys_read32(0x80001004);

  printk("\nSweRVolf version %d.%d.%d (SHA %08x)\n",
	 ver_major,
	 ver_minor,
	 ver_rev,
	 ver_sha);

  printk("     __\n");
  printk("   []  []-o CHIPS\n");
  printk(" o-[]  []\n");
  printk("   []  []-o ALLIANCE\n");
  printk(" o-[]__[]\n\n");

  if (ver_dirty)
    printk("Warning! SweRVolf was built from a modified source tree\n");

  u8_t mem_status = sys_read8(0x8000100a);
  if (mem_status & 0x1)
    printk("Memory test completed %s\n", (mem_status & 2) ? "with errors" : "successfully");
  else
    printk("Warning! Memory test did not complete\n");

  //Exit simulation. No effect on hardware
  sys_write8(1, 0x80001009);

  printk("Now proceeding to blink the LED\n");

  u16_t leds = 1;
  u16_t gpio_old = sys_read16(0x80001012);
  u16_t gpio_new = sys_read16(0x80001012);
  while (1) {
    sys_write16(leds, 0x80001010);
    leds = (leds << 1) | (leds >> 15);
    gpio_new = sys_read16(0x80001012);
    if (gpio_old != gpio_new) {
      printk("GPIO is now %04x\n", gpio_new);
      gpio_old = gpio_new;
    }
    k_sleep(100);
  }
}
