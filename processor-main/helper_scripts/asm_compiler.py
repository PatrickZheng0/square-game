"""
Calls the Python assembler to compile assembly files. If mode is LAB, it will instead call gtkwave_lab_asm.py.

@author: Vincent Chen
"""

import subprocess
from helper_scripts.logger import Logger
import sys
import os
import shutil
import hashlib  
from helper_scripts.gtkwave_lab_asm import assemble_lab
from helper_scripts.html_generator import HTMLGenerator
import configparser
import concurrent.futures

# FIXME: this global variable is necessary such that asm content still gets added to HTMLGenerator even if not assembling
SHOULD_ASSEMBLE = True

def assemble_all(asm_dir=os.path.join('test_files', 'assembly_files'), mem_dir=os.path.join('test_files', 'mem_files'), filter_files=False, mode="MIPS", act_appendix='', EN_MT=False):
    if not os.path.exists(asm_dir):
        Logger.error(f"Could not find directory '{asm_dir}' for assembly files.")
        sys.exit(1)

    if not os.path.isdir(asm_dir):
        Logger.error(f"'{asm_dir}' is not a directory.")
        sys.exit(1)

    # Create mem dir if it does not exist
    if not os.path.exists(mem_dir):
        os.makedirs(mem_dir)
        Logger.warn(f"'{mem_dir}' did not exist. Directory created.")

    # Clear previous files in mem dir
    if SHOULD_ASSEMBLE:
        for filename in os.listdir(mem_dir):
            file_path = os.path.join(mem_dir, filename)
            try:
                if os.path.isfile(file_path) and file_path.endswith('.mem'):
                    os.remove(file_path)
            except OSError as e:
                Logger.warn(f"Error deleting mem file '{file_path}'. Error: {e}")
    
    if filter_files:
        active_files = get_active_list(asm_dir=asm_dir, appendix=act_appendix)
    else:
        active_files = [f for f in os.listdir(asm_dir) if f.endswith('.s')]

    # MT selection
    if mode == 'LAB' or not EN_MT:
        for filename in active_files:
            path = os.path.join(asm_dir, f"{filename}")
            if not os.path.isfile(path):
                Logger.warn(f"Could not find assembly file '{path}'.")
                HTMLGenerator.add_content(filename, f"Could not find assembly file '{path}'.", keep=True)
                HTMLGenerator.set_state(filename, -1)
                continue

            if mode == 'LAB':
                assemble_lab(file_path=path, canonical_name=os.path.splitext(filename)[0], asm_dir=asm_dir, mem_dir=mem_dir)
            else:
                assemble(file_path=path, canonical_name=os.path.splitext(filename)[0], asm_dir=asm_dir, mem_dir=mem_dir)
    else:
        with concurrent.futures.ThreadPoolExecutor() as executor:
            futures = []
            for filename in active_files:
                path = os.path.join(asm_dir, f"{filename}")
                if not os.path.isfile(path):
                    Logger.warn(f"Could not find assembly file '{path}'.")
                    HTMLGenerator.add_content(filename, f"Could not find assembly file '{path}'.", keep=True)
                    HTMLGenerator.set_state(filename, -1)
                    continue
                
                future = executor.submit(
                    assemble,
                    file_path=path,
                    canonical_name=os.path.splitext(filename)[0],
                    asm_dir=asm_dir,
                    mem_dir=mem_dir
                )
                futures.append(future)
            
            # Wait for all tasks to complete
            concurrent.futures.wait(futures)

