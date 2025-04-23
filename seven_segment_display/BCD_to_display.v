`timescale 1ns / 1ps
module BCD_to_display(
    input[3:0] BCD,
    output reg[6:0] segment
);

    always @(*) begin
        case (BCD)
            4'd0: segment = 7'b1000000;
            4'd1: segment = 7'b1111001;
            4'd2: segment = 7'b0100100;
            4'd3: segment = 7'b0110000;
            4'd4: segment = 7'b0011001;
            4'd5: segment = 7'b0010010;
            4'd6: segment = 7'b0000010;
            4'd7: segment = 7'b1111000;
            4'd8: segment = 7'b0000000;
            4'd9: segment = 7'b0010000;
            default: segment = 7'b1111111;
        endcase
    end
endmodule