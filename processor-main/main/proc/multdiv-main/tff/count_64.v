module count_64(out, en, clk, clr);
    input clk, en, clr;
    output[5:0] out;

    wire en2, en3, en4, en5;

    tff tff0(out[0], en, clk, clr);

    tff tff1(out[1], out[0], clk, clr);

    assign en2 = out[0] & out[1];
    tff tff2(out[2], en2, clk, clr);

    assign en3 = out[0] & out[1] & out[2];
    tff tff3(out[3], en3, clk, clr);

    assign en4 = out[0] & out[1] & out[2] & out[3];
    tff tff4(out[4], en4, clk, clr);

    assign en5 = out[0] & out[1] & out[2] & out[3] & out[4];
    tff tff5(out[5], en5, clk, clr);

endmodule