main:
# set counter value
addi $t4, $zero, 48828
sll $t4, $t4, 9

addi $bx, $zero, 320
addi $by, $zero, 240

_update_player_pos:
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
    mul $ay, $ay, $t0
    div $ay, $ay, $t1
    add $py, $ay, $t2

    # decrease counter
    addi $t4, $t4, -1
    
    # check if counter is less than 0
    blt $t4, $zero, _update_box_pos
    
    j _update_player_pos

_update_box_pos:
    # get random number
    rand $t3

_update_box_x_pos:
    # bit mask to get least significant bit to control x pos, 1 = move right, 0 = move left
    addi $t5, $zero, 1
    and $t6, $t3, $t5
    bne $t6, $zero, _increase_box_pos_x
    j _decrease_box_pos_x

_update_box_y_pos:
    # bit mask to get second least significant bit to control y pos, 1 = move down, 0 = move up
    addi $t5, $zero, 2
    and $t6, $t3, $t5
    bne $t6, $zero, _increase_box_pos_y
    j _decrease_box_pos_y

_reset_counter:
    # reset counter value
    addi $t4, $zero, 48828
    sll $t4, $t4, 9

    j _update_player_pos

_increase_box_pos_x:
    addi $t5, $zero, -540
    sub $t6, $zero, $bx # negate bx for blt to work
    blt $t6, $t5, _update_box_y_pos # if box too close to edge of screen don't move it more

    addi $bx, $bx, 1
    j _update_box_y_pos

_decrease_box_pos_x:
    addi $t5, $zero, 100
    blt $bx, $t5, _update_box_y_pos # if box too close to edge of screen don't move it more

    addi $bx, $bx, -1
    j _update_box_y_pos

_increase_box_pos_y:
    addi $t5, $zero, -380
    sub $t6, $zero, $by # negate by for blt to work
    blt $t6, $t5, _reset_counter # if box too close to edge of screen don't move it more

    addi $by, $by, 1
    j _reset_counter

_decrease_box_pos_y:
    addi $t5, $zero, 100
    blt $bx, $t5, _reset_counter # if box too close to edge of screen don't move it more

    addi $by, $by, -1
    j _reset_counter