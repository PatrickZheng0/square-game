"""
Checks code for banned Verilog constructs.

@author: Philip Xue, Vincent Chen
"""

import os
import re
from dataclasses import dataclass
from typing import Callable, List

'''
# absolutely_banned - these should not be in the code at all

absolutely_banned = ['automatic', 'buf', 'bufif0', 'bufif1', 'cell', 'cmos', 'config', 'deassign', 'defparam', 'design', 'disable', 'endconfig', 'endfunction', 'endprimitive', 'endspecify', 'endtable', 'endtask', 'event', 'force', 'forever', 'fork', 'function', 'highz0', 'highz1', 'ifnone', 'incdir', 'include', 'instance', 'join', 'larger', 'liblist', 'library', 'macromodule', 'medium', 'nmos', 'noshow-cancelled', 'notif0', 'notif1', 'pmos', 'primitive', 'pull0', 'pull1', 'pullup', 'pulldown', 'pulsestyle_ondetect', 'pulsestyle_onevent', 'rcmos', 'real', 'realtime', 'release', 'rnmos', 'rpmos', 'rtran', 'rtranif0', 'rtranif1', 'scalared', 'show-cancelled', 'small', 'specify', 'specpa', 'strong0', 'strong1', 'supply0', 'supply1', 'table', 'task', 'time', 'tran', 'tranif0', 'tranif1', 'tri', 'tri0', 'tri1', 'triand', 'trior', 'trireg', 'use', 'vectored', 'wait', 'wand', 'weak0', 'weak1', 'wor']

# banned - these are banned but also likely to be used
banned = ['always', 'case', 'casex', 'casez', 'default', 'edge', 'else', 'endcase', 'if', 'initial', 'integer', 'negedge', 'posedge', 'reg', 'repeat', 'while']

# pay attention to these ones
attention = ['begin', 'end', 'endgenerate', 'for', 'generate', 'genvar', 'inout', 'input', 'localparam', 'output', 'parameter']
'''

'''
# different levels of regex checking

Ban Level:
1 - Only simple structural verilog
2 - Shift operator is allowed for decoder syntax
3 - In-line gates allowed
4 - Non-behavioral verilog allowed
'''

@dataclass
class VerilogObserver:
    callback: Callable
    message_type: str # Can be 'banned', 'generate', or 'all'
    html_friendly: bool

