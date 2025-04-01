# Assembly File Autotester
## Overview 
This repository provides an automated, local way to test your ECE 350 processor against various assembly files. This repository also contains the documents needed for the GTKWave Lab.

## Setup
**Note:** At each step, you may need to restart your terminal session to see the changes.
1. For Windows users, install Git Bash [here](https://git-scm.com/downloads/win)
   - Verify you have Git Bash installed by launching the application through the Start Menu or through an application like VSCode
   - Going forward, **only** use Git Bash 
2. Install Icarus Verilog and GTKWave by following the guide [here](https://docs.google.com/document/d/1RaLEdjCxocIHsXdHlYIY3IXyU-FsCGMA046p8uV3ypU/edit?usp=drive_link)
   - Check you have Icarus Verilog installed by running `iverilog -V` in your terminal
   - Check you have GTKWave installed by running `gtkwave` and verifying the application opens
3. Install Python 3.9.13 or later [here](https://www.python.org/downloads/)
   - Check you have Python installed by running `python --version`
4. Install pip [here](https://pip.pypa.io/en/stable/installation/)
   - Check you have pip installed by running `pip --version`
5. Install required packages by running `pip install -r requirements.txt`

## Updating the Autotester 
### From a Forked Repo (Recommended)
1. Run `git remote add upstream https://github.com/ece350TA/proc-toolchain.git` to add the original repository as an upstream remote.
2. Run `git fetch upstream` to pull new changes from the original repository.
3. Run `git merge upstream/main` to merge the changes into your local main branch.

**NOTE:** If the automatic merge in step 3 fails and you get a merge conflict (e.g., you edited one of the Python files), come to office hours for help. 

### From a Cloned Repo
1. Run `git pull --no-rebase` to pull new changes from the remote repository.
2. This may pull up a merge conflict editor. Type `:wq` and then press `Enter` to save and quit. 

**NOTE:** If the automatic merge in step 2 fails and you get a merge conflict (e.g., you edited one of the Python files), come to office hours for help. 


## Usage
1. Place your processor source files in the `main/proc` directory.
2. Run `python autotester.py`
    - You may also specify a different configuration file by running `python autotester.py <config_file>`.
3. Your test results will be saved in the `html_reports` directory.

## Output
The autotester will generate an HTML report that mimics Gradescope output to the `html_reports` directory. This file will automatically open in your default browser. Each block in the HTML report represents a single test case and will show the following information:
* Assembly file contents
* Number of cycles
* Icarus Verilog warnings or errors (if applicable)
* Expected output vs. actual output


Each block is color coded to indicate the test result:
* Green: All registers match expected output
* Orange: Test passed but iverilog warnings were present
* Red: One or more registers do not match expected output
* Gray: Test failed to run

**Note**: If the code hangs when running the tests, this is likely because you have a combinational loop in your processor that needs to be removed. For example:
```verilog
assign a = b ? c : d; // a relies on b
assign b = a ? a : c; // but b also relies on a
```
You can exit the run by pressing `Ctrl+C` in the terminal.


## Adding New Tests
1. Place the assembly files to test in the `test_files/assembly_files` directory and their expected files in the `test_files/verification_files` directory. Refer to the "File Structure" section of the Checkpoint 4: Processor document for instructions on formatting the expected output files, or you can use any of the provided expected files as a reference.
2. Update the `active_{ACTIVE_FILE}.txt` file to include the new tests if needed.

## Manual Testing
If you are running into issues with the autotester, you can manually compile and test your processor with the following commands:
### Assembly
1. Place your assembly files in the `test_files/assembly_files` directory.
2. Place your expected output files in the `test_files/verification_files` directory.
3. From the root directory, run `python assembler-python-version/assemble.py test_files/assembly_files/<asm_file_name>.s`
4. This command will output a .mem file to the `test_files/assembly_files` directory. Move the mem file to the `test_files/mem_files` directory.
### FileList
1. Copy `test_files/Wrapper_tb.v` to the `main/proc` directory.
2. In your terminal, change directory into `main/proc`
3. On Mac/Linux, run `find . -name "*.v" > FileList.txt`
3. On Windows cmd prompt, run `dir /s /b *.v > FileList.txt`
3. On Windows PowerShell, run `Get-ChildItem -Recurse -Name -Filter *.v | Out-File -FilePath FileList.txt -Encoding Ascii`
### Verilog Compilation
1. In your terminal, run `iverilog -Wimplicit -o proc.vvp -c FileList.txt -s Wrapper_tb -P Wrapper_tb.FILE=\"test_name\"`
2. Run `vvp proc.vvp`
   - Failed registers will be displayed in the terminal, and an output of `Finished:P` means that all registers passed.
   - If you are on Windows PowerShell, you may need to escape your file like this: `-P 't.FILE_NAME=""""r2.hex""""'`
3. To open the GTKWave file, run `gtkwave ../../test_files/output_files/test_name.vcd`

## Important Parameters
The `config.ini` configuration file provides numerous options for the autotester. The most important are:
* `PROCS`: The folder containing the processor files. This is provided as `main` by default and all of your processor files should go into `main/proc`. 
* `FILT_ASM`: Enables filtering of the `test_files/assembly_files` directory. If set to `True`, only files listed in the `active_{ACTIVE_FILE}.txt` file are tested. 
* `ACTIVE_FILE`: The file containing the assembly files you want to test against. These files can be found in `test_files/assembly_files`. By defalt, there are three premade options for each of the Gradescope checkpoints: `baby`, `hazardous`, and `final`. 
* `EN_MT`: This enables multithreading. If you run into issues, try setting this to `False`. 

## All Parameters
### Assembler
* `FILT_ASM`: Enables filtering of the `test_files/assembly_files` directory. If set to `True`, only files listed in the `active_{ACTIVE_FILE}.txt` file are tested. 
* `ACTIVE_FILE`: The file containing the assembly files you want to test against. These files can be found in `test_files/assembly_files`. By defalt, there are three premade options for each of the Gradescope checkpoints: `baby`, `hazardous`, and `final`. 
* `ASM_COMP`: If set to `ALWAYS`, the assembler will always be run. If set to `NEVER`, the assembler will never be run. If set to `AUTO`, the assembler will only be run if detects any changes to the active assembly files.
* `MODE`: The mode of the assembler. This can either be `MIPS` for the standard processor or `LAB` for the modified lab processor.

### Processor
* `EN_VERILOG_CHECK`: If set to `True`, the banned Verilog checker will be run. Please note that this checker may produce false positives and false negatives. Your final Gradescope submission will be checked manually for banned Verilog constructs. Refer to the Checkpoint 4: Processor document for the full list of banned Verilog constructs.
* `ZIP`: If set to `True`, one zip file will be made for every first-level subdirectory in `PROCS`. Only `.v` files will be included in the zip files. This facilitates Gradescope submission.  

### Logging
* `LOG_LEVEL`: The level of logging to use. By default, this is set to `INFO`.
    * `INFO`: logs completion of each step, and everything below.
    * `IVERILOG`: logs all iverilog output from processor compilation, and everything below.
    * `WARN`: logs recoverable errors (e.g., failed processor compilation), and everything below.
    * `ERROR`: logs unrecoverable errors (e.g., missing assembly files).
    * `NONE`: logs nothing.
* `LOG_LOC`: The location to output the log. This can be either `TERM` for console output or `FILE` for file output. 
* `LOG_DIR`: If `LOG_LOC` is set to `FILE`, this is where the log files are saved. 
* `LOG_ROLL`: Enables rolling log files. If set to `True`, only the five most recent files are kept in `LOG_DIR`.

### HTML
* `THEME`: The default theme for the HTML web page. This can either be `LIGHT` or `DARK`.
* `AUTO_OPEN`: If set to `True`, the HTML web page will automatically open in your default browser once the tests are complete.

### Advanced
* `EN_CSV`: Enables CSV output against expected processor performance. Mainly for TA use. 
* `OUT_ROLL`: Enables rolling CSV output files. If set to `True`, only the five most recent files are kept in the `output` directory.
* `EN_MT`: This enables multithreading. If you run into issues, try setting this to `False`.