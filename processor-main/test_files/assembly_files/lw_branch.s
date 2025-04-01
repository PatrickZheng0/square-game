nop            # Miscellaneous lw -> branch tests
nop            # Author: Philip Xue
nop
nop            # EDGE CASE: lw -> lw -> blt
nop            # blt depends on both lw values
addi $1, $0, -350	# r1 = -350
addi $2, $0, -175	# r2 = -175
addi $3, $0, 175	# r3 = 175
addi $4, $0, 350	# r4 = 350
nop
nop
sw $1, 1($0)		# mem[1] = r1 = -350
sw $2, 2($0)		# mem[2] = r2 = -175
sw $3, 3($0)		# mem[3] = r3 = 175
sw $4, 4($0)		# mem[4] = r4 = 350
nop
nop
addi $3, $0, 0		# set to 0
addi $4, $0, 0
nop
nop
lw $4, 4($0)  # r4 = mem[4] = 350
lw $3, 3($0)  # r3 = mem[3] = 175
blt $3, $4, skip1	# branch should be taken
nop
nop
addi $7, $7, 1		# this line should not be reached
skip1:
addi $3, $0, 0		# set to 0
addi $4, $0, 0
nop
nop
lw $4, 3($0)  # r4 = mem[3] = 175
lw $3, 4($0)  # r3 = mem[4] = 350
blt $3, $4, skip2	# branch should not be taken
nop
nop
addi $8, $8, 1		# this line should be reached
skip2:
addi $3, $0, 0		# set to 0
addi $4, $0, 0
nop
nop
lw $3, 1($0)  # r3 = mem[1] = -350
lw $4, 2($0)  # r4 = mem[2] = -175
blt $3, $4, skip3	# branch should be taken
nop
nop
addi $7, $7, 2		# this line should not be reached
skip3:
addi $3, $0, 0		# set to 0
addi $4, $0, 0
nop
nop
lw $3, 2($0)  # r3 = mem[2] = -175
lw $4, 1($0)  # r4 = mem[1] = -350
blt $3, $4, skip4	# branch should not be taken
nop
nop
addi $8, $8, 2		# this line should be reached
skip4:				# r7 should be 0, r8 should be 3
nop					# r7 = 1 means 1st blt wrong, = 2 means 3rd blt wrong, = 3 means both
nop					# r8 = 2 means 2nd blt wrong, = 1 means 4th blt wrong, = 0 means both
addi $1, $0, 350
addi $2, $0, 175
addi $3, $0, 350
addi $4, $0, 175
lw $1, 3($0)		# r1 = mem[3] = 175
bne $1, $2, skip5	# branch should not be taken
addi $9, $0, 1		# should not be flushed
addi $9, $9, 2		# should not be flushed
nop
nop
skip5:
lw $1, 4($0)		# r1 = mem[4] = 350
bne $1, $2, skip6	# branch should be taken
addi $10, $0, 1		# should be flushed
addi $10, $10, 2	# should be flushed
nop
nop
skip6:
lw $4, 4($0)		# r4 = mem[4] = 350
bne $3, $4, skip7	# branch should not be taken
addi $11, $0, 1		# should not be flushed
addi $11, $11, 2	# should not be flushed
nop
nop
skip7:
lw $4, 3($0)		# r4 = mem[3] = 175
bne $3, $4, skip8	# branch should be taken
addi $12, $0, 1		# should be flushed
addi $12, $12, 2	# should be flushed
nop
nop
skip8:				# r9, r11 should be 3
addi $1, $0, 0		# r10, r12 should be 0
addi $2, $0, 0
addi $3, $0, 0
addi $4, $0, 0
