"""
Exports the results of the tests to a CSV file. Mainly for TAs to test new assembly files.

@author: Vincent Chen
"""

from datetime import datetime
import os
import csv

import helper_scripts.util as util
import helper_scripts.default_values as dv
from helper_scripts.logger import Logger
from helper_scripts.proc_compiler import compile_all_procs

def export_results(proc_results, tests, rolling=False, folder=dv.OUTPUT_DIR):
    """
    Given a list of ProcResults objects, consolidates all results and exports into a CSV file
    """

    if(rolling):
        util.delete_old_folders(folder)

    # Prepare CSV file path
    curr_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_folder = folder + "/" + curr_time
    results_csv = output_folder + "/results.csv"
    diff_csv = output_folder + "/diff.csv"

    if not os.path.exists(folder):
        os.makedirs(folder)
        Logger.warn(f"Output folder '{folder}' does not exist. Creating it now.")

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Prepare CSV header
    fieldnames = ["processor name", "test name", "expected", "actual", "diff"]

    # Write data to CSV file
    with open(results_csv, mode='w', newline='', encoding='utf-8') as res, open(diff_csv, mode='w', newline='', encoding='utf-8') as diff:
        writer = csv.DictWriter(res, fieldnames=fieldnames)
        writer.writeheader()

        diff_writer = csv.DictWriter(diff, fieldnames=fieldnames)
        diff_writer.writeheader()

        # Iterate through ProcResults
        for proc_result in proc_results:
            # Iterate through tests
            for test in tests:
                # Check if test is in expected or actual
                expected_val = 1 if test in proc_result.expected else 0
                actual_val = 1 if test in proc_result.actual else -1 if test in proc_result.failed else 0
                diff_val = actual_val - expected_val

                # Write row to CSV
                writer.writerow({
                    "processor name": proc_result.name,
                    "test name": test,
                    "expected": expected_val,
                    "actual": actual_val,
                    "diff": diff_val
                })

                # Write row to diff CSV if diff_val is not 0
                if diff_val != 0:
                    diff_writer.writerow({
                        "processor name": proc_result.name,
                        "test name": test,
                        "expected": expected_val,
                        "actual": actual_val,
                        "diff": diff_val
                    })

    Logger.info(f"Results exported to '{output_folder}'.")
    # Pretty print to console
    print("\nResults:")
    print("{:<20} {:<20} {:<10} {:<10} {:<10}".format(*fieldnames))
    for proc_result in proc_results:
        for test in tests:

            # FIXME: duplicated code
            expected_val = 1 if test in proc_result.expected else 0
            actual_val = 1 if test in proc_result.actual else -1 if test in proc_result.failed else 0
            diff_val = actual_val - expected_val

            print("{:<20} {:<20} {:<10} {:<10} {:<10}".format(proc_result.name, test, expected_val, actual_val, "\033[91m{}\033[0m".format(diff_val) if diff_val != 0 else "\033[92m{}\033[0m".format(diff_val)))

# Note: duplicated, but for testing only
def get_tests(tests_folder):
    if not os.path.exists(tests_folder):
        Logger.error(f"Memory files directory '{tests_folder}' does not exist.")
        sys.exit(1)    

    tests = []
    for test_file in os.listdir(tests_folder):
        if os.path.isfile(os.path.join(tests_folder, test_file)):
            file_name, file_extension = os.path.splitext(test_file)
            if file_extension == ".mem":
                tests.append(file_name)
    return tests

if __name__ == "__main__":
    Logger.setup(log_level="INFO", output_destination="TERM")
    procs_folder = 'procs'  
    tests_folder = 'test_files/mem_files'
    tests = get_tests(tests_folder)

    proc_results = compile_all_procs(procs_folder, tests)
    export_results(proc_results, tests)