module sll_8(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[31:8] = A[23:0];
    assign Out[7:0] = 8'b0;

endmodule