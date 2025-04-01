`timescale 1ns / 100ps
module full_adder_tb;
    reg A, B, Cin;
    wire S, Cout;
    full_adder adder(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    initial begin
        A = 0;
        B = 0;
        Cin = 0;
        #80;
        $finish;
    end

    always
        #10 A = ~A;
    always
        #20 B = ~B;
    always
        #40 Cin = ~Cin;

    always @(A, B, Cin) begin
        #1; 
        $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);
    end

    initial begin
        $dumpfile("full_adder_wave.vcd");
        $dumpvars(0, full_adder_tb);
    end
endmodule