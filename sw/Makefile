TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-
RESET_VECTOR ?= 0
FLASH_ADDR ?= 0x0

%.elf: %.S
	$(TOOLCHAIN_PREFIX)gcc -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -o$@ $<
%.vh: %.bin
	python3 makehex.py $< > $@
%.bin: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
%.ihex: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O ihex $< $@
%.ub: %.bin
	mkimage \
	-A riscv \
	-C none \
	-T standalone \
	-a 0x0 \
	-e $(RESET_VECTOR) \
	-n '$@' \
	-d $< \
	$@

%.ubvh: %.ub
	objcopy --change-addresses $(FLASH_ADDR) -I binary -O verilog $< $@

clean:
	rm -f *.elf *.bin *.vh
