module sll_2(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[31:2] = A[29:0];
    assign Out[1:0] = 2'b0;

endmodule