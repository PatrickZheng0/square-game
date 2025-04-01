/**
 * Standard register module
 * 
 * @param WIDTH: Width of the register
 */ 

module register #(
    parameter WIDTH = 32
)(
    input clock, we, reset,
    input [WIDTH-1:0] dataWrite,
    output [WIDTH-1:0] dataRead
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: loop1
            dffe_ref d_flip_flop(.q(dataRead[i]), .d(dataWrite[i]), .clk(clock), .en(we), .clr(reset));
        end
    endgenerate
endmodule
