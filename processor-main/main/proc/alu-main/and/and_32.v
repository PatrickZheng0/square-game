module and_32(Out, A, B);
    input[31:0] A, B;
    output[31:0] Out;

    and_8 AND1(Out[7:0], A[7:0], B[7:0]);
    and_8 AND2(Out[15:8], A[15:8], B[15:8]);
    and_8 AND3(Out[23:16], A[23:16], B[23:16]);
    and_8 AND4(Out[31:24], A[31:24], B[31:24]);
endmodule