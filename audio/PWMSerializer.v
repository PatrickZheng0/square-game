/*
This module takes in a desired duty cycle percentage and the total width of the pulse,
and outputs a PWM signal with the specified duty cycle.

*/

module PWMSerializer #(
    parameter 
    // Parameters in nanoseconds
    PERIOD_WIDTH_NS = 20000000,  // Total width of the period in nanoseconds
    SYS_FREQ_MHZ   = 100     // Base FPGA Clock in MHz; Nexys A7 uses a 100 MHz Clock
    )(
    input clk,              // System Clock
    input reset,            // Reset the counter
    input [9:0] duty_cycle, // Duty Cycle of the Wave, between 0 and 1023 - scaled to 0 and 100
    output reg signal = 0   // Output PWM signal
    );
    
    // Convert PULSE_WIDTH_NS to clock cycles
    localparam PERIOD = (PERIOD_WIDTH_NS * SYS_FREQ_MHZ) / 1000; // Convert ns to clock cycles
    localparam PULSE_HALF   = PERIOD >> 1;
    localparam PULSE_BITS   = $clog2(PERIOD) + 1;
    
    // Counter to track pulse timing
    reg[PULSE_BITS-1:0] pulseCounter = 0;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pulseCounter <= 0;
        end else begin
            if(pulseCounter < PERIOD - 1) begin
                pulseCounter <= pulseCounter + 1;
            end else begin
                pulseCounter <= 0;
            end
        end
    end
    
    // The pulse is high when the counter is less than the calculated duty cycle count
    wire lessThan;
    reg delayerBit = 0;
    assign lessThan = pulseCounter < ((duty_cycle * PERIOD) >> 10); // >> 10 is less precise than /1023 but synthesizes faster and more efficiently 
    
    // Capture the lessThan signal on the negative edge after it has stabilized
    always @(negedge clk) begin
        signal <= lessThan;
    end
endmodule
