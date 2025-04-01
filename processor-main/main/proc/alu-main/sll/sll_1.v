module sll_1(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[31:1] = A[30:0];
    assign Out[0] = 1'b0;

endmodule