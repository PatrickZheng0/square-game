`timescale 1ns / 100ps
module decoder_32_tb;
    wire[31:0] out, Exp;
    wire[4:0] select;
    wire en, Eq;

    integer i, A;

    assign Exp = en << select;
    assign Eq = Exp == out;

    assign en = i[0];
    assign select = i[4:0];

    decoder_32 decoder_32_1(out, select, en);

    initial begin
        for (i = 0; i < 32; i = i+1) begin
            A = $random;
            
            #20;
            $display("select:%b, en:%b, => out:%b, Exp:%b, Eq:%d", select, en, out, Exp, Eq);
        end
        $finish;
    end
endmodule