import argparse
import collections
import csv
import os
import sys

# valid instruction types
types = ['R','I','JI','JII']

# expected number of operands for each instruction type
types_exp_operands = {'R':3, 'I':3, 'JI':1, 'JII':1}

# checks if a string represents a valid binary number
def is_bin(n):
	try:
		int(n, 2)
		return True
	except ValueError:
		return False

# checks if a string represents a valid integer
def is_int(n):
	try:
		int(n)
		return True
	except ValueError:
		return False

# converts an instruction split into its parts into binary
def instr_to_bin(instr, line_num):
	mnemonic = instr[0]
	instr_type,opcode,*_ = instrs[mnemonic]
	rd = aliases[instr[1]] if instr_type != 'JI' else None
	rs = aliases[instr[2]] if (instr_type == 'R' or instr_type == 'I') else None
	pre_target = instr[-1]
	if instr_type == 'R':
		sll_or_sra = mnemonic == 'sll' or mnemonic == 'sra'
		shamt = bin(int(instr[3]))[2:].zfill(5) if sll_or_sra else '00000'
		rt = '00000' if sll_or_sra else aliases[instr[3]]
		return f"00000{rd}{rs}{rt}{shamt}{opcode}00\n"
	elif instr_type == 'I':
		bne_or_blt = mnemonic == 'bne' or mnemonic == 'blt'
		imm = bin((labels[instr[3]]-line_num-1 if bne_or_blt else int(instr[3]))&0x1ffff)[2:].zfill(17)
		return f"{opcode}{rd}{rs}{imm}\n"
	elif instr_type == 'JI':
		if pre_target.isdigit():
			target = bin(int(pre_target))[2:].zfill(27)
		else:
			target = bin(labels[pre_target])[2:].zfill(27)
		return f"{opcode}{target}\n"
	else: # instr_type == 'JII'
		return f"{opcode}{rd}0000000000000000000000\n"
	
# checks if CSV entry yields a valid alias
def valid_alias(alias):
	# makes sure each row has 2 entries, first entry is number between 0 and 31, and alias is alphanumeric
	return (len(alias) == 2) and alias[0].isdigit() and (0 <= int(alias[0]) <= 31) and alias[1].isalnum()

# checks if CSV entry yields a valid instruction
def valid_instruction(instr):
	# makes sure each row has 3 entries, second entry is valid instr type, third entry is 5-bit binary
	return (len(instr) == 3) and instr[0].isalpha() and (instr[1] in types) and (len(instr[2]) == 5) and is_bin(instr[2])
	
# checks if provided operands correspond to instruction type
def valid_operands(mnemonic, operands):
	instr_type = instrs[mnemonic][0]
	sll_or_sra = mnemonic == 'sll' or mnemonic == 'sra'
	bne_or_blt = mnemonic == 'bne' or mnemonic == 'blt'
	if len(operands) != types_exp_operands[instr_type]:
		return False
	if instr_type == 'R':
		return (operands[0] in aliases) and (operands[1] in aliases) and ((is_int(operands[2]) and (0 <= int(operands[2]) < 32)) if sll_or_sra else (operands[2] in aliases))
	elif instr_type == 'I':
		return (operands[0] in aliases) and (operands[1] in aliases) and (True if bne_or_blt else (is_int(operands[2]) and (-2**16 <= int(operands[2]) < 2**16)))
	elif instr_type == 'JI':
		if mnemonic == 'setx':
			return operands[0].isdigit() and (int(operands[0]) < 2**27)
		elif operands[0].isdigit():
			return (int(operands[0]) < 2**27)
		return True
	else: # instr_type == 'JII'
		return operands[0] in aliases

invalid_argv = False
parser = argparse.ArgumentParser()
parser.add_argument('input_file', help = "name of the input file")
parser.add_argument('-o', '--output_file', help = "name of the output file")
parser.add_argument('-i', '--instr_file', help = "csv file containing custom instruction definitions")
parser.add_argument('-r', '--alias_file',  help = "csv file containing custom register aliases")

args = parser.parse_args()
input_file = args.input_file
output_file = args.output_file
alias_file = args.alias_file
instr_file = args.instr_file

invalid_argv_exp = ''

if not output_file:
	output_file = input_file[:input_file.rfind('.')] + '.mem'
if not output_file.endswith(".mem"):
	invalid_argv_exp += "assemble.py: error: output file must end with .mem\n"
	invalid_argv = True
if not input_file.endswith(".s"):
	invalid_argv_exp += "assemble.py: error: input file must end with .s\n"
	invalid_argv = True
if alias_file and not alias_file.endswith(".csv"):
	invalid_argv_exp += "assemble.py: error: register alias file must end with .csv\n"
	invalid_argv = True
if instr_file and not instr_file.endswith(".csv"):
	invalid_argv_exp += "assemble.py: error: custom instruction file must end with .csv\n"
	invalid_argv = True
if invalid_argv:
	raise Exception(invalid_argv_exp)

