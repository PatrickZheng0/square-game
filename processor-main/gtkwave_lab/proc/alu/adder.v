/**
 * Pretend this is a CLA adder
 * 
 */

module adder(data_operandA, data_operandB, carry_in, data_result);

    input [7:0] data_operandA, data_operandB;
    input carry_in;
    output [7:0] data_result;

    assign data_result = data_operandA + data_operandB + carry_in;

endmodule