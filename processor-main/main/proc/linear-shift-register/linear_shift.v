module linear_shift (rand_out, clk, reset);
    input clk, reset;
    output [31:0] rand_out;

    reg [31:0] rand;

    assign rand_out = rand;

    initial begin
		rand = 1;
	end

    always @(posedge clk) begin
        rand = {{rand[31]^rand[30]^rand[10]^rand[0]},rand[31:1]};
    end
endmodule