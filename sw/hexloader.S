#define UART_BASE     0x80002000
	/*
	x1  : ra = return address for other calls
	x2  : sp = start address
	x3  : gp = base address
	x4  : tp = record length
	x5  : t0 = return address for getc
	x6  : t1 = ':'
	x7  : t2 = parsebyte temp
	x8  : s0 = crc
	x9  : s1 = record type
	x10 : a0 = call/return value
	x11 : a1 = UART base address
	x12 : a2 = Program entry point
	*/
#define REG_BRDL (4*0x00) /* Baud rate divisor (LSB)        */
#define REG_BRDH (4*0x01) /* Baud rate divisor (MSB)        */
#define REG_RDR (4*0x00)  /* Receiver data reg.             */
#define REG_MDC (4*0x04)  /* Modem control reg.             */
#define REG_IER (4*0x01)  /* Interrupt enable reg.          */
#define REG_IIR (4*0x02)  /* Interrupt ID reg.              */
#define REG_FCR (4*0x02)  /* FIFO control reg.              */
#define REG_LCR (4*0x03)  /* Line control reg.              */
#define REG_MDC (4*0x04)  /* Modem control reg.             */
#define REG_LSR (4*0x05)  /* Line status reg.               */
#define REG_MSR (4*0x06)  /* Modem status reg.              */
#define REG_DLF (4*0xC0)  /* Divisor Latch Fraction         */

#define LCR_CS8 0x03   /* 8 bits data size */
#define LCR_1_STB 0x00 /* 1 stop bit */
#define LCR_PDIS 0x00  /* parity disable */

#define MCR_DTR 0x01  /* dtr output */
#define MCR_RTS 0x02  /* rts output */
#define MCR_OUT2 0x08 /* output #2 */

#define FCR_FIFO 0x01    /* enable XMIT and RCVR FIFO */
#define FCR_RCVRCLR 0x02 /* clear RCVR FIFO */
#define FCR_XMITCLR 0x04 /* clear XMIT FIFO */
#define FCR_MODE0 0x00 /* set receiver in mode 0 */
#define FCR_MODE1 0x08 /* set receiver in mode 1 */
#define FCR_FIFO_8 0x80  /* 8 bytes in RCVR FIFO */

.globl serial_boot
serial_boot:
	addi t5, zero, 0
	addi t6, zero, 0
	addi a2, zero, 0
	addi gp, zero, 0
	li a1, UART_BASE

	/* clear the port */
	lb	t3, REG_RDR(a1)

	li	t1, ':'

	/* Clear CRC */
	add s0, zero, zero

	/* Find start of new record by looking for ':' */
findrecord:
	jal	t0, get_byte
	/* get_byte returns byte in a0 */
	bne	a0, t1, findrecord
	addi	t6, t6, 1

	/* Get record length */
	jal	ra, parsebyte
	addi	tp, a0, 0

	/* Get start address */
	jal ra, parsebyte
	slli sp, a0, 8

	jal ra, parsebyte
	or sp, sp, a0

	/* Get record type */
	jal ra, parsebyte

	/* Record type 0 == data record */
	beqz a0, datarecord

	addi a0, a0, -1
	/* Record type 1 == end of file record */
	beqz a0, eofrecord

	/* Abort on non-supported record types for now */
	j error

eofrecord:
	li	t5, 'G'
	sb	t5, 0(a1)
	fence
	li	t5, 'o'
	sb	t5, 0(a1)
	fence
	li	t5, '!'
	sb	t5, 0(a1)
	fence
	jr a2

datarecord:
	add sp, gp, sp /* Base address + record offset */
	add tp, sp, tp /* Base address + record offset + record length */
1:
	jal parsebyte
	sb a0, 0(sp)
	addi sp, sp, 1
	bne tp, sp, 1b

crc:
	jal parsebyte
	andi s0, s0, 0xff
	bnez s0, error

	li	t5, '.'
	sb	t5, 0(a1)
	fence

	j findrecord

	/*
	Read two hex chars and combine to byte
	*/
parsebyte:
	/* Get first nibble */
	jal t0, get_byte
	blt a0, t1, 1f
	addi a0, a0, -7
1:	addi a0, a0, -48

	slli t2, a0, 4

	/* Get second nibble */
	jal t0, get_byte
	blt a0, t1, 2f
	addi a0, a0, -7
2:	addi a0, a0, -48

	or  a0, a0, t2
	andi a0, a0, 0xff

	/* Update CRC */
	add s0, s0, a0

	ret

error:
	li	t5, 'E'
	sb	t5, 0(a1)
	li	t5, 'r'
	sb	t5, 0(a1)
	sb	t5, 0(a1)
	li	t5, 'o'
	sb	t5, 0(a1)
	li	t5, 'r'
	sb	t5, 0(a1)

	/* Nothing to do. Spin here */
	j	error

get_byte:
	/* Read line status reg and check data available bit */
	lb a0, REG_LSR(a1)
	andi a0, a0, 1
	beqz a0, get_byte

	/* Get character */
	lb a0, REG_RDR(a1)
	jr t0
