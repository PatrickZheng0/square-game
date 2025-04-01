module register #(parameter WIDTH = 32) (q, d, clk, en, clr);
    input clk, en, clr;
    input[WIDTH-1:0] d;
    output[WIDTH-1:0] q;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i+1) begin: loop1
            dffe_ref a_dffe_ref(q[i], d[i], clk, en, clr);
        end
    endgenerate
endmodule