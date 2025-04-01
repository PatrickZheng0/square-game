module sra_8(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[23:0] = A[31:8];
    assign Out[31:24] = {8{A[31]}};

endmodule