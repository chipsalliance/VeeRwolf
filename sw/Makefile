%.elf: %.S
	riscv64-unknown-elf-gcc -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -o$@ $<
%.vh: %.bin
	python makehex.py $< > $@
#%.vh: %.elf
#	riscv64-unknown-elf-objcopy -O verilog $< $@
%.bin: %.elf
	riscv64-unknown-elf-objcopy -O binary $< $@
clean:
	rm -f *.elf *.bin *.vh
