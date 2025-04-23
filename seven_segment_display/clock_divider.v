module clock_divider(
    input clk_100mHz_in,
    input reset,
    output reg clk_10kHz_out
);
    reg[13:0] counter;

    initial begin
        clk_10kHz_out <= 1'b0;
    end

    always @(posedge clk_100mHz_in or posedge reset) begin
        if (reset) begin
            counter <= 14'd0;
            clk_10kHz_out <= 1'b0;
        end else begin
            if (counter == 14'd4999) begin
                counter <= 14'd0;
                clk_10kHz_out <= ~clk_10kHz_out; // Toggle the clock
            end else
                counter <= counter + 1;
        end
    end

endmodule