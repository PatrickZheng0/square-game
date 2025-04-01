module and_8(Out, A, B);
    input[7:0] A, B;
    output[7:0] Out;

    and AND0(Out[0], A[0], B[0]);
    and AND1(Out[1], A[1], B[1]);
    and AND2(Out[2], A[2], B[2]);
    and AND3(Out[3], A[3], B[3]);
    and AND4(Out[4], A[4], B[4]);
    and AND5(Out[5], A[5], B[5]);
    and AND6(Out[6], A[6], B[6]);
    and AND7(Out[7], A[7], B[7]);
endmodule