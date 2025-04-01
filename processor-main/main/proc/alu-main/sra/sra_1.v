module sra_1(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[30:0] = A[31:1];
    assign Out[31] = A[31];

endmodule