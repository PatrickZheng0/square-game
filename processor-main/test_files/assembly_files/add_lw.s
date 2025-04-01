nop            # Specifically tests add into lw
nop            # Author: Philip Xue
nop
nop            # EDGE CASE: bypassing ALU result to address calculation for lw
nop
addi $1, $0, 830        # r1 = 830
nop
nop
sw $1, 4($0)         # mem[4] = r1 = 830
addi $2, $0, 2       # r2 = 2
lw $3, 2($2)         # r3 = mem[2+r2] = mem[2+2] = mem[4] = 830
nop
nop
add $4, $2, $0       # r4 = 2
lw $5, 2($4)         # r5 = mem[2+r4] = mem[2+2] = mem[4] = 830
nop
nop
