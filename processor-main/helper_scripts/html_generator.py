"""
Generates HTML reports summarizing the results of the tests. 

@author: Vincent Chen
"""

from datetime import datetime
import json
import os
from helper_scripts.reformat import *
import random
from helper_scripts.logger import Logger
from helper_scripts.util import get_version
class HTMLContent:
    def __init__(self, title):
        self.title = title
        self.content_blocks = []
        self.state = 2  
        # FIXME: convert self.state to enum
        """
        HTMLContent objects are shown in order of state, then alphabetically by title
        
        State:
        -3: Failed banned Verilog
        -2: Passed banned Verilog
        -1: Not run - show title in gray and no GTKWave button
        0: Failed test - show title in red and all content
        1: Passed with warnings
        2: Passed test - show title in green and no content
        """
    
    # TODO: formalize state machine for transition rules between states. Not all states reset on a new processor because .s files only compile once per processor. This only affects TA usage and not student usage. 
    def reset_state(self):
        if self.state != -1:
            self.state = 2
    
    def to_dict(self):
        """JSON serialization"""
        return {
            'title': self.title,
            'state': self.state,
            'content_blocks': [block.to_dict() for block in self.content_blocks]
        }
    
    def equals(self, other):
        if self.title != other.title or self.state != other.state:
            return False

    def equals(self, other):
        if self.title != other.title or self.state != other.state:
            return False
            
        self_blocks = sorted(self.content_blocks, key=lambda x: x.text)
        other_blocks = sorted(other.content_blocks, key=lambda x: x.text)
        
        if len(self_blocks) != len(other_blocks):
            return False
            
        for self_block, other_block in zip(self_blocks, other_blocks):
            if not self_block.equals(other_block):
                return False
                
        return True
    
    @classmethod
    def from_dict(cls, data):
        """JSON deserialization"""
        content = cls(data['title'])
        content.state = data['state']
        content.content_blocks = [ContentBlock.from_dict(block) for block in data['content_blocks']]
        return content

    def __str__(self):
        return f"HTMLContent(title='{self.title}', state={self.state}, blocks={self.content_blocks})"
    
    def __repr__(self):
        return self.__str__()

class ContentBlock:
    def __init__(self, text, keep=False, show_line_numbers=False):
        self.text = text
        self.keep = keep  # keep across clears
        self.show_line_numbers = show_line_numbers

    def to_dict(self):
        """JSON serialization"""
        return {
            'text': self.text,
            'keep': self.keep,
            'show_line_numbers': self.show_line_numbers
        }
    
    def equals(self, other):
        return self.text == other.text and self.keep == other.keep and self.show_line_numbers == other.show_line_numbers
    
    @classmethod
    def from_dict(cls, data):
        """JSON deserialization"""
        return cls(data['text'], data['keep'], data['show_line_numbers'] if 'show_line_numbers' in data else False)

    def __str__(self):
        # Truncate text to 50 characters
        preview = self.text[:50] + "..." if len(self.text) > 50 else self.text
        # Replace newlines with \n for better readability
        preview = preview.replace('\n', '\\n')
        return f"ContentBlock(text='{preview}', keep={self.keep}, show_line_numbers={self.show_line_numbers})"
    
    def __repr__(self):
        return self.__str__()

