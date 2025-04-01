module sll_16(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[31:16] = A[15:0];
    assign Out[15:0] = 16'b0;

endmodule