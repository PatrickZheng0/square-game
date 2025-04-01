				# Efficiency Test 2: JAL into JR
nop
nop 	
nop
nop	
nop
addi $r31, $r0, 14		# r31 = 32
nop				# Avoid RAW hazard for jr
jal j1				# jal to jr (with RAW hazard)
nop				# Spacer
nop				# Spacer
j end1				# Jump to test cleanup
nop				# Spacer
nop				# Spacer
j1: jr $r31 			# jr immediately after jal
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
end1: nop			# Landing pad for jump
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 0
and $r20, $r0, $r20		# r20 should be 0
nop
nop
nop
nop

# Final: $r10 should be 0, $r20 should be 0
