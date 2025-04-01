"""
Compiles processors with the given tests.

@author: Vincent Chen
"""

from helper_scripts.logger import Logger
import helper_scripts.default_values as dv
from helper_scripts.html_generator import HTMLGenerator
from helper_scripts.banned_verilog_checker.banned_verilog import VerilogChecker
import subprocess
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

class ProcResult:
    """
    Class representing a processor and its results. 
    """
    html_lock = threading.Lock()
    logger_lock = threading.Lock()

    def __init__(self, name, expected):
        self.name = name
        self.expected = expected
        self.actual = []
        self.failed = []
    
    # TODO: maybe shouldn't be a static function?
    def read_exp(folder):
        """
        Reads the expected results from the given folder.
        """

        file_path = os.path.join(folder, 'exp.txt')
        lines = []

        # Open the file and read lines
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                lines = [line.strip() for line in file.readlines()]
        except FileNotFoundError:
            Logger.warn(f"exp.txt not found for processor in folder {folder}. Defaulting to empty list.")
            return []
        
        # Return the list of lines
        return lines

def file_list(proc_folder, wrapper_path=dv.WRAPPER_PATH):
    """
    Generates FileList.txt using the dedicated Wrapper_tb.v file
    """

    # Get all .v files, excluding Wrapper_tb.v
    verilog_files = []
    for root, _, files in os.walk('.'):
        for file in files:
            if file.endswith('.v') and file != 'Wrapper_tb.v':
                # Use os.path.join for proper path construction
                verilog_files.append(os.path.join(root, file))
    
    # Write the files to FileList.txt
    with open('FileList.txt', 'w', encoding='utf-8') as file:
        for v_file in verilog_files:
            file.write(f'{v_file}\n')
        file.write(f'{wrapper_path}\n')

def get_lines_expected(test_name, folder="test_files"):
    """
    Returns the expected lines for the given test name. Assumes that the expected lines are in the first line of the file and that the file is in {folder}}/verification_files
    """
    file_path = os.path.join('..', '..', folder, 'verification_files', f'{test_name}_exp.txt')
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.readline().strip()
    except FileNotFoundError:
        # current_dir = os.getcwd()
        Logger.error(f"Expected file not found: {file_path} when getting num_cycles")
        # Logger.error(f"Current working directory: {current_dir}")
        # Logger.error(f"Absolute path attempted: {os.path.abspath(file_path)}")
        return ""

def set_up_verilog_checker():
    checker = VerilogChecker()
    checker.add_observer(
        HTMLGenerator.add_content,
        message_type='generate',
        html_friendly=True
    )
    checker.add_observer(
        HTMLGenerator.add_content,
        message_type='banned',
        html_friendly=True
    )
    checker.add_observer(
        callback=lambda title, msg: Logger.warn(msg),
        message_type='generate',
        html_friendly=False
    )
    checker.add_observer(
        callback=lambda title, msg: Logger.warn(msg),
        message_type='banned',
        html_friendly=False
    )

    return checker

