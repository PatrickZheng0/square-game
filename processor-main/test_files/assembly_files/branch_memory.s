nop             # Comprehensive branching from memory tests
nop             # Tests several memory edge cases
nop             # Author: Vincent Chen
nop             
nop
addi $r1, $r0, 10
addi $r2, $r0, 50
addi $r3, $r0, -10
nop
sw $r1, 5($r0)      # setup: puts 10 into memory address 5
sw $r2, 6($r0)      # setup: puts 45 into memory address 6
sw $r3, 7($r0)      # setup: puts -10 into memory address 6
nop
nop
lw $r4, 5($r0)
bne $r4, $r0, correct
nop
addi $r20, $r0, 1     # missed branch (rd bypassing into bne)
nop
correct: nop
lw $r5, 5($r0)
bne $r0, $r5, correcttwo
nop
addi $r20, $r0, 2     # missed branch (rs bypassing into bne)
nop
correcttwo: nop
lw $r6, 7($r0)
blt $r6, $r0, correctthree
nop
addi $r20, $r0, 4     # missed branch (rd bypassing into blt)
nop
correctthree: nop
lw $r7, 5($r0)
blt $r0, $r7, correctfour
nop
addi $r20, $r0, 8     # missed branch (rs bypassing into blt)
nop
correctfour: nop
lw $r8, 6($r0)
jr $r8
nop
addi $r20, $r20, 16    # missed branch
nop
nop
nop