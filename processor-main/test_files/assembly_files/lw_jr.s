nop            # Specifically tests lw into jr
nop            # Author: Philip Xue
nop
nop            # EDGE CASE: bypassing from lw -> jr
nop            # checks if the value of lw is being bypassed, not the address
addi $1, $0, 10        # r1 = 10
addi $4, $0, 11        # r4 = 11
nop
sw $1, 12($0)         # mem[12] = r1 = 10
lw $4, 12($0)         # r4 = mem[12] = 10
jr $4          # This is line 10: the program should get stuck here
nop
nop
addi $2, $0, 1 # This line should never be reached
