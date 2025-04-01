module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    wire mult_en, div_en;

    // mult
    wire[63:0] mult_result;
    wire[31:0] mult_A, mult_B;
    wire mult_data_exception;

    dff_32 get_mult_A(mult_A, data_operandA, clock, ctrl_MULT, 1'b0);
    dff_32 get_mult_B(mult_B, data_operandB, clock, ctrl_MULT, 1'b0);
    dffe_ref get_mult_en(mult_en, ctrl_MULT, clock, ctrl_MULT, ctrl_DIV);


    mult multiplier(mult_result, data_resultRDY, mult_A, mult_B, clock, ctrl_MULT, mult_en);
   
    assign mult_data_exception = (((mult_A[31]^mult_B[31])&(~mult_result[31])) // operands have diff signs, output is positive
                                | ((~(mult_A[31]^mult_B[31]))&(mult_result[31])) // operands have same signs, output is negative
                                | ((&mult_result[63:32])^(|mult_result[63:32]))) // overflowed bits aren't all the same
                                & (|mult_A) & (|mult_B); // above cases are only exception if operands aren't 0
   

    // div
    wire[63:0] uncorrected_div_res;
    wire[31:0] div_A, div_B, negate_A, negate_B, corrected_div_A, corrected_div_B;
    wire[31:0] div_res_negated, div_result;
    wire div_data_exception, A_Cout, B_Cout, div_res_Cout, flipped_signs;

    dff_32 get_div_A(div_A, data_operandA, clock, ctrl_DIV, 1'b0);
    dff_32 get_div_B(div_B, data_operandB, clock, ctrl_DIV, 1'b0);
    dffe_ref get_div_en(div_en, ctrl_DIV, clock, ctrl_DIV, ctrl_MULT);
    

    // check signs
    assign flipped_signs = div_A[31]^div_B[31];
    cla get_negate_A(negate_A, A_Cout, ~div_A, {{31{1'b0}}, 1'b1}, 1'b0);
    assign corrected_div_A = div_A[31] ? negate_A : div_A;
    
    cla get_negate_B(negate_B, B_Cout, ~div_B, {{31{1'b0}}, 1'b1}, 1'b0);
    assign corrected_div_B = div_B[31] ? negate_B : div_B;

    // divider
    div divider(uncorrected_div_res, data_resultRDY, corrected_div_A, corrected_div_B, clock, ctrl_DIV, div_en);
    cla get_negate_res(div_res_negated, div_res_Cout, ~uncorrected_div_res[31:0], {31'b0, 1'b1}, 1'b0);
    assign div_result = flipped_signs ? div_res_negated : uncorrected_div_res[31:0];

    // divide by zero exception
    wire divide_by_zero;
    assign divide_by_zero = ~(|div_B);


    // result ready
    wire mult_and_div_exception;
    dffe_ref get_multdiv_exception(mult_and_div_exception, (ctrl_MULT & ctrl_DIV), clock, (ctrl_MULT | ctrl_DIV), 1'b0);
    assign data_resultRDY = mult_and_div_exception ? 1'b1 : 1'bz;

    // exception
    assign data_exception = (mult_data_exception & mult_en) | (divide_by_zero & div_en) | (mult_and_div_exception);

    // result
    assign data_result = (({32{mult_en}} & mult_result)
                       | ({32{div_en}} & div_result & {32{~divide_by_zero}}))
                       & {32{~mult_and_div_exception}};

endmodule