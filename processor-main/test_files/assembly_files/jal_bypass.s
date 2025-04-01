nop             # jal bypass
nop             # Tests jal bypassing
nop             # Author: Vincent Chen
nop             
nop
jal main
nop
nop
main: sw $r31, 5($r0)
nop
nop
lw $r1, 5($r0)                 # r1 should be 6
nop
nop
addi $r31, $r0, 0
nop
nop
jal maintwo
nop
nop
maintwo: addi $r2, $r31, 0     #r2 should be 18
nop
nop
addi $r31, $r0, 0
nop
nop
jal mainthree
nop
nop
mainthree:
bne $r31, $r0, end  
nop
addi $r3, $r0, 1               # incorrect branch
nop
end:                          
addi $r3, $r3, 1               # r3 should be 1
nop
nop         