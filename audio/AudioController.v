module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
	input[15:0]   switches,
    output       audioOut,	// PWM signal to the audio jack	
    output       audioEn);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency

	assign audioEn = switches[15];  // Enable Audio Output

	// Initialize the frequency array
	reg[10:0] FREQs[0:31];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end

	// Initialize counter
	reg noteClock = 0;
	wire[4:0] noteIndex;
	count_32 note_counter(.out(noteIndex), .en(1'b1), .clk(noteClock), .clr(1'b0));

	// Compute Note Duty Cycle Clock
	reg[17:0] periodLimit = 12*MHz; // half of desired period to switch notes
	reg[17:0] periodCounter = 0;

	reg editedClock = 0;
	reg[17:0] noteCounterLimit;
	reg[17:0] counter = 0;

	always @(posedge clk) begin
		if (periodCounter < periodLimit) begin
			periodCounter <= periodCounter + 1;

			noteCounterLimit <= (SYSTEM_FREQ / (2 * FREQs[switches[4:0]])) - 1;
			if (counter < noteCounterLimit)
				counter <= counter + 1;
			else begin
				counter <= 0;
				editedClock <= ~editedClock;
			end
		end
		else begin
			periodCounter <= 0;
			noteClock <= ~noteClock;
		end
	end

	// Generate Note Output
	wire [9:0] audio_duty_cycle;
	assign audio_duty_cycle = editedClock ? 10'd1023 : 10'd0;

	PWMSerializer serialize(.clk(clk),.reset(1'b0), .duty_cycle(audio_duty_cycle), .signal(audioOut));

endmodule