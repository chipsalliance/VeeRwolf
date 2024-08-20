/*
* Firmware for the Veerwolf Wolf Pack project
*
* Reads a number from UART, adds 1 and writes it to UART
* Same thing for GPIOs
*
*/
#define CONSOLE_ADDR 0x80001008
#define HALT_ADDR    0x80001009
#define UART_BASE    0x80002000
#define GPIO_BASE    0x80001010

#define REG_BRDL (4*0x00) /* Baud rate divisor (LSB)        */
#define REG_RDR (4*0x00)  /* Receiver data reg.             */
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
	a1 = GPIO base address
	t0 = Byte to write
	*/

.globl _start
_start:
	/* Init UART */
	li	a0, UART_BASE

	/* Load GPIO base address to a0 */
	lui a1, %hi(GPIO_BASE)
	addi a1, a1, %lo(GPIO_BASE)

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

get_byte:
	/* Read line status reg and check data available bit */
	lb t6, REG_LSR(a0)
	andi t6, t6, 1
	beqz t6, do_gpio

	/* Get byte */
	lbu t0, REG_RDR(a0)

put_byte:
	/* Check for space in UART FIFO */
	lb	t6, REG_LSR(a0)
	andi	t6, t6, LSR_THRE
	beqz	t6, put_byte

	/* Add 1 */ 
	addi t0, t0, 1

	/* Write to UART */ 
	sb	t0, 0(a0)

do_gpio:
	/* Read first 2 bytes of GPIO */
	lhu t1, 0(a1)

	/* Add 1 */
	addi t1, t1, 1

	/* Store number in 3rd and 4th byte of GPIO */
	sh t1, 2(a1)
	
	j get_byte


    /* Halt simulation (never happens) */
	li  a1,     HALT_ADDR
	sw zero, 0(a1)