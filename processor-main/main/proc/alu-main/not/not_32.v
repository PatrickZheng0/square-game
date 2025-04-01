module not_32(Out, A);
    input[31:0] A;
    output[31:0] Out;

    not_8 NOT1(Out[7:0], A[7:0]);
    not_8 NOT2(Out[15:8], A[15:8]);
    not_8 NOT3(Out[23:16], A[23:16]);
    not_8 NOT4(Out[31:24], A[31:24]);
endmodule