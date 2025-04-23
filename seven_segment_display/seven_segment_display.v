`timescale 1ns / 1ps
module seven_segment_display(
    input clk,
    input reset,
    input[15:0] score,
    output reg[7:0] AN,
    output reg CA,
    output reg CB,
    output reg CC,
    output reg CD,
    output reg CE,
    output reg CF,
    output reg CG
);

    wire[3:0] bcd0, bcd1, bcd2, bcd3, bcd4;
    wire done, busy;
    reg start = 0;

    initial begin
        AN <= 0;
        CA <= 0;
        CB <= 0;
        CC <= 0;
        CD <= 0;
        CE <= 0;
        CF <= 0;
        CG <= 0;
    end

    // Convert binary score to BCD
    double_dabble binary_to_BCD(
        .clk(clk),
        .reset(reset),
        .start(start),
        .binary_in(score),
        .bcd0(bcd0),
        .bcd1(bcd1),
        .bcd2(bcd2),
        .bcd3(bcd3),
        .bcd4(bcd4),
        .busy(busy),
        .done(done)
    );

    // Get segment output
    wire[6:0] seg0, seg1, seg2, seg3, seg4;
    BCD_to_display bcd_0(.BCD(bcd0), .segment(seg0));
    BCD_to_display bcd_1(.BCD(bcd1), .segment(seg1));
    BCD_to_display bcd_2(.BCD(bcd2), .segment(seg2));
    BCD_to_display bcd_3(.BCD(bcd3), .segment(seg3));
    BCD_to_display bcd_4(.BCD(bcd4), .segment(seg4));

    // Start BCD conversion when score changes
    reg[15:0] last_score = 16'd0;
    always @(posedge clk) begin
        if (reset) begin
            start <= 1;
            last_score <= 0;
        end else if (score != last_score && !busy) begin
            start <= 1;
            last_score <= score;
        end else
            start <= 0;
    end

    // Display to LEDs
    reg[2:0] digit_on = 3'd0;
    reg[2:0] temp = 3'd0;
    always @(posedge clk) begin
        AN[0] <= ~(digit_on == 3'd0);
        AN[1] <= ~(digit_on == 3'd1);
        AN[2] <= ~(digit_on == 3'd2);
        AN[3] <= ~(digit_on == 3'd3);
        AN[4] <= ~(digit_on == 3'd4);
        AN[5] <= ~(digit_on == 3'd5);
        AN[6] <= ~(digit_on == 3'd6);
        AN[7] <= ~(digit_on == 3'd7);

        if (reset)
            digit_on <= 3'd0;
        else if (digit_on == 3'd0)
            {CG, CF, CE, CD, CC, CB, CA} <= seg0;
        else if (digit_on == 3'd1)
            {CG, CF, CE, CD, CC, CB, CA} <= seg1;
        else if (digit_on == 3'd2)
            {CG, CF, CE, CD, CC, CB, CA} <= seg2;
        else if (digit_on == 3'd3)
            {CG, CF, CE, CD, CC, CB, CA} <= seg3;
        else if (digit_on == 3'd4)
            {CG, CF, CE, CD, CC, CB, CA} <= seg4;

        if (digit_on == 3'd4)
            digit_on <= 3'd0;
        else begin
            temp = digit_on + 3'd1;
            digit_on = temp;
        end
    end

endmodule