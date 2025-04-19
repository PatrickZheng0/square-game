main:
# set target movement counter value
addi $t4, $zero, 15000
# addi $t4, $zero, 2

# initialize target random direction counter value
rand $t7
addi $t8, $zero, 512
sll $t8, $t8, 9
addi $t8, $t8, -1
and $t7, $t7, $t8
add $t7, $t7, $t8
# addi $t7, $zero, 12416
# sll $t7, $t7, 2
# addi $t7, $zero, 4

# initialize box position
addi $bx, $zero, 320
addi $by, $zero, 240

# initialize box speed
addi $bs, $zero, 1

# initialize lives
addi $pl, $zero, 1

_gameloop:
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

    jal check_validity
    
    j _gameloop

_reset_direction_counter:
    # reset counter value
    rand $t7
    addi $t8, $zero, 512
    sll $t8, $t8, 9
    addi $t8, $t8, -1
    and $t7, $t7, $t8
    add $t7, $t7, $t8
    # addi $t7, $zero, 12416
    # sll $t7, $t7, 2
    # addi $t7, $zero, 4

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
    blt $bd, $t5, _decrease_box_pos_y
    addi $t5, $zero, 4
    blt $bd, $t5, _increase_box_pos_y

_reset_movement_counter:
    # reset counter value
    addi $t4, $zero, 15000
    # addi $t4, $zero, 2

    j _gameloop

_increase_box_pos_x:
    addi $t5, $zero, -540
    sub $t6, $zero, $bx # negate bx for blt to work
    blt $t6, $t5, _choose_left # if box too close to edge of screen don't move it more

    add $bx, $bx, $bs
    j _reset_movement_counter

_decrease_box_pos_x:
    addi $t5, $zero, 100
    blt $bx, $t5, _choose_right # if box too close to edge of screen don't move it more

    sub $bx, $bx, $bs
    j _reset_movement_counter

_increase_box_pos_y:
    addi $t5, $zero, -380
    sub $t6, $zero, $by # negate by for blt to work
    blt $t6, $t5, _choose_up # if box too close to edge of screen don't move it more

    add $by, $by, $bs
    j _reset_movement_counter

_decrease_box_pos_y:
    addi $t5, $zero, 100
    blt $by, $t5, _choose_down # if box too close to edge of screen don't move it more

    sub $by, $by, $bs
    j _reset_movement_counter

check_validity: # decrease lives if player box doesn't overlap with target box
    sub $t0, $bx, $px
    sub $t1, $by, $py

    addi $t5, $zero, 10
    addi $t6, $zero, -10

    # check if player box overlaps with target box
    blt $t5, $t0, _out_of_bounds
    blt $t0, $t6, _out_of_bounds
    blt $t5, $t1, _out_of_bounds
    blt $t1, $t6, _out_of_bounds

    jr $ra

    _out_of_bounds:
        addi $pl, $pl, -1
        jr $ra