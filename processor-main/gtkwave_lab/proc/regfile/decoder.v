module decoder #     (
    parameter WIDTH = 32,
    parameter SELECT_BITS = 5
)(
    input [SELECT_BITS-1:0] select,
    input enable,
    output [WIDTH-1:0] out
);
    assign out = enable << select;
endmodule