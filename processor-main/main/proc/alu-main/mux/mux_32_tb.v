`timescale 1ns / 100ps
module mux_32_tb;
    wire[31:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31;
    wire[4:0] select;
    wire[31:0] out;

    assign in0 = 32'd0;
    assign in1 = 32'd1;
    assign in2 = 32'd2;
    assign in3 = 32'd3;
    assign in4 = 32'd4;
    assign in5 = 32'd5;
    assign in6 = 32'd6;
    assign in7 = 32'd7;
    assign in8 = 32'd8;
    assign in9 = 32'd9;
    assign in10 = 32'd10;
    assign in11 = 32'd11;
    assign in12 = 32'd12;
    assign in13 = 32'd13;
    assign in14 = 32'd14;
    assign in15 = 32'd15;
    assign in16 = 32'd16;
    assign in17 = 32'd17;
    assign in18 = 32'd18;
    assign in19 = 32'd19;
    assign in20 = 32'd20;
    assign in21 = 32'd21;
    assign in22 = 32'd22;
    assign in23 = 32'd23;
    assign in24 = 32'd24;
    assign in25 = 32'd25;
    assign in26 = 32'd26;
    assign in27 = 32'd27;
    assign in28 = 32'd28;
    assign in29 = 32'd29;
    assign in30 = 32'd30;
    assign in31 = 32'd31;

    integer i;

    assign select = i[4:0];

    mux_32 mux(out, select, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31);
    
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            #20;
            $display("select:%b => out:%b", select, out);
        end
        $finish;
    end
endmodule