module sra_4(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[27:0] = A[31:4];
    assign Out[31:28] = {4{A[31]}};

endmodule