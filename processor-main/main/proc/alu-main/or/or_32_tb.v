`timescale 1ns / 100ps
module or_32_tb;
    wire[31:0] Out, Exp;

    integer i, A, B, Eq;

    or_32 OR1(Out, A, B);
    assign Exp = A|B;

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            A = $random;
            B = $random;

            #20
            Eq = Exp == Out;
            
            #20;
            $display("A:%b, B:%b => Out:%b, Exp:%b, Eq:%d", A, B, Out, Exp, Eq);
        end
        $finish;
    end
endmodule