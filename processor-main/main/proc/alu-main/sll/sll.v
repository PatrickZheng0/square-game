module sll(Out, A, Shamt);
    input[31:0] A;
    input[4:0] Shamt;
    output[31:0] Out;
    
    wire[31:0] sh16, sh8, sh4, sh2;
    wire[31:0] sh16out, sh8out, sh4out, sh2out, sh1out;

    sll_16 sll16(sh16out, A);
    mux_2 mux16(sh16, Shamt[4], A, sh16out);

    sll_8 sll8(sh8out, sh16);
    mux_2 mux8(sh8, Shamt[3], sh16, sh8out);

    sll_4 sll4(sh4out, sh8);
    mux_2 mux4(sh4, Shamt[2], sh8, sh4out);
    
    sll_2 sll2(sh2out, sh4);
    mux_2 mux2(sh2, Shamt[1], sh4, sh2out);
    
    sll_1 sll1(sh1out, sh2);
    mux_2 mux1(Out, Shamt[0], sh2, sh1out);


endmodule