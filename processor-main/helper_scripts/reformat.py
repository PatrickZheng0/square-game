"""
Reformat the results text to be more like the Gradescope output

@author: Vincent Chen
"""

def reformat_test_results(input_text):
    lines = input_text.split('\n')
    formatted_lines = ["==================== Results ===================="]
    passed = False
    
    for line in lines:
        parts = line.strip().split()
        if parts and parts[0] == 'FAILED':
            # parts will be ['FAILED', 'Reg:', reg_num, 'Expected:', exp_val, 'Actual:', act_val]
            reg = parts[2]
            expected = parts[4]
            actual = parts[6]
            formatted_line = f"Reg: {reg:<2} Expected:{expected:>12} Actual:{actual:>12}"
            formatted_line = formatted_line.replace(' ', '&nbsp;')
            formatted_lines.append(formatted_line)
        # FIXME: bad if statement
        elif line and "Finished" not in line and "VCD" not in line and "$finish called at" not in line:
            formatted_lines.append(line)

        if "Finished" in line:
            passed = ":P" in line

    if passed:
        return "All registers passed!"

    return '\n'.join(formatted_lines)

# Testing code
if __name__ == "__main__":
    test_input = """FAILED Reg: 1 Expected: 830 Actual: 2
FAILED Reg: 4 Expected: 842 Actual: 14"""
    
    formatted = reformat_test_results(test_input)
    print(formatted)
