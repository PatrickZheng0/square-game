module tff(out, T, clk, clr);
    input clk, T, clr;
    output out;

    wire T1, T2, D;

    assign T1 = out & (!T);
    assign T2 = (~out) & T;
    assign D = T1 | T2;

    dffe_ref dff(out, D, clk, 1'b1, clr);

endmodule