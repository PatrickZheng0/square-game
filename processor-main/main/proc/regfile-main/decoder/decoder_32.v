module decoder_32(out, select, en);
    input[4:0] select;
    input en;
    output[31:0] out;

    assign out = {31'b0, en} << select;
endmodule