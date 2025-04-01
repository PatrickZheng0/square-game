module sub_33(S, Cout, A, B);
    input[32:0] A, B;
    output[32:0] S;
    output Cout;

    wire cla_Cout;
    wire[32:0] not_B;
    assign not_B = ~B;

    cla a_cla(S[31:0], cla_Cout, A[31:0], not_B[31:0], 1'b1);
    full_adder a_full_adder(S[32], Cout, A[32], not_B[32], cla_Cout);

endmodule