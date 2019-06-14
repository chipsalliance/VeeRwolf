/*
* Hello world for SweRVolf
* 
* Prints a fancy string and exits afterwards
* 
*/
#define CONSOLE_ADDR 0x10000000
#define HALT_ADDR    0x20000000

	/*
	a0 = Console address
	a1 = String address
	t0 = Character to write
	*/

.globl _start
_start:
	/* Load console address to a0 */
	lui  a0,     %hi(CONSOLE_ADDR)
	addi a0, a0, %lo(CONSOLE_ADDR)

	/* Load string address to a0 */
	lui  a1,     %hi(str)
	addi a1, a1, %lo(str)

	/* Load first byte */
	lb t0, 0(a1)
next:
	/* Write to console and load next char until we get \0 */
	sb t0, 0(a0)
	addi a1, a1, 1
	lb t0, 0(a1)
	bne t0, zero, next

	/* Halt simulation */
	lui  a1,     %hi(HALT_ADDR)
	addi a1, a1, %lo(HALT_ADDR)
	sw zero, 0(a1)
str:
	.section .data
	.string "SweRV+FuseSoC rocks\n"

