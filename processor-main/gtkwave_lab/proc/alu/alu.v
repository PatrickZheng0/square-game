/**
 * ALU that supports 4-bit addition and subtraction
 * 
 */

module alu(
    data_operandA, data_operandB,
    ctrl_ALUopcode,
    data_result
);

    // Set up inputs and outputs
    input [7:0] data_operandA, data_operandB;
    input ctrl_ALUopcode;
    output [7:0] data_result;

    wire [7:0] add_result, sub_result;

    adder add(.data_operandA(data_operandA), .data_operandB(data_operandB), .data_result(add_result), .carry_in(1'b0)); 
    adder sub(.data_operandA(data_operandA), .data_operandB(~data_operandB), .data_result(sub_result), .carry_in(1'b1)); 

    assign data_result = (ctrl_ALUopcode == 0) ? add_result : sub_result; 

endmodule