def get_active_list(asm_dir=os.path.join('test_files', 'assembly_files'), appendix=''):
    file = os.path.join(asm_dir, f"active_{appendix}.txt")
    if not os.path.exists(file):
        Logger.warn(f"Could not find active assembly file list '{file}'.")
        return []

    lines = []
    with open(file, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    
    trimmed_lines = [line.strip() + ".s" for line in lines]

    if len(trimmed_lines) == 0:
        Logger.warn(f"No active assembly files found in '{file}'.")

    return trimmed_lines


# FIXME: Scuffed fix for people with no Python but infinite Python3
def run_assemble_command(file_path, canonical_name, asm_dir, mem_dir, asm_contents, py_cmd='python'):
    try:
        HTMLGenerator.add_content(canonical_name, asm_contents, keep=True, show_line_numbers=True)
        if SHOULD_ASSEMBLE:
            command = [py_cmd, os.path.join('assembler-python-version', 'assemble.py'), file_path]
            result = subprocess.run(command, capture_output=True, text=True, check=True)
        
            # Move mem file to correct location
            mem_file_path = os.path.join(asm_dir, canonical_name + ".mem")
            moved_to = os.path.join(mem_dir, canonical_name + ".mem")
            shutil.move(mem_file_path, moved_to)

            Logger.info(f"Assembly successful for {file_path}. Output written to {moved_to}.")
        else:
            return
    except subprocess.CalledProcessError as e:
        # Extract out traceback part
        error_text = e.stderr
        if "Exception:" in error_text:
            error_text = error_text.split("Exception:", 1)[1].strip()
        HTMLGenerator.add_content(canonical_name, f"Assembly file failed to compile. Error: {error_text}", keep=True)
        Logger.warn(f"Assembler failed to execute for {file_path}. Error: {error_text}")
        delete_state_file(mem_dir)

def assemble(file_path, canonical_name, asm_dir, mem_dir):
    # Add assembly contents to HTML generator
    with open(file_path, 'r', encoding='utf-8') as f:
        asm_contents = f.read()

    for py_cmd in ['python', 'python3']:
        try:
            run_assemble_command(file_path, canonical_name, asm_dir, mem_dir, asm_contents, py_cmd)
            return  # Success - exit function
        except IOError:
            continue  # Try next command
    
    # If we get here, both commands failed
    HTMLGenerator.add_content(canonical_name, "Mem file failed to write.", keep=True)
    Logger.warn(f"Error writing to memory file for {file_path}.")
    delete_state_file(mem_dir)

def delete_state_file(state_dir):
    state_path = get_state_path(state_dir)
    if os.path.exists(state_path):
        try:
            os.remove(state_path)
            Logger.info(f"Deleted state file '{state_path}'.")
        except OSError as e:
            Logger.warn(f"Failed to delete state file '{state_path}': {e}")
    
def get_state_path(state_dir):
    return os.path.join(state_dir, "state.ini")

def should_assemble(config_data = None, active_files = [], tests_folder="test_files"):
    state_path = get_state_path(os.path.join(tests_folder, "mem_files"))

    # Delete state file if always or never assemble
    if config_data["ASSEMBLER"]["ASM_COMP"] == "ALWAYS" or config_data["ASSEMBLER"]["ASM_COMP"] == "NEVER":
        Logger.info(f"Deleting state file '{state_path}' because ASM_COMP is {config_data['ASSEMBLER']['ASM_COMP']}.")
        delete_state_file(os.path.join(tests_folder, "mem_files"))

        return config_data["ASSEMBLER"]["ASM_COMP"] == "ALWAYS"
    
    # Assume we are now in auto state
    # Hash contents of active assembly files
    hash_obj = hashlib.sha256()
    all_contents = b''
    
    # Read and hash all active files in sorted order
    for filename in sorted(active_files):
        filepath = os.path.join(tests_folder, "assembly_files", f"{filename}.s")
        if os.path.isfile(filepath):
            with open(filepath, 'rb') as f:
                all_contents += f.read()
    
    hash_obj.update(all_contents)
    current_hash = hash_obj.hexdigest()

    if not os.path.exists(state_path):
        Logger.warn(f"Could not find state file '{state_path}'. Defaulting to always assemble.")
        write_state_file(state_path, config_data, current_hash)
        return True

    try:
        # with open(state_path, 'r', encoding='utf-8') as f:
        state_data = configparser.ConfigParser()
        state_data.read(state_path)
            
        # Return True if active file changed or hash doesn't match
        outdated = state_data.get('STATE', 'HASH') != current_hash
        Logger.info(f"Mem files are {'' if outdated else 'not '}outdated.")
        write_state_file(state_path, config_data, current_hash)

        return outdated
    
    except (configparser.Error, IOError) as e:
        Logger.warn(f"Could not parse state file '{state_path}'. Defaulting to always assemble : {e}")
        write_state_file(state_path, config_data, current_hash)
        return True

def write_state_file(state_path, config_data, current_hash):
    # Create a ConfigParser object
    config = configparser.ConfigParser()

    # Add data to the config
    config['STATE'] = {
        'ACTIVE_FILE': config_data["ASSEMBLER"]["ACTIVE_FILE"],
        'HASH': current_hash
    }

    # Write the config to the file
    with open(state_path, 'w') as f:
        config.write(f)


if __name__ == "__main__":
    Logger.setup(log_level="INFO", output_destination="TERM")
    assemble_all()