req_files = [f for f in [input_file, alias_file, instr_file] if f]
missing_files = [f for f in req_files if not os.path.isfile(f)]

if missing_files:
	raise Exception(f"Error: missing {', '.join(missing_files)}")

aliases = {'$zero':'00000',
			'$at': '00001',
			'$v0': '00010',
			'$v1': '00011',
			'$a0': '00100',
			'$a1': '00101',
			'$a2': '00110',
			'$a3': '00111',
			'$t0': '01000',
			'$t1': '01001',
			'$t2': '01010',
			'$t3': '01011',
			'$t4': '01100',
			'$t5': '01101',
			'$t6': '01110',
			'$t7': '01111',
			'$s0': '10000',
			'$s1': '10001',
			'$s2': '10010',
			'$s3': '10011',
			'$s4': '10100',
			'$s5': '10101',
			'$s6': '10110',
			'$s7': '10111',
			'$t8': '11000',
			'$t9': '11001',
			'$k0': '11010',
			'$k1': '11011',
			'$gp': '11100',
			'$sp': '11101',
			'$fp': '11110',
			'$ra': '11111'}
			 
# create lookup dictionary for register number to binary
reg_num_lookup = {}
for i in range(32):
	bin_temp = bin(i)[2:].zfill(5)
	reg_num_lookup[str(i)] = bin(i)[2:].zfill(5)
	aliases[f'${i}'] = bin_temp
	aliases[f'$r{i}'] = bin_temp

instrs = {	'nop' : ('R',  '00000'),
			'add' : ('R',  '00000'),
			'sub' : ('R',  '00001'),
			'and' : ('R',  '00010'),
			'or'  : ('R',  '00011'),
			'sll' : ('R',  '00100'),
			'sra' : ('R',  '00101'),
			'mul' : ('R',  '00110'),
			'div' : ('R',  '00111'),
			'j'   : ('JI', '00001'),
			'bne' : ('I',  '00010'),
			'jal' : ('JI', '00011'),
			'jr'  : ('JII','00100'),
			'addi': ('I',  '00101'),
			'blt' : ('I',  '00110'),
			'sw'  : ('I',  '00111'),
			'lw'  : ('I',  '01000'),
			'setx': ('JI', '10101'),
			'bex' : ('JI', '10110')}
instrs_inv = {	'00000R': 'add',
				'00001R': 'sub',
				'00010R': 'and',
				'00011R': 'or' ,
				'00100R': 'sll',
				'00101R': 'sra',
				'00110R': 'mul',
				'00111R': 'div',
				'00001' : 'j'  ,
				'00010' : 'bne',
				'00011' : 'jal',
				'00100' : 'jr' ,
				'00101' : 'addi',
				'00110' : 'blt',
				'00111' : 'sw' ,
				'01000' : 'lw' ,
				'10101' : 'setx',
				'10110' : 'bex'}
bad_aliases = []
conflict_aliases = collections.defaultdict(list)
bad_instrs = []
conflict_instrs = collections.defaultdict(list)

# create dictionary with all register aliases
if alias_file:
	with open(alias_file, newline='') as f:
		registers = csv.reader(f)
		for i,alias in enumerate(registers):
			# check if CSV entry is valid 
			if not valid_alias(alias):
				bad_aliases.append(f"Line {i+1}: {','.join(alias)}\n")
				continue
			reg_pre = '$'+alias[1]
			if reg_pre in aliases:
				conflict_aliases[reg_pre].append(f"Line {i+1}: {','.join(alias)}\n")
			else:
				aliases[reg_pre] = (reg_num_lookup[alias[0]], i+1)

# create dictionary with all instructions
if instr_file:
	with open(instr_file, newline='') as f:
		instructions = csv.reader(f)
		for i,instr in enumerate(instructions):
			# checks if CSV entry is valid, instruction mnemonic doesn't already exist, and opcode is not a duplicate or opcode is duplicate but entries involve an R-type and a non-R-type
			if not valid_instruction(instr):
				bad_instrs.append(f"Line {i+1}: {','.join(instr)}\n")
				continue
			mnemonic,instr_type,opcode = instr
			
			opcode_is_dupe = False
			opcodeR = opcode+'R'*(instr_type == 'R')
			if mnemonic in instrs:
				conflict_instrs[mnemonic].append(f"Line {i+1}: {','.join(instr)}\n")
			if opcodeR in instrs_inv:
				ref_instr_type = instrs[instrs_inv[opcodeR]][0]
				if (instr_type == 'R' and ref_instr_type == 'R') or (instr_type != 'R' and ref_instr_type != 'R'):
					opcode_is_dupe = True
					conflict_instrs[opcodeR].append(f"Line {i+1}: {','.join(instr)}\n")
			if mnemonic not in instrs and not opcode_is_dupe:
				instrs[mnemonic] = (instr_type, opcode, i)
				instrs_inv[opcodeR] = mnemonic
