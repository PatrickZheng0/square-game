`timescale 1ns / 100ps
module not_32_tb;
    wire[31:0] Out, Exp;

    integer i, A, Eq;

    not_32 not1(Out, A);
    assign Exp = ~A;

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            A = $random;

            #20
            Eq = Exp == Out;
            
            #20;
            $display("A:%b => Out:%b, Exp:%b, Eq:%d", A, Out, Exp, Eq);
        end
        $finish;
    end
endmodule