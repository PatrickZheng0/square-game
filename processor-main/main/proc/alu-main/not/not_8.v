module not_8(Out, A);
    input[7:0] A;
    output[7:0] Out;

    not NOT0(Out[0], A[0]);
    not NOT1(Out[1], A[1]);
    not NOT2(Out[2], A[2]);
    not NOT3(Out[3], A[3]);
    not NOT4(Out[4], A[4]);
    not NOT5(Out[5], A[5]);
    not NOT6(Out[6], A[6]);
    not NOT7(Out[7], A[7]);
endmodule