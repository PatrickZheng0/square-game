module full_adder(S, Cout, A, B, Cin);
    input A, B, Cin;
    output S, Cout;
    wire w1, w2, w3;

    xor XOR1(S, A, B, Cin);
    and AND1(w1, A, B);
    and AND2(w2, B, Cin);
    and AND3(w3, A, Cin);
    or OR1(Cout, w1,w2,w3);
endmodule