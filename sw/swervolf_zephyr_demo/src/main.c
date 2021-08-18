/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>

void main(void)
{
  uint8_t ver_patch  = sys_read8(0x80001000);
  uint8_t ver_minor = sys_read8(0x80001001);
  uint8_t ver_major = sys_read8(0x80001002);
  uint8_t ver_misc  = sys_read8(0x80001003);

  uint32_t ver_sha = sys_read32(0x80001004);

  printk("\nSweRVolf version %d.%d.%d.%d (SHA %08x)\n",
	 ver_major,
	 ver_minor,
	 ver_patch,
	 ver_misc & 0x7F,
	 ver_sha);

  printk("     __\n");
  printk("   []  []-o CHIPS\n");
  printk(" o-[]  []\n");
  printk("   []  []-o ALLIANCE\n");
  printk(" o-[]__[]\n\n");

  if (ver_misc & 0x80)
    printk("Warning! SweRVolf was built from a modified source tree\n");

  uint8_t mem_status = sys_read8(0x8000100a);
  if (mem_status & 0x1)
    printk("Memory test completed %s\n", (mem_status & 2) ? "with errors" : "successfully");
  else
    printk("Warning! Memory test did not complete\n");

  printk("CPU type: ");
  uint32_t marchid;
  __asm__ volatile ("csrr %0, marchid" : "=r" (marchid));
  switch (marchid) {
  case 11 : printk("EH1\n"); break;
  case 16 : printk("EL2\n"); break;
  default : printk("Unknown (marchid=%d)\n", marchid);
  }

  printk("Clock frequency: %d MHz\n", sys_read32(0x8000103c)/1000000);

  //Exit simulation. No effect on hardware
  sys_write8(1, 0x80001009);

  printk("Now proceeding to blink the LED\n");

  uint16_t leds = 1;
  uint16_t gpio_old = sys_read16(0x80001012);
  uint16_t gpio_new = sys_read16(0x80001012);
  while (1) {
    sys_write16(leds, 0x80001010);
    leds = (leds << 1) | (leds >> 15);
    gpio_new = sys_read16(0x80001012);
    if (gpio_old != gpio_new) {
      printk("GPIO is now %04x\n", gpio_new);
      gpio_old = gpio_new;
    }
    k_msleep(100);
  }
}
