/*
 * Copyright (c) 2020 Olof Kindgren <olof.kindgren@gmail.com>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define DT_DRV_COMPAT veerwolf_gpio

#include <errno.h>
#include <device.h>
#include <drivers/gpio.h>
#include <zephyr/types.h>
#include <sys/util.h>
#include <string.h>
#include <logging/log.h>

#define LOG_LEVEL CONFIG_GPIO_LOG_LEVEL
LOG_MODULE_REGISTER(gpio_veerwolf);

struct gpio_veerwolf_cfg {
	volatile uint32_t *reg_addr;
	int nr_gpios;
	bool port_is_output;
};

struct gpio_veerwolf_data {
	struct gpio_driver_data common;
};

/* Helper macros for GPIO */

#define DEV_GPIO_CFG(dev)						\
	((const struct gpio_veerwolf_cfg *)(dev)->config)

#define DEV_GPIO_ADDR(dev) \
  ((mem_addr_t)DEV_GPIO_CFG(dev)->reg_addr)

/* Driver functions */

static int gpio_veerwolf_init(const struct device *dev)
{
	return 0;
}

static int gpio_veerwolf_configure(const struct device *dev,
				gpio_pin_t pin, gpio_flags_t flags)
{
	return 0;
}

static int gpio_veerwolf_port_get_raw(const struct device *dev,
				   gpio_port_value_t *value)
{
	mem_addr_t addr = DEV_GPIO_ADDR(dev);

	*value = sys_read32(addr);
	return 0;
}

static int gpio_veerwolf_port_set_masked_raw(const struct device *dev,
					  gpio_port_pins_t mask,
					  gpio_port_value_t value)
{
	mem_addr_t addr = DEV_GPIO_ADDR(dev);
	uint32_t port_val;

	port_val = sys_read32(addr);
	port_val = (port_val & ~mask) | (value & mask);
	sys_write32(port_val, addr);

	return 0;
}

static int gpio_veerwolf_port_set_bits_raw(const struct device *dev,
					gpio_port_pins_t pins)
{
	mem_addr_t addr = DEV_GPIO_ADDR(dev);
	uint32_t port_val;

	port_val = sys_read32(addr) | pins;
	sys_write32(port_val, addr);

	return 0;
}

static int gpio_veerwolf_port_clear_bits_raw(const struct device *dev,
					  gpio_port_pins_t pins)
{
	mem_addr_t addr = DEV_GPIO_ADDR(dev);
	uint32_t port_val;

	port_val = sys_read32(addr) & ~pins;
	sys_write32(port_val, addr);

	return 0;
}

static int gpio_veerwolf_port_toggle_bits(const struct device *dev,
				       gpio_port_pins_t pins)
{
	mem_addr_t addr = DEV_GPIO_ADDR(dev);
	uint32_t port_val;

	port_val = sys_read32(addr) ^ pins;
	sys_write32(port_val, addr);

	return 0;
}

static int gpio_veerwolf_pin_interrupt_configure(const struct device *dev,
					      gpio_pin_t pin,
					      enum gpio_int_mode mode,
					      enum gpio_int_trig trig)
{
	int ret = 0;

	if (mode != GPIO_INT_MODE_DISABLED) {
		ret = -ENOTSUP;
	}
	return ret;
}

static const struct gpio_driver_api gpio_veerwolf_driver_api = {
	.pin_configure = gpio_veerwolf_configure,
	.port_get_raw = gpio_veerwolf_port_get_raw,
	.port_set_masked_raw = gpio_veerwolf_port_set_masked_raw,
	.port_set_bits_raw = gpio_veerwolf_port_set_bits_raw,
	.port_clear_bits_raw = gpio_veerwolf_port_clear_bits_raw,
	.port_toggle_bits = gpio_veerwolf_port_toggle_bits,
	.pin_interrupt_configure = gpio_veerwolf_pin_interrupt_configure,
};

/* Device Instantiation */

#define GPIO_VEERWOLF_INIT(n) \
	static const struct gpio_veerwolf_cfg gpio_veerwolf_cfg_##n = {	\
		.reg_addr =						\
		(volatile uint32_t *) DT_INST_REG_ADDR(n),		\
		.nr_gpios = DT_INST_PROP(n, ngpios),			\
	};								\
	static struct gpio_veerwolf_data gpio_veerwolf_data_##n;	\
									\
	DEVICE_DEFINE(veerwolf_gpio_##n,				\
		      DT_INST_LABEL(n),					\
		      gpio_veerwolf_init,				\
		      NULL,						\
		      &gpio_veerwolf_data_##n,				\
		      &gpio_veerwolf_cfg_##n,				\
		      POST_KERNEL,					\
		      CONFIG_KERNEL_INIT_PRIORITY_DEVICE,		\
		      &gpio_veerwolf_driver_api				\
		      );

DT_INST_FOREACH_STATUS_OKAY(GPIO_VEERWOLF_INIT)
