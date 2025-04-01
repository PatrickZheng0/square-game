# Assembler - Python Version

MIPS assembler completely rewritten in Python. 

## Usage
The most basic form of the command is as follows:

`python assemble.py input_file.s`

This will output a `.mem` file with the same name as the input assembly file.

The complete command is shown below:

Args:  
`
python assemble.py [-o OUTPUT_FILE] [-i INSTR_FILE] [-r ALIAS_FILE] input_file
`

Optional Flags:  
`-o      name of the output file`  
`-i      csv file containing custom instruction definitions`  
`-r      csv file containing custom register aliases`  
### Custom Instructions

Custom instructions should be defined in a .csv file. Each row specifies a single instruction and should match the following format: instruction, type, opcode.

For example:  
`print,J,11000`  
`draw,R,11001`

Note that for R-type instructions, the opcode will instead be the ALU opcode, since all R-type instructions have opcode `00000`.

### Custom Register Aliases

You can define additional register aliases in another .csv file. The first entry of the row should be the register number and the second entry should be the alias.

For example:  
`2,sprite`  
`3,reg3`  
`3,register3`  
`3,three`  

This will set `sprite` to be an alias for register 2 and `reg3`, `register3`, and `three` to be aliases for register 3. Then these aliases can be used in the assembly files in place of the
register number.

`add $three, $sprite, $reg3 <==> add $3, $2, $3`


## Unit Testing
Unit tests for this assembler are located in the `tests` directory. Correct output is verified against the old Go assembler. To run tests, run `./test.sh` in the root directory. To turn off multithreading, run `./test.sh -m off`. You can also run a specific test suite with `./test.sh -t happy` or `./test.sh -t sad`.

