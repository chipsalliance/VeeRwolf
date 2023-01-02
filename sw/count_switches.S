/*
* Switch counter
* Assuming that GPIO_BASE is mapped to a GPIO core, which in turn is
* connected to LEDs and switches, this will count the number of switches
* in the "on" position and light the same LEDs.
*/
#define GPIO_BASE 0x80001010

	/*
	a0 = GPIO Base address
	t0 = Value of switches
	t1 = Number of active switches (kind of)
	t2 = Value of currently evaluated switch

	*/

.globl _start
_start:
	/* Load GPIO base address to a0 */
	li	a0, GPIO_BASE

	/* Read switches */
	lhu	t0, 2(a0)

	/* Set t1 to one. */
	addi	t1, zero, 1

	/* Mask out lowest bit */
l1:	andi	t2, t0, 1

	/* If bit is set, left shift t1 one step */
	beqz	t2, l2
	slli	t1, t1, 1

	/* Shift out next bit from t0 and repeat until t0 is empty */
l2:	srli	t0, t0, 1
	bnez	t0, l1

	/*
	This changes the bit in t1 to indicate the number of steps it has
	been shifted
	*/
	addi	t1, t1,-1

	/* Write to LEDs */
	sh	t1, 0(a0)

	j	_start
