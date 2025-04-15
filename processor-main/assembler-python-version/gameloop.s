main:

_update_player_pos:
    # update box position register

    # pull data from accelerometer
    upx
    upy

    # scale accel x data
    addi $a0, $zero, 589
    addi $a1, $zero, 511
    addi $a2, $zero, 25
    mul $ax, $ax, $a0
    div $ax, $ax, $a1
    add $px, $ax, $a2

    # scale accel y data
    addi $a0, $zero, 429
    addi $a1, $zero, 511
    mul $ay, $ay, $a0
    div $ay, $ay, $a1
    add $py, $ay, $a2
    
    j _update_player_pos