`timescale 1ns / 100ps
module mult_tb;
    wire[31:0] result, Exp;
    wire[63:0] out;
    wire result_rdy, Eq;
    reg clk;

    integer A, B;

    // wire[31:0] A, B;
    // assign A = {29'b0, 3'b001};
    // assign B = {29'b0, 3'b010};

    // assign A = {29'b0, 3'b000};
    // assign B = {29'b0, 3'b001};


    mult multiplier(out, result_rdy, A, B, clk, 1'b0);

    assign result = out[31:0];
    assign Exp = A*B;
    assign Eq = Exp == result;

    initial begin
        clk = 0;
        A = $random;
        B = $random;

        #390
        $finish;
    end

    always @(posedge clk) begin
        #10
        if (result_rdy == 1)
            $display("A:%b, B:%b, clk:%b, => result:%b, result_ready:%b, Exp:%b, Eq:%d", A, B, clk, result, result_rdy, Exp, Eq);
    end

    always
        #10 clk = ~clk;

    initial begin
        $dumpfile("mult_wave.vcd");
        $dumpvars(0, mult_tb);
    end    
endmodule