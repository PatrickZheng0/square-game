module or_8(Out, A, B);
    input[7:0] A, B;
    output[7:0] Out;

    or OR0(Out[0], A[0], B[0]);
    or OR1(Out[1], A[1], B[1]);
    or OR2(Out[2], A[2], B[2]);
    or OR3(Out[3], A[3], B[3]);
    or OR4(Out[4], A[4], B[4]);
    or OR5(Out[5], A[5], B[5]);
    or OR6(Out[6], A[6], B[6]);
    or OR7(Out[7], A[7], B[7]);
endmodule