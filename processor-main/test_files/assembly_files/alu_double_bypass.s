nop             # Values initialized using addi (positive only)
nop             # Author: Oliver Rodas
nop
nop
nop             # Bypassing 2 values to ALU
addi $r1, $r0, 37        # r1 = 37
addi $r2, $r0, 41        # r2 = 41
sub $r3, $r2, $r1        # r3 = r2 - r1 = 4        (X->D and M->D)
sub $r4, $r2, $r3        # r4 = r2 - r3 = 37        (X->D and M->D)
