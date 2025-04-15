module linear_shift (f, clk, reset);
    input clk, reset;
    output f;

    wire [3:0] x_bus;

    xor f_out(f, x_bus[3], x_bus[0]);

    dffe_ref ff_1(x_bus[3], f, clk, 1'b1, reset);
    dffe_ref ff_2(x_bus[2], x_bus[3], clk, 1'b1, reset);
    dffe_ref ff_3(x_bus[1], x_bus[2], clk, 1'b1, reset);
    dffe_ref ff_4(x_bus[0], x_bus[1], clk, 1'b1, reset);
endmodule