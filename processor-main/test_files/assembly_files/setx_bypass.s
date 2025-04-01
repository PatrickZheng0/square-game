nop             # setx bypassing test
nop             # tests incorrect and correct branching of bex if a setx happens right before
nop             # Author: Vincent Chen
nop             
nop
setx 5        
bex correct
incorrect:
nop
nop
nop
addi $r1, $r0, 10   # bex not taken, incorrect
nop
correct:
nop
setx 10
setx 0
bex incorrecttwo    # bex taken, incorrect
correct:  
nop
j next
nop
incorrecttwo:          
addi $r1, $r1, 100  
nop
nop
next:
setx 5        
bex end
addi $r1, $r1, 1000     # test flushing after bex
end:                # r1=0      [Correct]
nop                 # r1=xx10   [Failed taken case]
nop                 # r1=x100   [Failed not taken case]
nop                 # r1=1000   [Failed flushing case]