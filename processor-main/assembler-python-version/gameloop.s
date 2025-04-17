main:
# set movement counter value
addi $t4, $zero, 12416
# addi $t4, $zero, 2

# initialize random direction counter value
# rand $t7
# addi $t8, $zero, 512
# sll $t8, $t8, 9
# addi $t8, $t8, -1
# and $t7, $t7, $t8
# add $t7, $t7, $t8
addi $t7, $zero, 12416
sll $t7, $t7, 2

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

    # decrease movement counter
    addi $t4, $t4, -1

    # decrease direction counter
    addi $t7, $t7, -1
    
    # check if direction counter is less than 0
    blt $t7, $zero, _change_box_dir

    _after_box_dir:

    # check if movement counter is less than 0
    blt $t4, $zero, _update_box_pos
    
    j _update_player_pos

_reset_direction_counter:
    # # reset counter value
    # rand $t7
    # addi $t8, $zero, 512
    # sll $t8, $t8, 9
    # addi $t8, $t8, -1
    # and $t7, $t7, $t8
    # add $t7, $t7, $t8
    addi $t7, $zero, 12416
    sll $t7, $t7, 2

    j _after_box_dir

_change_box_dir:
    rand $t3
    addi $t5, $zero, 1
    and $t8, $t3, $t5
    addi $t5, $zero, 2
    and $t9, $t3, $t5

    bne $t8, $zero, _choose_x
    j _choose_y

    _choose_x:
        bne $t9, $zero, _choose_right
        j _choose_left
        _choose_right:
            addi $bd, $zero, 0
            j _reset_direction_counter

        _choose_left:
            addi $bd, $zero, 1
            j _reset_direction_counter
    _choose_y:
        bne $t9, $zero, _choose_up
        j _choose_down
        _choose_up:
            addi $bd, $zero, 2
            j _reset_direction_counter

        _choose_down:
            addi $bd, $zero, 3
            j _reset_direction_counter

_update_box_pos:
    # based on direction, change
    addi $t5, $zero, 1
    blt $bd, $t5, _increase_box_pos_x
    addi $t5, $zero, 2
    blt $bd, $t5, _decrease_box_pos_x
    addi $t5, $zero, 3
    blt $bd, $t5, _increase_box_pos_y
    addi $t5, $zero, 4
    blt $bd, $t5, _decrease_box_pos_y

_reset_movement_counter:
    # reset counter value
    addi $t4, $zero, 12416
    #addi $t4, $zero, 2

    j _update_player_pos

_increase_box_pos_x:
    addi $t5, $zero, -540
    sub $t6, $zero, $bx # negate bx for blt to work
    blt $t6, $t5, _decrease_box_pos_x # if box too close to edge of screen don't move it more

    addi $bx, $bx, 1
    j _reset_movement_counter

_decrease_box_pos_x:
    addi $t5, $zero, 100
    blt $bx, $t5, _increase_box_pos_x # if box too close to edge of screen don't move it more

    addi $bx, $bx, -1
    j _reset_movement_counter

_increase_box_pos_y:
    addi $t5, $zero, -380
    sub $t6, $zero, $by # negate by for blt to work
    blt $t6, $t5, _decrease_box_pos_y # if box too close to edge of screen don't move it more

    addi $by, $by, 1
    j _reset_movement_counter

_decrease_box_pos_y:
    addi $t5, $zero, 100
    blt $by, $t5, _increase_box_pos_y # if box too close to edge of screen don't move it more

    addi $by, $by, -1
    j _reset_movement_counter