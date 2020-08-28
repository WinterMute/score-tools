	.extern _gp

	.section ".crt0","ax"
	.global _start
_start:
	.rept	65
	j	.loop
	.endr

.loop:	b!	.loop

	.space  0xe04 - ( . - _start)

_entry:
	la	r28, _gp

	la      r6, __bss_start__
	la      r7, __bss_end__
	ldiu!   r8, 0
	b!	.clearbss

.clearbss_loop:
	sw!     r8, [r6]
	addi    r6, 4
.clearbss:
	cmp!    r6, r7
	bne    .clearbss_loop

	jl	main

	.global exit
exit:
	b exit