def compile_proc(proc_folder, test_name, test_folder="test_files"):
    """
    Compiles the processor in the given folder with the given test name.
    Returns True if the test passes, False otherwise.
    """
    
    # Use locks when accessing shared resources
    with ProcResult.logger_lock:
        Logger.info(f"Compiling processor {proc_folder} with test: {test_name}.")
    
    with ProcResult.html_lock:
        HTMLGenerator.add_content(test_name, get_lines_expected(test_name, test_folder))

    # Create unique output file name for each test
    output_file = f'proc_{test_name}.vvp'
    
    # Use unique output file in compile command
    compile_cmd = f'iverilog -Wimplicit -o {output_file} -c FileList.txt -s Wrapper_tb -P Wrapper_tb.FILE=\\\"{test_name}\\\"'
    compile_process = subprocess.Popen(compile_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    compile_output, compile_error = compile_process.communicate()
    with ProcResult.logger_lock:
        if(compile_output):
            Logger.iverilog(f"Compiler output: \n {compile_output.decode('utf-8')}")
        if compile_error:
            Logger.warn(f"iverilog compilation error: \n{compile_error.decode('utf-8')}")  
            HTMLGenerator.set_state(test_name, 1)
            HTMLGenerator.add_content(test_name, f"==================== Compilation Issues ====================\n{compile_error.decode('utf-8').strip()}")
    
    # Run vvp
    run_cmd = f'vvp {output_file}'
    run_process = subprocess.Popen(run_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    run_output, run_error = run_process.communicate()
    run_output = run_output.decode('utf-8')

    html_result = HTMLGenerator.reformat_results(f"{run_output}", "test_results")
    
    with ProcResult.html_lock:
        HTMLGenerator.add_content(test_name, html_result)
        if not (html_result == "All registers passed!"):
            HTMLGenerator.set_state(test_name, 0)
        elif not (HTMLGenerator.get_state(test_name) == 1):
            HTMLGenerator.set_state(test_name, 2)
    
    with ProcResult.logger_lock:
        Logger.iverilog(f"Simulation output: \n {run_output}")
        if run_error:
            Logger.warn(f"iverilog runtime error: \n {run_error}")
            HTMLGenerator.set_state(test_name, -1)
            HTMLGenerator.add_content(test_name, f"==================== Runtime Errors ====================\n{run_error.decode('utf-8').strip()}")

    # Find result 
    # TODO: maybe better way of doing this? 
    index_finished = run_output.rfind("Finished:")
    if index_finished == -1:
        Logger.warn("Simulation failed to run")
        HTMLGenerator.set_state(test_name, -1)
        return -1
    
    result = run_output[index_finished + len("Finished:")]

    return 1 if (result == 'P') else 0

# FIXME: passing in entire config_data map is unnecessary
def compile_all_procs(tests, procs_folder="example", en_mt=True, wrapper_path=dv.WRAPPER_PATH, test_folder="test_files", config_data=None):
    """
    Compiles all processors in the given folder using parallel execution for tests.
    """

    # Check if procs_folder and tests_folder exist
    if not os.path.exists(procs_folder):
        Logger.error(f"Processor directory '{procs_folder}' does not exist.")
        sys.exit(1)
    if len(tests) == 0:
        Logger.error("No tests to run.")
        sys.exit(1)

    proc_results = []
    original_directory = os.getcwd()

    # Set up banned verilog checker
    banned_verilog_checker = set_up_verilog_checker()

    for proc in os.listdir(procs_folder):
        HTMLGenerator.clear()
        if os.path.isdir(os.path.join(procs_folder, proc)):
            proc_folder = os.path.join(procs_folder, proc)
            current_proc = ProcResult(proc, ProcResult.read_exp(proc_folder))

            # Change directory to proc_folder
            os.chdir(proc_folder)

            # Clear any existing vvp files
            for file in os.listdir():
                if file.endswith('.vvp'):
                    os.remove(file)

            # Generate FileList
            file_list(proc_folder, wrapper_path)

            if config_data.getboolean("PROCESSOR", "EN_VERILOG_CHECK", fallback=False):
                # Initalize banned Verilog block
                Logger.info("Checking for banned Verilog constructs...")
                HTMLGenerator.add_content(VerilogChecker.BANNED_VERILOG_TITLE, "==================== DISCLAIMER ====================\n \nThis automated banned Verilog checker may produce false positives and false negatives. Your final Gradescope submission will be checked manually for banned Verilog constructs. \n \nPlease reference the Checkpoint 4: Processor document for the full list of banned Verilog constructs.")

                failed_check_verilog = banned_verilog_checker.check_verilog(level = 4, show_generate = False)
                HTMLGenerator.set_state(VerilogChecker.BANNED_VERILOG_TITLE, -3 if failed_check_verilog else -2)
                Logger.info("Banned Verilog check complete.")

            if en_mt:
                # Run tests in parallel using ThreadPoolExecutor
                with ThreadPoolExecutor(max_workers=len(tests)) as executor:
                    # Create a list of futures for each test
                    future_to_test = {
                        executor.submit(compile_proc, proc_folder, test, test_folder): test 
                        for test in tests
                    }
                    
                    # Process results as they complete
                    for future in as_completed(future_to_test):
                        test = future_to_test[future]
                        try:
                            res = future.result()
                            if res == 1:
                                current_proc.actual.append(test)
                            elif res == -1:
                                current_proc.failed.append(test)
                        except Exception as e:
                            Logger.error(f"Test {test} generated an exception: {str(e)}")
                            current_proc.failed.append(test)
            else:
                for test in tests:
                    res = compile_proc(proc_folder, test, test_folder)
                    if res == 1:
                        current_proc.actual.append(test)
                    elif res == -1:
                        current_proc.failed.append(test)

            proc_results.append(current_proc)
            
            # Change directory back to original
            os.chdir(original_directory)
            Logger.info(f"Processor {proc} compiled successfully.")

            html_file = HTMLGenerator.generate_html_report(output_dir="html_reports", theme=config_data.get("HTML", "THEME", fallback="LIGHT"), test_folder=test_folder, name=proc, EN_MT=en_mt)
            Logger.info(f"HTML report generated at {html_file}")

    sorted_results = sorted(proc_results, key=lambda x: x.name)
    return sorted_results

if __name__ == "__main__":
    Logger.setup(log_level="INFO", output_destination="TERM")
    procs_folder = 'procs'  
    tests = ["alu_bypass", "alu_double_bypass", "bad"]
    results = compile_all_procs(procs_folder, tests)

    for result in results:
        print(f"Processor: {result.name}")
        print(f"Expected: {result.expected}")
        print(f"Actual: {result.actual}")
        print("--------------------")


