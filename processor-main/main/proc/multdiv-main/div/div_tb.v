`timescale 1ns / 100ps
module div_tb;
    wire[31:0] result, Exp;
    wire[63:0] out;
    wire result_rdy, Eq;
    reg clk;

    // integer A, B;

    wire signed[31:0] A, B;
    assign A = {28'b0, 4'd3};
    assign B = {28'b0, 4'd2};

    // assign A = {29'b0, 3'b000};
    // assign B = {29'b0, 3'b001};


    div divider(out, result_rdy, ~A, B, clk, 1'b0);

    assign result = out[31:0];
    assign Exp = A/B;
    assign Eq = Exp == result;

    initial begin
        clk = 0;
        // A = $random;
        // B = $random;

        #680
        $finish;
    end

    always @(posedge clk) begin
        #5
        // if (result_rdy == 1)
            $display("A:%d, B:%d, clk:%b, => result:%d, result_ready:%b, Exp:%d, Eq:%d", A, B, clk, result, result_rdy, Exp, Eq);
    end

    always
        #10 clk = ~clk;

    initial begin
        $dumpfile("div_wave.vcd");
        $dumpvars(0, div_tb);
    end    
endmodule