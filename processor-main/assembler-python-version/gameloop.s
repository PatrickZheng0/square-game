main:

_update_player_pos:
    # update box position register
    rand $t3

    # pull data from accelerometer
    upx
    upy

    # scale accel x data
    addi $t0, $zero, 589
    addi $t1, $zero, 511
    addi $t2, $zero, 25
    mul $ax, $ax, $t0
    div $ax, $ax, $t1
    add $px, $ax, $t2

    # scale accel y data
    addi $t0, $zero, 429
    addi $t1, $zero, 511
    mul $ay, $ay, $t0
    div $ay, $ay, $t1
    add $py, $ay, $t2
    
    j _update_player_pos