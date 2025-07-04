main:

_await_button_press:
     diff
     bne $gs, $zero, _initialize_game
     j _await_button_press

_initialize_game:
    # reset score
    addi $ps, $zero, 0
    # set target movement counter value
    addi $t4, $zero, 15000

    # initialize target random direction counter value
    rand $t7
    addi $t8, $zero, 512
    sll $t8, $t8, 9
    addi $t8, $t8, -1
    and $t7, $t7, $t8
    add $t7, $t7, $t8

    # initialize box position
    addi $bx, $zero, 320
    addi $by, $zero, 240

    # initialize player out of bounds timer
    addi $t8, $zero, 512
    sll $ot, $t8, 9

    # initialize difficulty settings
    addi $t0, $zero, 2
    blt $gs, $t0, _set_easy
    addi $t0, $zero, 3
    blt $gs, $t0, _set_medium
    j _set_hard

    _set_easy:
        addi $bs, $zero, 1
        addi $pl, $zero, 9
        j _gameloop
    _set_medium:
        addi $bs, $zero, 2
        addi $pl, $zero, 5
        j _gameloop
    _set_hard:
        addi $bs, $zero, 4
        addi $pl, $zero, 2

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
    j _in_bounds

    _out_of_bounds:
        addi $ot, $ot, -1
        blt $ot, $zero, _decrease_lives
        jr $ra

    _in_bounds:
        # increment score counter
        addi $ps, $ps, 1
        # reset lives counter
        addi $t8, $zero, 512
        sll $ot, $t8, 9
        jr $ra

    _decrease_lives:
        addi $pl, $pl, -1
        
        # reset lives counter
        addi $t8, $zero, 512
        sll $ot, $t8, 9

        # set lives to 0 if it becomes negative
        blt $pl, $zero, _set_lives_to_zero
        jr $ra

        _set_lives_to_zero:
            addi $pl, $zero, 0
            addi $gs, $zero, 0
            j _await_button_press