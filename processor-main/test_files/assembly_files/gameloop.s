main:

_update_player_pos:
    # pull data from accelerometer
    upx
    upy

    # scale accel x data
    addi $a0, $zero, 639
    addi $a1, $zero, 511
    mul $ax, $ax, $a0
    div $px, $ax, $a1

    # scale accel y data
    addi $a0, $zero, 479
    addi $a1, $zero, 511
    mul $ay, $ay, $a0
    div $py, $ay, $a1

    j _update_player_pos