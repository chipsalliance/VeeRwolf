TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-

%.elf: %.S
	$(TOOLCHAIN_PREFIX)gcc -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -o$@ $<
%.vh: %.bin
	python3 makehex.py $< > $@
%.bin: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
%.ihex: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O ihex $< $@
clean:
	rm -f *.elf *.bin *.vh
