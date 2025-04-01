`timescale 1ns / 100ps
module cla_tb;
    wire[31:0] S, Exp;
    wire Cin, Cout, Eq;
    // wire[31:0] A, B;

    integer i, C;
    integer A, B;

    assign Exp = A+B+Cin;
    assign Eq = Exp == S;

    assign Cin = C[0];

    // assign A = 32'd4294967295;
    // assign B = 32'd4294967295;
    // assign Cin = 1;

    cla cla1(S, Cout, A, B, Cin);

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            A = $random;
            B = $random;
            C = $random;
            
            #20;
            $display("A:%b, B:%b, Cin:%b => Out:%b, Cout:%b, Exp:%b, Eq:%d", A, B, Cin, S, Cout, Exp, Eq);
        end
        $finish;
    end
endmodule