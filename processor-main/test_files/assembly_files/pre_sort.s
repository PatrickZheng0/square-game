nop 				# Test to make sure eveything works correctly
nop 				# before sort. Passing this test should also 
nop                 # pass sort.
nop 				# Register 10 tracks correct and 20 tracks incorrect
nop 				# Author: Will Denton
nop
addi  $1, $0, 123   # Init values
addi  $2, $0, 124
addi  $3, $0, 122
sw $1, 2($0)        # Init value in memory
nop                 
nop
nop                 # Test 1: lw into bne hazard + bypass
lw $11, 2($0)
bne $11, $0, e1      # Taken
nop
nop
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
e1: nop
addi $r10, $r10, 1  # r10 += 1 (Correct)
nop
nop
nop
lw $12, 2($0)
bne $0, $12, e2      # Taken
nop
nop
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
e2: nop
addi $r10, $r10, 1  # r10 += 1 (Correct)
nop
nop
nop
nop                 # Test 2: lw into blt hazard + bypass
lw $13, 2($0)
blt $13, $2, e3
nop
nop
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
e3: nop
addi $r10, $r10, 1  # r10 += 1 (Correct)
nop
nop
nop
lw $14, 2($0)
blt $3, $14, e4
nop
nop
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
e4: nop
addi $r10, $r10, 1  # r10 += 1 (Correct)
nop
nop
nop

# Final, $r10 should be 4, $r20 should be 0
