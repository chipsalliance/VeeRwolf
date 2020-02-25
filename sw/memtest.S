#define GPIO_BASE 0x80001010
#define DELAY 0x1000 /*0000*/ /* Loop 100000 times before inverting the LED */
#define MEM_START 0
#define MEM_END 0x1FF

.globl _start
_start:
	li x1, 0x03020100 //Word 1
	li x2, 0x07060504 //Word 2
	li x8, 0x0B0A0908 //Word 3
	li x9, 0x0F0E0D0C //Word 4

	li x3, MEM_START //Address base pointer
	li x7, MEM_END

	addi x10, x0, 16
wordloop:
	add x4, x0, x0 //Offset pointer
	sw x1,  0(x3)
	sw x2,  4(x3)
	sw x8,  8(x3)
	sw x9, 12(x3)
byteloop:
	add x5, x3, x4 //Byte address pointer
	lb  x6, 0(x5)  //Loaded byte
	bne x4, x6, error

	addi x4, x4, 1
	bne x4, x10, byteloop

	/* Destroy written memory */
	sw x0,  0(x3)
	sw x0,  4(x3)
	sw x0,  8(x3)
	sw x0, 12(x3)

	addi x3, x3, 16
	blt x3, x7, wordloop


	li a0, GPIO_BASE
	addi t0, x0, 1
	sb t0, 0(a0)

done:
	j done

error:
	li a0, GPIO_BASE
	li t1, DELAY

bl1:
	sb t0, 0(a0)
	xori t0, t0, 1
	and t2, zero, zero
time1:
	addi t2, t2, 1
	bne t1, t2, time1
	j bl1