alias_instr_exp = ''
if bad_aliases:
	alias_instr_exp += "Invalid entries detected in registers.csv:\n"
	alias_instr_exp += ''.join(bad_aliases)
	
if conflict_aliases:
	alias_instr_exp += "Conflicting entries detected in registers.csv:\n"
	for k,alias in conflict_aliases.items():
		alias_instr_exp += f"{int(aliases[k][0],2)},{k[1:]}\n"
		alias_instr_exp += ''.join(alias)

if bad_instrs:
	alias_instr_exp += "Invalid entries detected in instructions.csv:\n"
	alias_instr_exp += ''.join(bad_instrs)
	
if conflict_instrs:
	alias_instr_exp += "Conflicting entries detected in instructions.csv:\n"
	for k,instr in conflict_instrs.items():
		mnemonic = instrs_inv[k] if is_bin(k[:5]) else k
		alias_instr_exp += f"{mnemonic},{instrs[mnemonic][0]},{instrs[mnemonic][1]}\n"
		alias_instr_exp += ''.join(instr)

if bad_aliases or bad_instrs or conflict_aliases or conflict_instrs:
	raise Exception(alias_instr_exp)

for alias in sorted(aliases.keys()):
	if len(aliases[alias]) == 2: 
		aliases[alias] = aliases[alias][0]

line_counter = 0
labels = {}
req_labels = collections.defaultdict(list)
assembly_lines = []
invalid_lines = []
invalid_labels = []

with open(input_file, 'r', encoding="utf8") as f:
	for i,line in enumerate(f):
		# get rid of comments
		line_commentless = (line.split('#')[0]).strip()
		# skip empty lines
		if not line_commentless:
			continue
		# see if line starts with label by checking for colon
		instr_parts = line_commentless.partition(':')
		if instr_parts[1]:
			# if label is present, make sure it is alphabetic only
			if instr_parts[0].isdigit():
				invalid_labels.append([line, i])
			labels[instr_parts[0]] = line_counter
		# if line only has label with no instruction, go to next line
		if instr_parts[1] and not instr_parts[2]:
			continue
		# only increment line_counter if line contains instruction
		line_counter += 1
		# find instruction from correct part of partition depending on presence of colon
		instr = (instr_parts[2] if instr_parts[1] else instr_parts[0])
		# isolate mnemonic and make sure mnemonic is in list of instructions
		split_instr = instr.split(None, 1)
		mnemonic = split_instr[0]
		
		if mnemonic not in instrs:
			invalid_lines.append([line,i])
			continue
		# if instruction is nop, replace with functional equivalent
		if mnemonic == "nop" and len(split_instr) == 1:
			assembly_lines.append(['add', '$zero', '$zero', '$zero'])
			continue
		operands = [operand.strip() for operand in split_instr[1].split(',')]
		# convert lw and sw into proper I-type instruction format before validation
		if mnemonic == 'sw' or mnemonic == 'lw':
			imm,lb,reg = operands[-1].partition('(')
			imm = imm.strip()
			reg,_,_ = reg.rpartition(')')
			reg = reg.strip()
			operands[1:2] = [reg, imm]
		if not valid_operands(mnemonic, operands):
			invalid_lines.append([line,i])
			continue
		# keep track of labels required by branch/jump instructions
		if mnemonic == 'bne' or mnemonic == 'blt' or instrs[mnemonic][0] == 'JI' and not operands[-1].isdigit():
			req_labels[operands[-1]].append([line, i])
		assembly_lines.append([mnemonic, *operands])

# print out instructions that are not valid
lines_labels_exp = ''

if invalid_lines:
	lines_labels_exp += "Invalid instructions detected on the following lines:\n"
	for line in invalid_lines:
		lines_labels_exp += f"Line {line[1]}: {line[0]}\n"

missing_labels = []	

# check required labels against existing labels
for label in sorted(req_labels.keys()):
	if label not in labels:
		missing_labels += req_labels[label]

# print out labels that are not alphabetic
if invalid_labels:
	lines_labels_exp += "Invalid numeric labels detected on the following lines:\n"
	for label in invalid_labels:
		lines_labels_exp += f"Line {label[1]}: {label[0]}\n"

# print out instructions that need a label that is missing
if missing_labels:
	lines_labels_exp += "Instructions that branch/jump to a missing label detected on the following lines:\n"
	for line in missing_labels:
		lines_labels_exp += f"Line {line[1]}: {line[0]}\n"

if invalid_lines or invalid_labels or missing_labels:
	raise Exception(lines_labels_exp)
	
if not assembly_lines:
	raise Exception(f"{input_file} is blank. No .mem file generated.")

# convert instructions to binary and write to .mem file
with open(output_file, 'w', newline='\n') as f:
	for line_num,instr in enumerate(assembly_lines):
		f.write(instr_to_bin(instr,line_num))
	for i in range(line_num+1,4096):
		f.write('00000000000000000000000000000000\n')