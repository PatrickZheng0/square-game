"""
Creates a zip file for every first-level subdirectory in dir for easy submission to Gradescope

@author Vincent Chen
"""

import os
import zipfile
from helper_scripts.logger import Logger

def zip_recursive(dir):
    # First-level subdirectories
    subdirs = [d for d in os.listdir(dir) if os.path.isdir(os.path.join(dir, d))]
    Logger.info(f"Zipping subdirectories: {', '.join(subdirs)}")

    for subdir in subdirs:
        subdir_path = os.path.normpath(os.path.join(dir, subdir))
        zip_path = os.path.normpath(os.path.join(dir, f"{subdir}.zip"))
        
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(subdir_path):
                # Only include .v files
                v_files = [f for f in files if f.endswith('.v')]
                for file in v_files:
                    file_path = os.path.normpath(os.path.join(root, file))
                    arcname = os.path.relpath(file_path, subdir_path)
                    zipf.write(file_path, arcname)
