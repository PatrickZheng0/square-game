`timescale 1ns / 1ps
module double_dabble(
    input clk,
    input reset,
    input start,
    input[15:0] binary_in,
    output reg [3:0] bcd0,
    output reg [3:0] bcd1,
    output reg [3:0] bcd2,
    output reg [3:0] bcd3,
    output reg [3:0] bcd4,
    output reg busy,
    output reg done
);
    initial begin
        busy <= 0;
        done <= 0;
    end

    reg[3:0] temp = 0;
    reg[4:0] counter = 0;
    reg[35:0] scratch_space = 36'd0;
    wire test = scratch_space[19:16] >= 4'd5;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scratch_space <= 0;
            busy <= 0;
            done <= 0;
            counter <= 0;
        end else if (clk) begin
            if (start && !busy) begin
                scratch_space <= {20'b0, binary_in};
                counter <= 0;
                busy <= 1;
                done <= 0;
            end else if (busy) begin
                // add 3 if any group is at least 5
                if (scratch_space[19:16] >= 4'd5) begin
                    temp = scratch_space[19:16] + 4'd3;
                    scratch_space[19:16] = temp;
                end
                if (scratch_space[23:20] >= 4'd5) begin
                    temp = scratch_space[23:20] + 4'd3;
                    scratch_space[23:20] = temp;
                end
                if (scratch_space[27:24] >= 4'd5) begin
                    temp = scratch_space[27:24] + 4'd3;
                    scratch_space[27:24] = temp;
                end
                if (scratch_space[31:28] >= 4'd5) begin
                    temp = scratch_space[31:28] + 4'd3;
                    scratch_space[31:28] = temp;
                end
                if (scratch_space[35:32] >= 4'd5) begin
                    temp = scratch_space[35:32] + 4'd3;
                    scratch_space[35:32] = temp;
                end
                
                scratch_space = scratch_space << 1;
                counter = counter + 1;

                if (counter == 5'd16) begin
                    // extract BCD bits
                    bcd0 <= scratch_space[19:16];
                    bcd1 <= scratch_space[23:20];
                    bcd2 <= scratch_space[27:24];
                    bcd3 <= scratch_space[31:28];
                    bcd4 <= scratch_space[35:32];

                    busy <= 0;
                    done <= 1;
                end
            end
        end
    end

endmodule