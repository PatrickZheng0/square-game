`timescale 1ns / 100ps
module seven_segment_display_tb;
    reg[15:0] score = 16'd754;
    reg clk;
    wire[7:0] AN;
    wire CA, CB, CC, CD, CE, CF, CG;
    wire reset = 1'b0;

	seven_segment_display display_score(
		.clk(clk),
		.reset(reset),
		.score(score),
		.AN(AN),
		.CA(CA),
		.CB(CB),
		.CC(CC),
		.CD(CD),
		.CE(CE),
		.CF(CF),
		.CG(CG)
	);

    initial begin
        clk = 0;
        #9000000;
        $finish;
    end

    always @(clk) begin
        score <= score + 16'd1;
    end

    always
        #50000 clk = ~clk;

    always @(clk) begin
        $display("AN:%b, CA:%b, CB:%b, CC:%b, CD:%b, CE:%b, CF:%b, CG:%b", AN, CA, CB, CC, CD, CE, CF, CG);
    end

    initial begin
        $dumpfile("seven_segment_display_tb.vcd");
        $dumpvars(0, seven_segment_display_tb);
    end
endmodule