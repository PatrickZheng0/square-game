"""
Main autograder script. Calls helper scripts to compile and test assembly files and processors.

@author: Vincent Chen
"""

import sys
import os
import configparser
import time
from helper_scripts.logger import Logger
import helper_scripts.default_values as dv
import helper_scripts.asm_compiler as asm
import helper_scripts.proc_compiler as proc
import helper_scripts.results_export as rexp
from helper_scripts.html_generator import HTMLGenerator
import helper_scripts.zip as zipp  # rename to avoid conflict with built-in zip function

def read_config(config_file):
    try:
        config_data = configparser.ConfigParser()
        config_data.read(config_file)
        return config_data
    except FileNotFoundError:
        print(f"Error: Config file '{config_file}' not found.")
        sys.exit(1)
    except configparser.Error as e:
        print(f"Error parsing config file: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) > 2:
        print("Usage: python autotester.py <config_file>")
        sys.exit(1)

    config_file = sys.argv[1] if len(sys.argv) == 2 else dv.DEFAULT_CONFIG_FILE

    config_data = read_config(config_file)

    # Logging setup
    try:
        Logger.setup(log_level=config_data["LOGGING"]["LOG_LEVEL"], output_destination=config_data["LOGGING"]["LOG_LOC"], 
            rolling=config_data.getboolean("LOGGING", "LOG_ROLL", fallback=True), folder_path=config_data["LOGGING"]  ["LOG_DIR"])
    except KeyError as e:
        print(f"Missing logging-related key in config file: {e}")
        sys.exit(1)

    Logger.info("Logger setup complete.")
    start_time = time.time()

    # Assemble all files
    # FIXME: Extremely messy
    tests_folder = "gtkwave_lab_test_files" if config_data["ASSEMBLER"]["MODE"] == "LAB" else "test_files"
    active_files = (asm.get_active_list(
        asm_dir= os.path.join(tests_folder, "assembly_files"), 
        appendix=config_data["ASSEMBLER"]["ACTIVE_FILE"]) 
        if config_data.getboolean("ASSEMBLER", "FILT_ASM", fallback=False) else [
            f for f in os.listdir(os.path.join(tests_folder, "assembly_files")) if f.endswith('.s')
        ]
    )
    active_files = [f[:-2] if f.endswith('.s') else f for f in active_files]

    asm.SHOULD_ASSEMBLE = asm.should_assemble(config_data, active_files, tests_folder)            
    try:
        asm.assemble_all(
            asm_dir= os.path.join(tests_folder, "assembly_files"), 
            mem_dir= os.path.join(tests_folder, "mem_files"), 
            filter_files=config_data.getboolean("ASSEMBLER", "FILT_ASM", fallback=False), mode=config_data["ASSEMBLER"]["MODE"], 
            act_appendix=config_data["ASSEMBLER"]["ACTIVE_FILE"],
            EN_MT=config_data.getboolean("ADVANCED", "EN_MT", fallback=False)
        )
    except KeyError as e:
        asm.assemble_all()
        Logger.warn(f"Missing assembler-related key in config file. Using all default values: {e}")

    Logger.info("Assembly file compilation complete.")

    tests = get_tests(os.path.join(tests_folder, "mem_files"), active_files)
    # Compile all processors
    try:
        proc_results = proc.compile_all_procs(procs_folder=config_data["FOLDER_PATHS"]["PROCS"], tests=tests, en_mt=config_data.getboolean("ADVANCED","EN_MT", fallback=False), wrapper_path=dv.L9_WRAPPER_PATH if config_data["ASSEMBLER"]["MODE"] == "LAB" else dv.WRAPPER_PATH, test_folder=tests_folder, config_data=config_data)
    except KeyError as e:
        proc_results = proc.compile_all_procs()
        Logger.warn(f"Unable to find one or more keys for processor compilation. Using all default values: {e}")

    Logger.info("Processor compilation complete.")

    # Export results
    if config_data.getboolean("ADVANCED", "EN_CSV", fallback=False):
        try:
            rexp.export_results(proc_results, tests, rolling = config_data.getboolean("ADVANCED", "OUT_ROLL", fallback=False))
        except KeyError as e:
            rexp.export_results(proc_results, tests)
            Logger.warn(f"Missing OUT_ROLL key in config file. Defaulting to False.")
        
        Logger.info("Results exported.")

    if config_data.getboolean("PROCESSOR", "ZIP", fallback=False):
        try:
            zipp.zip_recursive(dir=config_data["FOLDER_PATHS"]["PROCS"])
        except KeyError as e:
            Logger.warn(f"Unable to find one or more keys for directory compressing: {e}")
    
    if config_data.getboolean("HTML", "AUTO_OPEN", fallback=True):
        HTMLGenerator.open_report() 
        Logger.info("HTML report opened.")

    Logger.info(f"Total time taken: {time.time() - start_time} seconds")
    Logger.close()

def get_tests(tests_folder, active_files=[]):
    if not os.path.exists(tests_folder):
        Logger.error(f"Memory files directory '{tests_folder}' does not exist.")
        sys.exit(1)    

    tests = []
    for test_file in active_files:
        if os.path.isfile(os.path.join(tests_folder, f"{test_file}.mem")):
            tests.append(test_file)
        else:
            Logger.warn(f"Memory file '{test_file}.mem' not found.")
            HTMLGenerator.add_content(test_file, f"Memory file '{test_file}.mem' not found.", keep=True)
            HTMLGenerator.set_state(test_file, -1)
    return tests

if __name__ == "__main__":
    main()
