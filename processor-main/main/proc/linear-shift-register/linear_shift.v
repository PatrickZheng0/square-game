module linear_shift (x_bus, clk, reset);
    input clk, reset;
    output [31:0] x_bus;

    wire f;
    xor f_out(f, x_bus[31], x_bus[0]);

    dffe_ref ff_31(x_bus[31], f, clk, 1'b1, reset);
    genvar i;
    generate
        for (i = 30; i >= 0; i = i - 1) begin: loop1
            dffe_ref ff(x_bus[i], x_bus[i+1], clk, 1'b1, reset);
        end
    endgenerate
endmodule