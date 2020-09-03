	.extern _gp

	.section ".crt0", "ax"
	.global _start
_start:
	.rept	65
	j	.loop
	.endr

.loop:	b!	.loop

	.space  0xe04 - ( . - _start)

_entry:
	# disable irq
	ldi	r4, 0
	mtcr	r4, cr0
	nop!
	nop!
	nop!
	nop!
	nop

	# setup gp
	la	r28, _gp
	# setup stack
	la	r0, 0xa0fffffc

#	ldi	r4, 0
	la	r5, __bss_wsize__
	mtsr	r5, sr0
	la	r6, __bss_end__
	b!	.clearbss

.clearbss_loop:
	push!	r4, [r6]
.clearbss:
	bcnz!	.clearbss_loop

	jl!	main

	.global exit
exit:
	b exit

