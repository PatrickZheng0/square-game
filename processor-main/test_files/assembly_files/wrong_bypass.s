nop				# Tests for faulty bypassing
nop				# Author: Philip Xue
nop
nop
nop
addi $1, $0, 11		# set values that jr should jump to if bypassing is done correctly
addi $2, $0, 17
nop
nop
sw $1, 15($0)		# shouldn't be bypassed
jr $1				# should NOT Jump to 255
nop
nop
addi $5, $0, 1		# r5 = 1
sw $2, 21($0)		# shouldn't be bypassed
nop
jr $2				# should NOT jump to 255
nop
nop
addi $6, $0, 1		# r6 = 1
nop
nop
addi $1, $0, 30		# set values that jr should jump to if bypassing is done correctly
addi $2, $0, 30
addi $3, $0, 36
addi $4, $0, 36
nop
nop
bne $1, $2, wrongjr1	# shouldn't branch or be bypassed
jr $1
nop
nop
addi $7, $0, 1		# r7 = 1
wrongjr1: bne $3, $4, wrongjr2	# shouldn't branch or be bypassed
nop
jr $3
nop
nop
addi $8, $0, 1		# r8 = 1
wrongjr2: addi $1, $0, 45		# set values that jr should jump to if bypassing is done correctly
addi $2, $0, 45
addi $3, $0, 51
addi $4, $0, 51
blt $1, $2, wrongjr3	# shouldn't branch or be bypassed
jr $1
nop
nop
addi $9, $0, 1		# r9 = 1
wrongjr3: blt $3, $4, wrongjr4	# shouldn't branch or be bypassed
nop
jr $3
nop
nop
addi $10, $0, 1		# r10 = 1
wrongjr4: addi $1, $0, 175
nop
nop
sw $1, 350($0)
lw $11, 175($1)		# r11 = mem[350] = 175
nop
nop
sw $1, 350($0)
nop
lw $12, 175($1)		# r12 = mem[350] = 175
addi $1, $0, 175	# r1 = 175
addi $2, $0, 350	# r2 = 350
nop
nop
sw $1, 1($0)
sw $2, 2($0)
add $13, $1, $2		# r13 = 525
nop
nop
sw $2, 1($0)
sw $1, 2($0)
add $14, $1, $2		# r14 = 525
nop
nop
sw $1, 1($0)
sw $2, 1($0)
sw $1, 0($2)		# mem[350] = 175
nop
nop
sw $1, 1($0)
sw $2, 1($0)
sw $2, 0($1)		# mem[175] = 350
nop
nop
lw $15, 350($0)		# r15 = 175
lw $16, 175($0)		# r16 = 350
nop
nop
lw $1, 1($0)		# r1 = 350
lw $2, 2($0)		# r2 = 175
add $17, $1, $2		# r17 = 525
nop
nop
addi $1, $0, 0
addi $2, $0, 0
nop
nop
lw $2, 1($0)
lw $1, 2($0)
add $18, $1, $2		# r18 = 525
nop
nop					# tests for NOT bypassing to zero
addi $1, $0, 0		# make sure r1 = 0
addi $19, $0, 1		# non-zero if failing
nop
nop
addi $0, $1, 175	# shouldn't be bypassed
addi $0, $1, 175	# shouldn't be bypassed
add $19, $0, $0		# r19 should be 0, if it isn't zero I'm going to fight god
nop
nop
addi $1, $0, 350	# r1 = 350
addi $2, $0, 350	# r2 = 350
addi $3, $0, 175	# r3 = 175
addi $4, $0, 175	# r4 = 175
nop					# none of the following branches should be taken
nop					# they are there merely to check for improper bypassing
bne $1, $2, dummy	# should not branch
bne $2, $1, dummy	# should not branch
add $20, $1, $2 	# r20 = 700
nop
nop
bne $2, $1, dummy	# should not branch
bne $1, $2, dummy	# should not branch
add $21, $1, $2 	# r21 = 700
nop
nop
addi $1, $0, 350	# make sure these values are still 350
addi $2, $0, 350
nop
nop
blt $1, $2, dummy	# should not branch
blt $2, $1, dummy	# should not branch
add $22, $1, $2 	# r22 = 700
nop
nop
blt $2, $1, dummy	# should not branch
blt $1, $2, dummy	# should not branch
add $23, $1, $2 	# r23 = 700
nop
nop
blt $1, $3, dummy
blt $2, $4, dummy
bne $1, $2, wrongbranch1	# NONE OF THESE BRANCHES SHOULD BE TAKEN
nop
nop
addi $24, $0, 1		# r24 = 1
wrongbranch1: nop
nop
blt $1, $3, dummy
blt $2, $4, dummy
bne $2, $1, wrongbranch2	# SHOULD NOT BRANCH I SWEAR TO GOD
nop
nop
addi $25, $0, 1		# r25 = 1
wrongbranch2: nop
nop
bne $1, $2, dummy
blt $1, $2, wrongbranch3	# NOT YOU EITHER FOR
nop
nop
addi $26, $0, 1		# r26 = 1
wrongbranch3: nop
nop
bne $1, $2, dummy
nop
blt $1, $2, wrongbranch4	# DO NOT DARE
nop
nop
addi $27, $0, 1		# r27 = 1
wrongbranch4: nop
nop
addi $1, $0, 35		# set r1 and r2 to smaller values to test erroneous bypassing
addi $2, $0, 35
nop
nop
bne $1, $2, dummy
blt $2, $1, wrongbranch5	# (╯°□°)╯︵ ┻━┻
nop
nop
addi $28, $0, 1		# r28 = 1
wrongbranch5: nop
nop
bne $1, $2, dummy
nop
blt $2, $1, wrongbranch6	# ┻━┻ ︵╰(°□°╰)
nop
nop
addi $29, $0, 1		# r29 = 1
wrongbranch6: nop
nop
sw $1, 1($0)
sw $2, 2($0)
bne $1, $2, wrongbranch7	# ┬─┬ノ( º _ ºノ)
nop
nop
addi $30, $0, 1		# r30 = 1
wrongbranch7: nop
nop
sw $2, 2($0)
sw $1, 1($0)
bne $1, $2, wrongbranch8	# ┻━┻︵ \(°□°)/ ︵ ┻━┻
nop
nop
addi $31, $0, 1		# r31 = 1
wrongbranch8: nop
nop
sw $1, 1($0)
sw $2, 70($0)
blt $1, $2, wrongbranch9	# ┏━┓┏━┓┏━┓ ︵ /(^.^/)
nop
nop
addi $3, $0, 1		# r3 = 1
wrongbranch9: nop
nop
sw $2, 70($0)
sw $1, 1($0)
blt $1, $2, wrongbranch10	# (╯°Д°)╯︵/(.□ . \)
nop
nop
addi $4, $0, 1		# r4 = 1
wrongbranch10: nop
nop
sw $1, 1($0)
addi $1, $1, 0		# r1 = 35
nop
nop
sw $2, 1($0)
nop
addi $2, $2, 0		# r2 = 35
dummy: nop
nop
nop
