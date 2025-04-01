`timescale 1ns / 100ps
module tff_tb;
    wire out, T;
    wire Eq;
    reg clk;
    reg Exp;

    assign Eq = Exp == out;
    assign T = 1'b1;

    tff a_tff(out, T, clk);

    initial begin
        clk = 0;
        Exp = 0;

        #80
        $finish;
    end

    always @(clk) begin
        #2
        $display("T:%b, clk:%b, => out:%b, Exp:%b, Eq:%d", T, clk, out, Exp, Eq);
    end

    always @(posedge clk) begin
        if (T == 1) begin
            Exp = ~Exp;
        end
    end

    always
        #10 clk = ~clk;
endmodule