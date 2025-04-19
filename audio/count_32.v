module count_32(out, en, clk, clr);
    input clk, en, clr;
    output[4:0] out;

    wire en2, en3, en4;

    tff tff0(out[0], en, clk, clr);

    tff tff1(out[1], out[0], clk, clr);

    assign en2 = out[0] & out[1];
    tff tff2(out[2], en2, clk, clr);

    assign en3 = out[0] & out[1] & out[2];
    tff tff3(out[3], en3, clk, clr);

    assign en4 = out[0] & out[1] & out[2] & out[3];
    tff tff4(out[4], en4, clk, clr);

endmodule