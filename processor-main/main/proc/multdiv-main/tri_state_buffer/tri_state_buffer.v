module tri_state_buffer(out, in, oe);
    input[65:0] in;
    input oe;
    output[65:0] out;

    assign out = oe ? in : 66'bz;
endmodule