/*
* Hello world for SweRVolf
*
* Prints a fancy string using the UART and exits afterwards
*
*/
#define CONSOLE_ADDR 0x80001008
#define HALT_ADDR    0x80001009
#define UART_BASE    0x80002000

#define REG_BRDL (4*0x00) /* Baud rate divisor (LSB)        */
#define REG_IER (4*0x01)  /* Interrupt enable reg.          */
#define REG_FCR (4*0x02)  /* FIFO control reg.              */
#define REG_LCR (4*0x03)  /* Line control reg.              */
#define REG_LSR (4*0x05)  /* Line status reg.               */
#define LCR_CS8 0x03   /* 8 bits data size */
#define LCR_1_STB 0x00 /* 1 stop bit */
#define LCR_PDIS 0x00  /* parity disable */

#define LSR_THRE 0x20
#define FCR_FIFO 0x01    /* enable XMIT and RCVR FIFO */
#define FCR_RCVRCLR 0x02 /* clear RCVR FIFO */
#define FCR_XMITCLR 0x04 /* clear XMIT FIFO */
#define FCR_MODE0 0x00 /* set receiver in mode 0 */
#define FCR_MODE1 0x08 /* set receiver in mode 1 */
#define FCR_FIFO_8 0x80  /* 8 bytes in RCVR FIFO */

	/*
	a0 = UART address
	a1 = String address
	t0 = Character to write
	*/

.globl _start
_start:
	/* Init UART */
	li	a0, UART_BASE

	/* Set DLAB bit in LCR */
	li	t3, 0x80
	sb	t3, REG_LCR(a0)

	/* Set divisor regs */
	li	t4, 27
	sb	t4, REG_BRDL(a0)

	/* 8 data bits, 1 stop bit, no parity, clear DLAB */
	li	t3, LCR_CS8 | LCR_1_STB | LCR_PDIS
	sb	t3, REG_LCR(a0)

	li	t3, FCR_FIFO | FCR_MODE0 | FCR_FIFO_8 | FCR_RCVRCLR | FCR_XMITCLR
	sb	t3, REG_FCR(a0)

	/* disable interrupts  */
	sb	zero, REG_IER(a0)

	/* Load string address to a0 */
	la  a1,     str

	/* Load first byte */
	lb t0, 0(a1)
next:
	/* Write to console and load next char until we get \0 */
	jal put_byte
	addi a1, a1, 1
	lb t0, 0(a1)
	bne t0, zero, next

loop:	j loop
	/* Halt simulation */
	li  a1,     HALT_ADDR
	//sw zero, 0(a1)

put_byte:
	/* Check for space in UART FIFO */
	lb	t6, REG_LSR(a0)
	andi	t6, t6, LSR_THRE
	beqz	t6, put_byte

	sb	t0, 0(a0)
	ret

	.section .data
str:
	.string "SweRV+FuseSoC rocks\n"
