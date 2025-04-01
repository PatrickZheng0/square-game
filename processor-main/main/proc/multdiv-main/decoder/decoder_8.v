module decoder_8(out, select, en);
    input[2:0] select;
    input en;
    output[7:0] out;

    assign out = {7'b0, en} << select;
endmodule