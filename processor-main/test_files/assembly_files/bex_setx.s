
nop 			# simple bex and setx test case
nop 
nop 
nop
nop
setx 0			# r30 = 0
nop			# Avoid setx RAW hazard
nop			# Avoid setx RAW hazard
bex e1			# r30 == 0 --> not taken
nop			# nop in case of flush
nop			# nop in case of flush
nop			# Spacer
addi $r10, $r10, 1	# r10 += 1 (Correct)
e1: nop			# Landing pad for branch
setx 10			# r30 = 10
nop			# Avoid setx RAW hazard
nop			# Avoid setx RAW hazard
bex e2			# r30 != 0 --> taken
nop			# flushed instruction
nop			# flushed instruction
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
e2: 
addi $r10, $r10, 1	# r10 += 1 (Correct)
nop			# Avoid add RAW hazard
nop			# Avoid add RAW hazard
nop

# Final: $r10 should be 2, $r20 should be 0