module div(out, result_rdy, dividend, divisor, clk, reset, enable);
    input clk, reset, enable;
    input[31:0] dividend, divisor;
    output result_rdy;
    output[63:0] out;

    // counter
    wire[5:0] cycle;
    wire clr;
    count_64 counter(cycle, 1'b1, clk, clr);
    assign clr = (cycle[5] & cycle[0]) | reset; // clear after 32nd positive edge or reset
    assign result_rdy = (cycle[5] & enable) ? 1'b1 : 1'bz;

    // divider
    wire[63:0] AQ, shifted_AQ, add_sub_AQ, corrected_AQ, dff_out;
    wire[31:0] add_A_M, add_shifted_A_M, sub_A_M, sub_shifted_A_M;
    wire add_Cout, add_shifted_Cout, sub_Cout, sub_shifted_Cout;

    assign AQ = |cycle ? dff_out : {{32{1'b0}}, dividend};
    assign shifted_AQ = AQ << 1;

    // NRDI - final trial subtraction
    cla add_M(add_A_M, add_Cout, AQ[63:32], divisor, 1'b0);
    assign out = AQ[63] ? {add_A_M, AQ[31:0]} : AQ;

    // Non-restoring division
    cla add_shifted_M(add_shifted_A_M, add_shifted_Cout, shifted_AQ[63:32], divisor, 1'b0);
    cla sub_shifted_M(sub_shifted_A_M, sub_shifted_Cout, shifted_AQ[63:32], ~divisor, 1'b1);

    assign add_sub_AQ = shifted_AQ[63] ? {add_shifted_A_M, shifted_AQ[31:0]} : {sub_shifted_A_M, shifted_AQ[31:0]};
    assign corrected_AQ = add_sub_AQ[63] ? {add_sub_AQ[63:1], 1'b0} : {add_sub_AQ[63:1], 1'b1};

    dff_64 a_dff(dff_out, corrected_AQ, clk, 1'b1, reset);

endmodule