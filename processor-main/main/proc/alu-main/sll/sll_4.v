module sll_4(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[31:4] = A[27:0];
    assign Out[3:0] = 4'b0;

endmodule