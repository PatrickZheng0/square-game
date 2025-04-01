nop             # Exception testing
nop             # Author: Jack Proudfoot
nop
nop
nop             
addi $r1, $r0, 1        # r1 = 1
sll $r2, $r1, 31        # r2 = -2147483648 (Max negative integer)
sub $r3, $r2, $r1       # sub unfl --> rstatus = 3
nop
nop
add $r20, $r20, $r30    # r20 = 3
nop
nop
addi $r3, $r0, 32767    # r3 = 32767
sll $r3, $r3, 16        # r3 = 2147418112
addi $r3, $r3, 65535    # r3 = 2147483647 (Max positive integer)
add $r4, $r3, $r1       # add ovfl --> rstatus = 1
nop
nop
sll $r20, $r20, 3       # r20 = 24
add $r20, $r20, $r30    # r20 = 25
nop
nop
addi $r4, $r3, 1        # addi ovfl --> rstatus = 2
nop
nop
sll $r20, $r20, 3       # r20 = 200
add $r20, $r20, $r30    # r20 = 202
nop
nop
mul $r4, $r3, $r30     # mul ovfl --> rstatus = 4
nop
add $r21, $r20, $r0     # r21 = 202
sll $r21, $r21, 3       # r21 = 1616
add $r21, $r21, $r30    # r21 = 1620
nop
nop
div $r4, $r3, $r0       # div exception --> rstatus = 5
nop
nop
sll $r21, $r21, 3       # r21 = 12960
add $r21, $r21, $r30    # r21 = 12965
nop
nop
nop
nop