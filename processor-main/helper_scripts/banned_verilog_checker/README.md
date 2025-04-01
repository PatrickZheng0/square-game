# Overview
This script checks a given directory for instance of banned Verilog. It has a different level of strictness for each of the four checkpoints (ALU, regfile, multdiv, and processor). Lines containing banned Verilog are outputted to the terminal.

DISCLAIMER: This script may produce false positives and false negatives. Your final Gradescope submission will be checked manually for banned Verilog constructs. Check the appropriate checkpoint document for a list of banned Verilog constructs.

# Usage
```
python run.py -d <directory> -l <level> -g <show_genvar>
```

* `<directory>`: the directory containing the Verilog files to check
* `<level>`: the level of strictness to use (1-4)
    - 1: only structural Verilog (ALU checkpoint)
    - 2: shift operator allowed (regfile checkpoint)
    - 3: in-line gates allowed (multdiv checkpoint)
    - 4: non-behavioral Verilog allowed (processor checkpoint)
* `<show_genvar>`: whether to show genvar statements (t/f)

## Example Usage
```
python run.py -d alu -l 1
```
This will check that all Verilog files in the `alu` directory follow the ALU checkpoint restrictions.
```
python run.py -d regfile -l 2
```
This will check that all Verilog files in the `regfile` directory follow the regfile checkpoint restrictions.

```
python run.py -d multdiv -l 3
```
This will check that all Verilog files in the `multdiv` directory follow the multdiv checkpoint restrictions.

```
python run.py -d proc -l 4
```
This will check that all Verilog files in the `proc` directory follow the processor checkpoint restrictions.

# To Do
* Unit testing

# Changelog
* 03-03-2025: initial build 