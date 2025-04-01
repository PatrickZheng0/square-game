module sra_16(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[15:0] = A[31:16];
    assign Out[31:16] = {16{A[31]}};

endmodule