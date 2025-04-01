"""
Assembles assembly files for the GTKWave lab. Only supports nops, addi, and subi instructions.

@author: Vincent Chen
"""

import os
from helper_scripts.logger import Logger
from helper_scripts.html_generator import HTMLGenerator

def assemble_lab(file_path, canonical_name, asm_dir, mem_dir):

    # Setup output path
    mem_path = os.path.join(mem_dir, canonical_name + '.mem')
    nop = (0 << 14) | (0 << 11) | (0 << 8) | 0  # addi $r0, $r0, 0

    instructions = []
    
    # Read assembly file
    with open(file_path, 'r', encoding='utf-8') as f:
        asm_contents = f.read()
        for line in asm_contents.splitlines():
            # Remove comments and whitespace
            line = line.split('#')[0].strip()
            if not line:
                continue
                
            # Parse instruction
            parts = line.replace(',', ' ').split()
            
            # Handle nop instruction
            if parts[0] == 'nop':
                instructions.append(nop)
                continue
                
            opcode = 0 if parts[0] == 'addi' else 1
            rd = int(parts[1].replace('$r', ''))
            rs = int(parts[2].replace('$r', ''))
            immed = int(parts[3])
            
            # Validate ranges
            if not (0 <= rd <= 7 and 0 <= rs <= 7 and -128 <= immed <= 127):
                raise ValueError(f"Invalid values in instruction: {line}")
                
            # Convert negative immediates to 8-bit two's complement
            if immed < 0:
                immed = immed & 0xFF
                
            # Build 15-bit instruction
            machine_code = (opcode << 14) | (rd << 11) | (rs << 8) | immed
            instructions.append(machine_code)
    
    # Write memory file with padding
    with open(mem_path, 'w', encoding='utf-8') as f:
        # Write actual instructions
        for instr in instructions:
            f.write(f"{instr:015b}\n")
            
        # Pad with NOPs (addi $r0, $r0, 0) up to 100 lines
        for _ in range(len(instructions), 64):
            f.write(f"{nop:015b}\n")
    
    HTMLGenerator.add_content(canonical_name, asm_contents, keep=True, show_line_numbers=True)
    Logger.info(f"Assembly successful for {file_path}. Output written to {mem_path}.")
