module mult(out, result_rdy, multiplicand, multiplier, clk, reset, enable);
    input clk, reset, enable;
    input[31:0] multiplicand, multiplier;
    output result_rdy;
    output[63:0] out;

    // counter
    wire[4:0] cycle;
    wire clr;
    count_32 counter(cycle, 1'b1, clk, clr);
    assign clr = (cycle[4] & cycle[0]) | reset; // clear after 16th positive edge or on reset
    assign result_rdy = (cycle[4] & enable) ? 1'b1 : 1'bz;
    
    // multiplier
    wire[32:0] ext_multiplicand, shifted_multiplicand;
    assign ext_multiplicand = {multiplicand[31], multiplicand};
    assign shifted_multiplicand = ext_multiplicand << 1;

    wire[65:0] product, dff_out;
    assign product = |cycle ? dff_out : {33'b0, multiplier, 1'b0};

    assign out = dff_out[64:1];

    // modified booth's selection
    wire signed[65:0] buffer_result;
    wire[7:0] booth_en;
    decoder_8 decoder_booth(booth_en, product[2:0], 1'b1);
    
    // 000, do nothing
    tri_state_buffer tri_000(buffer_result, product, booth_en[0]);

    // 001, add multiplicand
    wire[32:0] add_multiplicand;
    wire Cout_001;
    add_33 sel_001(add_multiplicand, Cout_001, product[65:33], ext_multiplicand);
    tri_state_buffer tri_001(buffer_result, {add_multiplicand, product[32:0]}, booth_en[1]);
    
    // 010, same as 001
    wire[65:0] test;
    tri_state_buffer tri_010(buffer_result, {add_multiplicand, product[32:0]}, booth_en[2]);

    // 011, add multiplicand << 1
    wire[32:0] add_shift_multiplicand;
    wire Cout_011;
    add_33 sel_011(add_shift_multiplicand, Cout_011, product[65:33], shifted_multiplicand);
    tri_state_buffer tri_011(buffer_result, {add_shift_multiplicand, product[32:0]}, booth_en[3]);

    // 100, subtract multiplicand << 1
    wire[32:0] sub_shift_multiplicand;
    wire Cout_100;
    sub_33 sel_100(sub_shift_multiplicand, Cout_100, product[65:33], shifted_multiplicand);
    tri_state_buffer tri_100(buffer_result, {sub_shift_multiplicand, product[32:0]}, booth_en[4]);

    // 101, subtract multiplicand
    wire[32:0] sub_multiplicand;
    wire Cout_101;
    sub_33 sel_101(sub_multiplicand, Cout_101, product[65:33], ext_multiplicand);
    tri_state_buffer tri_101(buffer_result, {sub_multiplicand, product[32:0]}, booth_en[5]);

    // 110, same as 101
    tri_state_buffer tri_110(buffer_result, {sub_multiplicand, product[32:0]}, booth_en[6]);

    // 111, same as 000
    tri_state_buffer tri_111(buffer_result, product, booth_en[7]);

    dff_66 a_dff(dff_out, buffer_result >>> 2, clk, 1'b1, reset);

endmodule