class VerilogChecker:
    # Regular expression patterns for different ban levels
    REGEX_1 = re.compile('[+\-*/%&|^~!<>]|==')
    REGEX_2 = re.compile('[+\-*/%&|^~!]'
                    '|(?<!>)>(?!>)'
                    '|(?<!<)<(?!<)'
                    '|==|>=|<=')
    REGEX_3 = re.compile('[+\-*/%]'
                    '|(?<!>)>(?!>)'
                    '|(?<!<)<(?!<)'
                    '|!=|==|>=|<=')
    REGEX_4 = re.compile('[+\-*/%]'
                    '|(?<!>)>(?!>)'
                    '|(?<!<)<(?!<)'
                    '|>=|<=')
    BANNED_VERILOG_TITLE = "Banned Verilog Check"

    # Regular expression for keyword matching
    REGEX_KEYWORD = re.compile(r'always\s*@'
                    '|always '
                    '|always$'
                    '|case\s*\('
                    '|casex\s*\('
                    '|casez\s*\('
                    '|default\s*:'
                    '|else\s*\('
                    '|else$'
                    '|for\s*\('
                    '|if\s*\('
                    '|if$'
                    '|initial '
                    '|initial$'
                    '|inout\s*\['
                    '|integer '
                    '|reg '
                    '|reg\s*\['
                    '|input reg'
                    '|output reg'
                    '|repeat\('
                    '|while\s*\(')

    # Files to ignore during checking
    IGNORE_LIST = ("_tb.v", "Wrapper.v", "RAM.v", "ROM.v", "dffe_ref.v")

    def __init__(self):
        self.regs = [self.REGEX_1, self.REGEX_2, self.REGEX_3, self.REGEX_4]
        self.observers: List[VerilogObserver] = []

    def add_observer(self, callback: Callable, message_type: str, html_friendly: bool):
        self.observers.append(VerilogObserver(callback, message_type, html_friendly))

    def notify_observers(self, file_name: str, lines: List[str], message_type: str):
        for observer in self.observers:
            if observer.message_type == message_type or observer.message_type == 'all':
                message = self.get_banned_warning(file_name, lines, message_type, observer.html_friendly)
                observer.callback(self.BANNED_VERILOG_TITLE, message)

    def check_string(self, s, level=1):
        """
        Check if string s starts with a certain set of characters or contains banned constructs based on ban level
        """
        return s.startswith(('`', '$')) or self.REGEX_KEYWORD.match(s) or re.search(self.regs[level-1], s)

    def get_banned_warning(self, file_name, lines, type='banned', html_friendly=False):
        """
        Returns a warning string for banned Verilog constructs
        """
        span_start = '<span class="failure">' if html_friendly else ""
        span_end = '</span>' if html_friendly else ""
        message = "Potentially banned syntax" if type == "banned" else "Generate loop(s) detected"
        
        return f'{message} in {span_start}{file_name}{span_end} on the following lines:\n' + '\n'.join(lines) + '\n'

    def process_file(self, f, level=1):
        """
        Processes a Verilog file and returns a tuple of possible genvar lines and banned lines
        """
        comment_block = False
        generate_block = False
        lines_generate = [[]]
        lines_banned = []
        for i, line in enumerate(f):
            line_nopadding = line.strip()
            stripped = (line_nopadding.partition('//'))[0]
            if not stripped:
                continue

            if stripped.startswith('`timescale') or (comment_block and ('*/' not in stripped)):
                continue
            if '*/' in stripped:
                comment_block = False
                stripped = stripped.partition('*/')[2]
            if stripped.startswith('generate') or (generate_block and not stripped.startswith('endgenerate')):
                generate_block = True
                lines_generate[-1].append((line.rstrip()).replace('\t',"    "))
                continue
            if stripped.startswith('endgenerate'):
                lines_generate[-1].append((line.rstrip()).replace('\t',"    "))
                if len(lines_generate[-1]) > 2:
                    lines_generate[-1] = f"{i-len(lines_generate[-1])+1}-{i+1}:\n"+'\n'.join(lines_generate[-1])+'\n'
                    lines_generate.append([])
                else:
                    lines_generate[-1].clear()
                generate_block = False
            
            if '/*' in stripped:
                comment_block = True
                stripped = stripped.partition('/*')[0]
            if stripped.startswith(('input','output','wire')) and (not self.REGEX_KEYWORD.match(stripped)):
                continue
            if self.check_string(stripped, level):
                line_reformat = (line.rstrip()).replace('\t','    ')
                lines_banned.append(f"{i+1}:\t{line_reformat}")

        lines_generate.pop()
        return (lines_generate, lines_banned)

    def check_verilog(self, directory='.',level=1, show_generate=True, use_filelist=True):
        """
        Checks for banned Verilog constructs with varying degrees of strictness
        """

        # FIXME: a little scuffed 
        if use_filelist:
            with open(os.path.join(directory, 'FileList.txt'), 'r', encoding='utf-8') as FileList:
                files = [file.rstrip() for file in FileList]
        else:
            files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.v')]

        failed = False

        for file in files:
            if file.endswith(self.IGNORE_LIST):
                continue

            with open(file, errors='ignore') as f:
                file_name = os.path.basename(file)
                (lines_generate, lines_banned) = self.process_file(f, level)

                if show_generate and lines_generate:
                    self.notify_observers(file_name, lines_generate, 'generate')
                    failed = True

                if lines_banned:
                    self.notify_observers(file_name, lines_banned, 'banned')
                    failed = True

        return failed