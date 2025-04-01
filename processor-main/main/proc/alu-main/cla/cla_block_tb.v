`timescale 1ns / 100ps
module cla_block_tb;
    wire[7:0] S, Exp, A, B;
    wire Cin, G, P, Eq;

    integer i, Ai, Bi, Ci;

    assign Exp = A+B+Cin;
    assign Eq = Exp == S;


    // assign A = Ai[7:0];
    // assign B = Bi[7:0];
    // assign Cin = Ci[0];
    assign A = 8'd255;
    assign B = 8'd1;
    assign Cin = 1;

    cla_block cla1(S, G, P, A, B, Cin);

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            Ai = $random;
            Bi = $random;
            Ci = $random;
            
            #20;
            $display("A:%b, B:%b, Cin:%b => Out:%b, Exp:%b, Eq:%d, G:%b, P:%b", A, B, Cin, S, Exp, Eq, G, P);
        end
        $finish;
    end
endmodule