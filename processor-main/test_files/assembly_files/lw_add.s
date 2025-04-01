nop            # Specifically tests lw into add
nop            # Author: Philip Xue
nop
nop            # EDGE CASE: Stalling 1 cycle for lw to ALUop
nop            # checking for undefined behavior while stalling
addi $1, $0, 830        # r1 = 830
nop
nop
sw $1, 2($0)         # mem[2] = r1 = 830
lw $4, 2($0)         # r4 = mem[2] = 830
addi $4, $4, 12      # r4 = r4 + 12 = 842    (M->D) 1 cycle stall required
nop                  # r4 should remain 830 while stalling
nop
nop
nop
nop
nop