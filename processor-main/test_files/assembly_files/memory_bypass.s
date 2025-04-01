nop             # Values initialized using addi (positive only)
nop             # Author: Oliver Rodas
nop
nop
nop             # Basic Bypassing to Memory
addi $1, $0, 12        # r1 = 12
sw $1, 1($0)        # mem[1] = r1 = 12        (X->D)
addi $2, $0, 14        # r2 = 14
addi $3, $0, 51        # r3 = 51
sw $3, 0($2)         # mem[r2] = r3 = 51        (X->D and M->D)
lw $4, 1($0)        # r4 = mem[1] = 12
lw $5, 0($2)        # r5 = mem[r2] = 51
