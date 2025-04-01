`timescale 1ns / 100ps
module count_32_tb;
    wire en;
    wire[4:0] out;
    wire Eq;
    reg clk;
    reg[4:0] Exp;

    assign Eq = Exp == out;
    assign en = 1'b1;

    count_32 a_count_32(out, en, clk);

    initial begin
        clk = 0;
        Exp = 0;

        #800
        $finish;
    end

    always @(clk) begin
        #2
        $display("en:%b, clk:%b, => out:%b, Exp:%b, Eq:%d", en, clk, out, Exp, Eq);
    end

    always @(posedge clk) begin
        if (en == 1) begin
            Exp = Exp + 1'b1;
        end
    end

    always
        #10 clk = ~clk;
endmodule