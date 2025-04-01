`timescale 1ns/1ps

module alu_tb();

    // Inputs
    reg [7:0] data_operandA;
    reg [7:0] data_operandB;
    reg ctrl_ALUopcode;

    // Outputs
    wire [7:0] data_result;

    // Instantiate ALU
    alu dut(
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_ALUopcode(ctrl_ALUopcode),
        .data_result(data_result)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        data_operandA = 0;
        data_operandB = 0;
        ctrl_ALUopcode = 0;

        // Wait 100 ns for initialization
        #100;

        // Test 1: Basic Addition (20 + 30 = 50)
        data_operandA = 8'h14;
        data_operandB = 8'h1E;
        ctrl_ALUopcode = 0;
        #20;
        if (data_result !== 8'h32) $display("Test 1 failed: 20 + 30 should be 50");

        // Test 2: Addition with Overflow (200 + 100 = 44 due to overflow)
        data_operandA = 8'hC8;
        data_operandB = 8'h64;
        ctrl_ALUopcode = 0;
        #20;
        if (data_result !== 8'h2C) $display("Test 2 failed: 200 + 100 should overflow to 44");

        // Test 3: Basic Subtraction (50 - 30 = 20)
        data_operandA = 8'h32;
        data_operandB = 8'h1E;
        ctrl_ALUopcode = 1;
        #20;
        if (data_result !== 8'h14) $display("Test 3 failed: 50 - 30 should be 20");

        // Test 4: Subtraction with Negative Result (30 - 50 = -20)
        data_operandA = 8'h1E;
        data_operandB = 8'h32;
        ctrl_ALUopcode = 1;
        #20;
        if (data_result !== 8'hEC) $display("Test 4 failed: 30 - 50 should be -20");

        $display("All tests completed");
        $finish;
    end

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
