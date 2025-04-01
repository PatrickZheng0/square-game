module cla(S, Cout, A, B, Cin);
    input[31:0] A, B;
    input Cin;
    output[31:0] S;
    output Cout;

    wire G0, G1, G2, G3, P0, P1, P2, P3, c8, c16, c24;

    cla_block block1(S[7:0], G0, P0, A[7:0], B[7:0], Cin);
    
    wire c8_1;
    and AND8_1(c8_1, P0, Cin);
    or calc_c8(c8, G0, c8_1);

    cla_block block2(S[15:8], G1, P1, A[15:8], B[15:8], c8);

    wire c16_1, c16_2;
    and AND16_1(c16_1, P1, P0, Cin);
    and AND16_2(c16_2, P1, G0);
    or calc_c16(c16, G1, c16_1, c16_2);

    cla_block block3(S[23:16], G2, P2, A[23:16], B[23:16], c16);

    wire c24_1, c24_2, c24_3;
    and AND24_1(c24_1, P2, P1, P0, Cin);
    and AND24_2(c24_2, P2, P1, G0);
    and AND24_3(c24_3, P2, G1);
    or calc_c24(c24, G2, c24_1, c24_2, c24_3);

    cla_block block4(S[31:24], G3, P3, A[31:24], B[31:24], c24);

    // not used 
    wire c32_1, c32_2, c32_3, c32_4;
    and AND32_1(c32_1, P3, P2, P1, P0, Cin);
    and AND32_2(c32_2, P3, P2, P1, G0);
    and AND32_3(c32_3, P3, P2, G1);
    and AND32_4(c32_4, P3, G2);
    or calc_c32(Cout, G3, c32_1, c32_2, c32_3, c32_4);

endmodule