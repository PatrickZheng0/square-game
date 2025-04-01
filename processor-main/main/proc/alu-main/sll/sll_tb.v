`timescale 1ns / 100ps
module sll_tb;
    wire[31:0] Out, Exp;
    wire[4:0] Shamt;

    integer i, A, Shamti, Eq;

    assign Shamt = Shamti[4:0];
    assign Exp = A<<Shamt;

    sll sll_test(Out, A, Shamt);

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            A = $random;
            Shamti = $random;

            #20
            Eq = Exp == Out;
            
            #20;
            $display("A:%b, Shamt:%b => Out:%b, Exp:%b, Eq:%d", A, Shamt, Out, Exp, Eq);
        end
        $finish;
    end
endmodule