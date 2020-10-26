/*
* Hello world for SweRVolf
*
* Prints a fancy string and exits afterwards
*
*/
#define CONSOLE_ADDR 0x80001008
#define HALT_ADDR    0x80001009

	/*
	a0 = Console address
	a1 = String address
	t0 = Character to write
	*/

.globl _start
_start:
	/* Load console address to a0 */
	li  a0,     CONSOLE_ADDR

	/* Load string address to a0 */
	la  a1,     str

	/* Load first byte */
	lb t0, 0(a1)
next:
	/* Write to console and load next char until we get \0 */
	sb t0, 0(a0)
	addi a1, a1, 1
	lb t0, 0(a1)
	bne t0, zero, next

	/* Halt simulation */
	li  a1,     HALT_ADDR
	sb zero, 0(a1)
str:
	.section .data
	.string "SweRV+FuseSoC rocks\n"
