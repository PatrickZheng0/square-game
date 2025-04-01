nop             # Values initialized using addi (positive only)
nop             # Author: Oliver Rodas
nop
nop
nop             # Bypassing Register 0
addi $0, $0, 12        # r0 = 12 (doesn't write)
addi $1, $0, 3        # r1 = r0 + 3 = 3
add $2, $0, $0        # r2 = r0 + r0 = 0
sub $3, $0, $0        # r3 = r0 - r0 = 0
sw $1, 3($0)         # mem[3] = r1 = 3
lw $0, 3($0)         # r0 = mem[3] (doesn't write)
add $4, $0, $0        # r4 = r0 + r0 = 0
