`timescale 1ns / 100ps
module dff_32_tb;
    wire[31:0] q, Exp;
    wire Eq;
    reg clk, en, clr;

    integer d, i;

    assign Exp = (clk && en && !clr) && d;
    assign Eq = Exp == q;

    dff_32 a_dff_32(q, d, clk, en, clr);

    initial begin
        clk = 0;
        en = 1;
        clr = 0;

        #80
        $finish;
    end

    always @(clk, en, clr) begin
        d = $random;
        #2
        $display("q:%b, clk:%b, en:%b, clr:%b => d:%b, Exp:%b, Eq:%d", q, clk, en, clr, d, Exp, Eq);
    end

    always
        #10 clk = ~clk;
    // always
    //     #20 en = ~en;
    always
        #20 clr = ~clr;
endmodule