class HTMLGenerator:
    _content_map = {}  # Static map of title -> HTMLContent object
    _output_file = None  # Static variable to store the output file path

    # Extract light mode colors so they're easier to finetune
    red_lm = "#f03d30"
    green_lm = "#23a645"

    @classmethod
    def add_content(cls, title, text, keep=False, show_line_numbers=False):
        """Add content block to be included in the HTML report
        Args:
            title (str): The test name/title for this content block
            text (str): The content text to add
        """
        if not text.strip():
            return
        
        if title not in cls._content_map:
            cls._content_map[title] = HTMLContent(title)
        
        cls._content_map[title].content_blocks.append(ContentBlock(text, keep, show_line_numbers))

    @classmethod
    def set_state(cls, title, state):
        """Set the state of a specific HTMLContent object
        Args:
            title (str): The title/key of the content to update
            state (int): The new state value
        """
        if title in cls._content_map:
            cls._content_map[title].state = state

    @classmethod
    def get_state(cls, title):
        """Get the state of a specific HTMLContent object
        Args:
            title (str): The title/key of the content to get
        """
        return cls._content_map[title].state
    
    @classmethod
    def generate_html_report(cls, output_dir, theme="LIGHT", test_folder="test_files", name="proc", EN_MT=False):
        """Generate HTML report from the content map"""
        time_saved = round(random.uniform(8.73, 114.29) * (random.uniform(1.01, 1.25) if EN_MT else 1), 2) 
        
        # Set initial theme based on config
        initial_theme_class = "dark-mode" if theme.upper() == "DARK" else ""
        initial_button_text = "☀️ Light Mode" if theme.upper() == "DARK" else "🌙 Dark Mode"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test Results</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .section {{ margin: 20px 0; padding: 10px; border: 1px solid #eee; border-radius: 8px; }}
                .header {{ 
                    background-color: #f5f5f5; 
                    padding: 10px; 
                    display: flex;
                    align-items: center;
                    cursor: pointer;
                    user-select: none;
                    -webkit-user-select: none;
                    -moz-user-select: none;
                    -ms-user-select: none;
                    flex-wrap: wrap;
                    gap: 10px;
                    border-radius: 8px;
                }}
                .header span {{ 
                    font-size: 1.2em;
                    font-weight: bold;
                    margin-left: 3px;
                    margin-right: 30px;
                }}
                .success {{ color: {cls.green_lm}; }}
                .failure {{ color: {cls.red_lm}; }}
                .warning {{ color: #FF9500; }}
                .not-run {{ color: #BBBBBB; }}
                .toc-link.success {{ color: {cls.green_lm}; }}
                .toc-link.failure {{ color: {cls.red_lm}; }}
                .toc-link.warning {{ color: #FF9500; }}
                .toc-link.not-run {{ color: #BBBBBB; }}
                .content-block {{ margin: 10px 0; padding: 10px; background-color: #f9f9f9; border-radius: 8px; }}
                .content-block:last-child {{
                    margin-bottom: 0;  /* Removes bottom margin from last content block */
                }}
                .content-block div {{ 
                    white-space: pre-wrap;
                    font-family: monospace;
                    tab-size: 5;
                    -moz-tab-size: 5;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }}
                .collapse-btn {{
                    cursor: pointer;
                    border: none;
                    background: none;
                    font-size: 1.2em;
                    padding: 0 10px;
                    color: inherit;
                    user-select: none;
                    -webkit-user-select: none;
                    -moz-user-select: none;
                    -ms-user-select: none;
                }}
                .content-container {{
                    display: block;
                }}
                .content-container.collapsed {{
                    display: none;
                }}
                .description {{
                    color: #666;
                    font-style: italic;
                    margin-bottom: 20px;
                    margin-left: 3px;
                }}
                .theme-toggle {{
                    flex: 1;
                    padding: 10px 20px;
                    background-color: #017AFF;
                    color: white;
                    border: none;
                    border-radius: 5px;
                    cursor: pointer;
                    box-shadow: 2px 2px 5px rgba(0,0,0,0.2);
                    z-index: 1000;
                }}
                .float-button {{
                    flex: 1;
                    padding: 10px 20px;
                    background-color: #017AFF;
                    color: white;
                    border: none;
                    border-radius: 5px;
                    cursor: pointer;
                    box-shadow: 2px 2px 5px rgba(0,0,0,0.2);
                }}
                /* Add dark mode styles */
                body.dark-mode {{ 
                    background-color: #1a1a1a; 
                    color: #ffffff; 
                }}
                body.dark-mode .section {{ 
                    border-color: #444; 
                }}
                body.dark-mode .header {{ 
                    background-color: #2d2d2d; 
                }}
                body.dark-mode .content-block {{ 
                    background-color: #2d2d2d; 
                }}
                body.dark-mode .failure {{ 
                    color: #FF443B;  
                }}
                body.dark-mode .success {{ 
                    color: #32D84C; 
                }}
                body.dark-mode .description {{ 
                    color: #e1e1e1; /* match title color */
                }}
                body.dark-mode .not-run {{ 
                    color: #777777; 
                }}
                .copy-button {{
                    padding: 5px 10px;
                    color: white;
                    border: none;
                    border-radius: 3px;
                    cursor: pointer;
                    margin-left: 0px;
                    user-select: none;
                    -webkit-user-select: none;
                    -moz-user-select: none;
                    -ms-user-select: none;
                }}
                .copy-button.success {{
                    background-color: {cls.green_lm};
                    color: white;
                }}
                .copy-button.success:hover {{
                    background-color: #45d86c;
                    color: white;
                }}
                .copy-button.failure {{
                    background-color: {cls.red_lm};
                    color: white;
                }}
                .copy-button.failure:hover {{
                    background-color: #ff524a;
                    color: white;
                }}
                body.dark-mode .copy-button.success {{
                    background-color: #28b040;
                    color: #ffffff;
                }}
                body.dark-mode .copy-button.success:hover {{
                    background-color: #32c94c;
                    color: #ffffff;
                }}
                body.dark-mode .copy-button.failure {{
                    background-color: #FF443B;
                    color: #ffffff;
                }}
                body.dark-mode .copy-button.failure:hover {{
                    background-color: #ff5a52;
                    color: #ffffff;
                }}
                .copy-button.warning {{
                    background-color: #FF9500;
                    color: white;
                }}
                .copy-button.warning:hover {{
                    background-color: #ffaa33;
                    color: white;
                }}
                body.dark-mode .copy-button.warning {{
                    background-color: #FF9500;
                    color: #ffffff;
                }}
                body.dark-mode .copy-button.warning:hover {{
                    background-color: #ffaa33;
                    color: #ffffff;
                }}
                /* Add new sidebar styles */
                .sidebar {{
                    position: fixed;
                    right: 20px;
                    top: 80px;
                    width: 250px;
                    padding: 20px;
                    background-color: #f5f5f5;
                    border-radius: 8px;
                    max-height: calc(100vh - 140px);
                    overflow-y: auto;
                    z-index: 999;
                }}
                body.dark-mode .sidebar {{
                    background-color: #2d2d2d;
                }}
                .sidebar-title {{
                    font-weight: bold;
                    margin-bottom: 10px;
                }}
                .toc-link {{
                    display: block;
                    padding: 5px 0;
                    text-decoration: none;
                    color: inherit;
                }}
                .toc-link:hover {{
                    text-decoration: underline;
                }}
                .main-content {{
                    margin-right: 300px;
                    margin-top: 20px;
                }}
                .button-container {{
                    display: flex;
                    gap: 10px;
                    margin-bottom: 20px;
                    width: 100%;
                    position: fixed;
                    right: 20px;
                    top: 20px;
                    width: 290px;
                    z-index: 999;
                }}
            </style>
            <script>
                function toggleContent(buttonElement) {{
                    const container = buttonElement.parentElement.nextElementSibling;
                    const isCollapsed = container.classList.contains('collapsed');
                    container.classList.toggle('collapsed');
                    buttonElement.textContent = isCollapsed ? '▽' : '▷';

                    const allSections = document.querySelectorAll('.content-container');
                    const allCollapsed = Array.from(allSections).every(section => 
                        section.classList.contains('collapsed')
                    );
                    
                    // Update floating button text accordingly
                    const toggleButton = document.getElementById('toggleButton');
                    toggleButton.textContent = allCollapsed ? 'Expand Failed' : 'Collapse All';
                }}

                function toggleAll() {{
                    const button = document.getElementById('toggleButton');
                    const isCollapsed = button.textContent === 'Expand Failed';
                    const sections = document.querySelectorAll('.section');
                    
                    if (isCollapsed) {{
                        // Expand failed tests
                        sections.forEach(section => {{
                            if (section.querySelector('.header.failure') || section.querySelector('.header.not-run')) {{
                                const container = section.querySelector('.content-container');
                                const btn = section.querySelector('.collapse-btn');
                                container.classList.remove('collapsed');
                                btn.textContent = '▽';
                            }}
                        }});
                        button.textContent = 'Collapse All';
                    }} else {{
                        // Collapse all
                        sections.forEach(section => {{
                            const container = section.querySelector('.content-container');
                            const btn = section.querySelector('.collapse-btn');
                            container.classList.add('collapsed');
                            btn.textContent = '▷';
                        }});
                        button.textContent = 'Expand Failed';
                    }}
                }}

                function toggleTheme() {{
                    const body = document.body;
                    const button = document.getElementById('themeToggle');
                    body.classList.toggle('dark-mode');
                    button.textContent = body.classList.contains('dark-mode') ? '☀️ Light Mode' : '🌙 Dark Mode';
                }}

                function copyGTKWaveCommand(title) {{
                    const command = `gtkwave {test_folder}/output_files/${{title}}.vcd`;
                    navigator.clipboard.writeText(command);
                    
                    // Optional: Show feedback that command was copied
                    const button = event.target;
                    const originalText = button.textContent;
                    button.textContent = 'Copied!';
                    setTimeout(() => button.textContent = originalText, 1000);
                }}

                function scrollToSection(id) {{
                    const element = document.getElementById(id);
                    if (element) {{
                        element.scrollIntoView({{ behavior: 'smooth' }});
                    }}
                }}
            </script>
        </head>
        <body class="{initial_theme_class}">
            <div class="button-container">
                <button id="toggleButton" class="float-button" onclick="toggleAll()">Collapse All</button>
                <button id="themeToggle" class="theme-toggle" onclick="toggleTheme()">{initial_button_text}</button>
            </div>
            <div class="sidebar">
                <div class="sidebar-title">Test List</div>
                <div class="sidebar-content">
                    <!-- TOC links will be added here dynamically -->
                </div>
            </div>
            <div class="main-content">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <h1>Test Results - {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</h1>
                </div>
                <div class="description">You saved {time_saved} seconds by running this script instead of uploading to Gradescope.</div>
                <div class="description">Build version: {get_version()}</div>
        """

        sorted_items = sorted(
            cls._content_map.items(),
            key=lambda x: (x[1].state, x[0].lower())
        )

        # Generate TOC entries first
        toc_content = ""
        for title, content in sorted_items:
            state_class = {
                -3: 'failure',
                -2: 'success',
                -1: 'not-run',
                0: 'failure',
                2: 'success',
                1: 'warning',
            }.get(content.state, 'failure')
            
            section_id = f"section-{title.replace(' ', '-')}"
            toc_content += f'<a href="javascript:void(0)" onclick="scrollToSection(\'{section_id}\')" class="toc-link {state_class}">{title}</a>'

        html_content += f"""
            <script>
                document.querySelector('.sidebar-content').innerHTML = `{toc_content}`;
            </script>
        """

        # Generate HTML for each test section
        for title, content in sorted_items:
            section_id = f"section-{title.replace(' ', '-')}"
            html_content += f'<div class="section" id="{section_id}">'
            
            # Set header color based on state
            state_class = {
                -3: 'failure',
                -2: 'success',
                -1: 'not-run',
                0: 'failure',
                2: 'success',
                1: 'warning',
            }.get(content.state, 'failure')
            
            should_collapse = (
                content.state == 1 or 
                content.state == -3 or 
                content.state == -2
            )
            collapsed = 'collapsed' if should_collapse else ''
            button_symbol = '▷' if should_collapse else '▽'
            
            # Only show GTKWave button if state is not run or banned Verilog check
            gtkwave_button = ''
            if content.state != -1 and content.state != -3 and content.state != -2:
                gtkwave_button = f"""
                    <button class='copy-button {state_class}' onclick='event.stopPropagation(); copyGTKWaveCommand("{title}")'>
                        Copy GTKWave Command
                </button>
                """
            
            # Header with collapse button and clickable title
            html_content += f"""
                <div class='header {state_class}' onclick='toggleContent(this.querySelector(".collapse-btn"))'>
                    <button class='collapse-btn'>{button_symbol}</button>
                    <span>{title}</span>
                    {gtkwave_button}
                </div>
            """
            
            # Content container
            html_content += f"<div class='content-container {collapsed}'>"
            for block in content.content_blocks:
                html_content += "<div class='content-block'>"
                total_lines = len(block.text.split('\n'))
                for line_number, line in enumerate(block.text.split('\n'), 1):
                    if block.show_line_numbers:
                        # Format with consistent spacing: {number:width}:  {line}
                        padding_width = len(str(total_lines - 1))
                        line = f"{line_number-1:{padding_width}d}:  {line}"
                    css_class = 'failure' if 'FAILED' in line else ''
                    html_content += f"<div class='{css_class}'>{line}</div>"
                html_content += "</div>"
            html_content += "</div></div>"

        html_content += "</body></html>"

        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)

        # Write the HTML file
        cls._output_file = os.path.join(output_dir, f'results_{name}.html')
        with open(cls._output_file, 'w', encoding='utf-8') as f:
                f.write(html_content)
        
        return cls._output_file

    @classmethod
    def open_report(cls):
        """Open the generated HTML report in the default browser"""
        if cls._output_file and os.path.exists(cls._output_file):
            import webbrowser
            webbrowser.open('file://' + os.path.abspath(cls._output_file))
        else:
            Logger.error(f"Failed to open the HTML report {cls._output_file}")

    @classmethod
    def reformat_results(cls, text, func):
        """Calls correct reformatting function"""
        if func == "test_results":
            return reformat_test_results(text)
        else:
            return text
    
    @classmethod
    def clear(cls):
        """Clear the content map unless keep is set. Some items, like asm file contents, should not be cleared between runs."""
        keys_to_remove = []
        
        for title, content in cls._content_map.items():
            content.content_blocks = [block for block in content.content_blocks if block.keep]
            
            content.reset_state()

            if not content.content_blocks:
                keys_to_remove.append(title)
        
        for key in keys_to_remove:
            del cls._content_map[key]
    
    @classmethod
    def full_clear(cls):
        """Full clear, for unit/integration testing purposes"""
        cls._content_map = {}
        cls._output_file = None

    @classmethod
    def export_snapshot(cls, output_dir, filename="results.json"):
        """Export the content map to a JSON file - for testing purposes"""
        os.makedirs(output_dir, exist_ok=True)

        content_list = list(cls._content_map.values())
        content_list.sort(key=lambda x: x.title)

        json_file = os.path.join(output_dir, filename)
        
        # Write to JSON file
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump([content.to_dict() for content in content_list], f, indent=4)

        return json_file
        
