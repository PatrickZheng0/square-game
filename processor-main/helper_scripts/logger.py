"""
Logging class that manages logging location and logging levels. 

@author: Vincent Chen
"""

from datetime import datetime
import os

import helper_scripts.util as util
import helper_scripts.default_values as dv

class Logger:
    """
    Logging class that logs messages to the terminal or a file.
    """

    priority_dict = {"INFO": 0, "IVERILOG": 10, "WARN": 20, "ERROR": 30, "NONE": 5000}
    message_buffer = ""

    @staticmethod
    def setup(log_level="INFO", output_destination="TERM", rolling=False, folder_path=dv.LOG_DIR):
        Logger.log_level = Logger.priority_dict[log_level.upper()]
        Logger.output_destination = output_destination.upper()
        
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        curr_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    
        if(Logger.output_destination == "FILE"):
            if(rolling):
                util.delete_old_files(folder_path)

            # Construct file name with today's date
            Logger.file_path = os.path.join(folder_path, f"log_{curr_time}.txt")

            # Create the file
            with open(Logger.file_path, 'w', encoding='utf-8') as file:
                file.write("Log output for run at " + curr_time + "\n")        

    @staticmethod
    def info(message):
        if Logger.log_level <= Logger.priority_dict["INFO"]:
            Logger._output_message("INFO", message)
    
    @staticmethod
    def iverilog(message):
        if Logger.log_level <= Logger.priority_dict["IVERILOG"]:
            Logger._output_message("IVERILOG", message)
        
    @staticmethod
    def warn(message):
        if Logger.log_level <= Logger.priority_dict["WARN"]:
            Logger._output_message("WARN", message)

    @staticmethod
    def error(message):
        if Logger.log_level <= Logger.priority_dict["ERROR"]:
            Logger._output_message("ERROR", message)

    @staticmethod
    def _output_message(level, message):
        formatted_message = f"[{level}] {message}"
        if Logger.output_destination == "TERM":
            print(formatted_message)
        elif Logger.output_destination == "FILE":
            if Logger.file_path:
                Logger.message_buffer += formatted_message + "\n"
            else:
                raise ValueError("File path must be provided for file output.")
        else:
            raise ValueError("Invalid output destination. Choose 'TERM' or 'FILE'.")

    # FIXME: somewhat scuffed solution
    @staticmethod
    def close():
        if(Logger.output_destination == "FILE"):
            with open(Logger.file_path, "a", encoding='utf-8') as file:
                file.write(Logger.message_buffer)
# Example usage:
if __name__ == "__main__":
    Logger.setup(log_level="INFO", output_destination="FILE")
    Logger.info("This is an information message")
    Logger.iverilog("This is iverilog output")
    Logger.warn("This is a warning message")
    Logger.error("This is an error message")
