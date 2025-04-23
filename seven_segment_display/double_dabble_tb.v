`timescale 1ns / 100ps
module double_dabble_tb;
    reg[15:0] score = 16'd754;
    reg start, clk;
    wire[3:0] bcd0, bcd1, bcd2, bcd3, bcd4;
    wire busy, done;
    wire reset = 1'b0;

    initial begin
        start <= 0;
    end

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

    initial begin
        clk = 0;
        #9000000;
        $finish;
    end

    always
        #50000 clk = ~clk;

    always @(clk) begin
        $display("BCD0:%d, BCD1:%d, BCD2:%d, BCD3:%d, BCD4:%d, busy:%b, done:%b, start:%b", bcd0, bcd1, bcd2, bcd3, bcd4, busy, done, start);
    end

    initial begin
        $dumpfile("double_dabble_tb.vcd");
        $dumpvars(0, double_dabble_tb);
    end
endmodule