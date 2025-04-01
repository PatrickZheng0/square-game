module or_32(Out, A, B);
    input[31:0] A, B;
    output[31:0] Out;

    or_8 OR1(Out[7:0], A[7:0], B[7:0]);
    or_8 OR2(Out[15:8], A[15:8], B[15:8]);
    or_8 OR3(Out[23:16], A[23:16], B[23:16]);
    or_8 OR4(Out[31:24], A[31:24], B[31:24]);
endmodule