module sra_2(Out, A);
    input[31:0] A;
    output[31:0] Out;

    assign Out[29:0] = A[31:2];
    assign Out[31:30] = {2{A[31]}};

endmodule