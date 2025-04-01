`timescale 1ns/1ps

module regfile_tb();

    // Parameters
    parameter WIDTH = 32;
    parameter SIZE = 32;
    localparam REGBITS = $clog2(SIZE);

    // Inputs
    reg clock;
    reg ctrl_writeEnable;
    reg ctrl_reset;
    reg [REGBITS-1:0] ctrl_writeReg;
    reg [REGBITS-1:0] ctrl_readReg;
    reg [WIDTH-1:0] data_writeReg;

    // Outputs
    wire [WIDTH-1:0] data_readReg;

    // Instantiate regfile
    regfile #(
        .WIDTH(WIDTH),
        .SIZE(SIZE)
    ) dut (
        .clock(clock),
        .ctrl_writeEnable(ctrl_writeEnable),
        .ctrl_reset(ctrl_reset),
        .ctrl_writeReg(ctrl_writeReg),
        .ctrl_readReg(ctrl_readReg),
        .data_writeReg(data_writeReg),
        .data_readReg(data_readReg)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        ctrl_writeEnable = 0;
        ctrl_reset = 1;
        ctrl_writeReg = 0;
        ctrl_readReg = 0;
        data_writeReg = 0;

        // Wait 100 ns for global reset
        #100;
        ctrl_reset = 0;
        
        // Test 1: Write to register 1 and read it back
        #20;
        ctrl_writeReg = 1;
        data_writeReg = 32'hDEADBEEF;
        ctrl_writeEnable = 1;
        #20;
        ctrl_writeEnable = 0;
        ctrl_readReg = 1;
        #20;
        if (data_readReg !== 32'hDEADBEEF) $display("Test 1 failed!");
        
        // Test 2: Write to register 2 and read it back
        #20;
        ctrl_writeReg = 2;
        data_writeReg = 32'hCAFEBABE;
        ctrl_writeEnable = 1;
        #20;
        ctrl_writeEnable = 0;
        ctrl_readReg = 2;
        #20;
        if (data_readReg !== 32'hCAFEBABE) $display("Test 2 failed!");
        
        // Test 3: Read from $r0 (should always be 0)
        ctrl_readReg = 0;
        #20;
        if (data_readReg !== 32'h0) $display("Test 3 failed!");
        
        // Test 4: Try to write to $r0 (should remain 0)
        ctrl_writeReg = 0;
        data_writeReg = 32'hFFFFFFFF;
        ctrl_writeEnable = 1;
        #20;
        ctrl_writeEnable = 0;
        ctrl_readReg = 0;
        #20;
        if (data_readReg !== 32'h0) $display("Test 4 failed!");

        // Test 5: Test reset
        ctrl_reset = 1;
        #20;
        ctrl_reset = 0;
        ctrl_readReg = 1;  // Read from register 1 (should be 0 after reset)
        #20;
        if (data_readReg !== 32'h0) $display("Test 5 failed!");

        $display("All tests completed");
        $finish;
    end

    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);
    end

endmodule
