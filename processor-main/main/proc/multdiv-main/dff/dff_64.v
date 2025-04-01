module dff_64(q, d, clk, en, clr);
    input[63:0] d;
    input clk, en, clr;
    output[63:0] q;

    genvar i;
    generate
        for (i = 0; i < 64; i = i+1) begin: loop1
            dffe_ref a_dffe_ref(q[i], d[i], clk, en, clr);
        end
    endgenerate

endmodule