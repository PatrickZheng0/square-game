module cla_block(S, G, P, A, B, Cin);
    input[7:0] A, B;
    input Cin;
    output[7:0] S;
    output G, P;

    wire G, P;
    wire[7:0] c, g, p; // c[0-7] is actually c_1 through c_8
    

    and_8 calc_g(g, A, B);
    or_8 calc_p(p, A, B);


    wire G0, G1, G2, G3, G4, G5, G6;
    and AND0(G0, g[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and AND1(G1, g[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and AND2(G2, g[2], p[3], p[4], p[5], p[6], p[7]);
    and AND3(G3, g[3], p[4], p[5], p[6], p[7]);
    and AND4(G4, g[4], p[5], p[6], p[7]);
    and AND5(G5, g[5], p[6], p[7]);
    and AND6(G6, g[6], p[7]);
    or calc_G(G, G0, G1, G2, G3, G4, G5, G6, g[7]);

    and calc_P(P, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);


    wire c10;
    and C10(c10, p[0], Cin);
    or get_c1(c[0], g[0], c10); // is actually get c_1 due to naming scheme

    wire c20, c21;
    and C20(c20, p[1], p[0], Cin);
    and C21(c21, p[1], g[0]);
    or get_c2(c[1], g[1], c20, c21);

    wire c30, c31, c32;
    and C30(c30, p[2], p[1], p[0], Cin);
    and C31(c31, p[2], p[1], g[0]);
    and C32(c32, p[2], g[1]);
    or get_c3(c[2], g[2], c30, c31, c32);

    wire c40, c41, c42, c43;
    and C40(c40, p[3], p[2], p[1], p[0], Cin);
    and C41(c41, p[3], p[2], p[1], g[0]);
    and C42(c42, p[3], p[2], g[1]);
    and C43(c43, p[3], g[2]);
    or get_c4(c[3], g[3], c40, c41, c42, c43);

    wire c50, c51, c52, c53, c54;
    and C50(c50, p[4], p[3], p[2], p[1], p[0], Cin);
    and C51(c51, p[4], p[3], p[2], p[1], g[0]);
    and C52(c52, p[4], p[3], p[2], g[1]);
    and C53(c53, p[4], p[3], g[2]);
    and C54(c54, p[4], g[3]);
    or get_c5(c[4], g[4], c50, c51, c52, c53, c54);

    wire c60, c61, c62, c63, c64, c65;
    and C60(c60, p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    and C61(c61, p[5], p[4], p[3], p[2], p[1], g[0]);
    and C62(c62, p[5], p[4], p[3], p[2], g[1]);
    and C63(c63, p[5], p[4], p[3], g[2]);
    and C64(c64, p[5], p[4], g[3]);
    and C65(c65, p[5], g[4]);
    or get_c6(c[5], g[5], c60, c61, c62, c63, c64, c65);

    wire c70, c71, c72, c73, c74, c75, c76;
    and C70(c70, p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    and C71(c71, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and C72(c72, p[6], p[5], p[4], p[3], p[2], g[1]);
    and C73(c73, p[6], p[5], p[4], p[3], g[2]);
    and C74(c74, p[6], p[5], p[4], g[3]);
    and C75(c75, p[6], p[5], g[4]);
    and C76(c76, p[6], g[5]);
    or get_c7(c[6], g[6], c70, c71, c72, c73, c74, c75, c76);

    wire c80, c81, c82, c83, c84, c85, c86, c87;
    and C80(c80, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    and C81(c81, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and C82(c82, p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and C83(c83, p[7], p[6], p[5], p[4], p[3], g[2]);
    and C84(c84, p[7], p[6], p[5], p[4], g[3]);
    and C85(c85, p[7], p[6], p[5], g[4]);
    and C86(c86, p[7], p[6], g[5]);
    and C87(c87, p[7], g[6]);
    or get_c8(c[7], g[7], c80, c81, c82, c83, c84, c85, c86, c87);


    wire t0, t1, t2, t3, t4, t5, t6, t7;
    full_adder fa0(S[0], t0, A[0], B[0], Cin);
    full_adder fa1(S[1], t1, A[1], B[1], c[0]);
    full_adder fa2(S[2], t2, A[2], B[2], c[1]);
    full_adder fa3(S[3], t3, A[3], B[3], c[2]);
    full_adder fa4(S[4], t4, A[4], B[4], c[3]);
    full_adder fa5(S[5], t5, A[5], B[5], c[4]);
    full_adder fa6(S[6], t6, A[6], B[6], c[5]);
    full_adder fa7(S[7], t7, A[7], B[7], c[6]);

endmodule