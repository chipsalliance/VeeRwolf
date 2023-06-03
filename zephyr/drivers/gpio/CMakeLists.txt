# Copyright (c) 2020 Olof Kindgren <olof.kindgren@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

set(ZEPHYR_CURRENT_LIBRARY drivers__gpio)

zephyr_library_sources_ifdef(CONFIG_GPIO_VEERWOLF gpio_veerwolf.c)

