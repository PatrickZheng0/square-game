module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
	input[15:0]   switches,
    output       audioOut,	// PWM signal to the audio jack	
    output       audioEn);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 25*MHz; // System clock frequency

	assign audioEn = switches[15];  // Enable Audio Output

	// Initialize the frequency array
	reg[10:0] FREQs[0:31];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end

	// Initialize counter
	reg[4:0] noteIndex = 0;

	// Compute Note Duty Cycle Clock
	reg[31:0] periodLimit = SYSTEM_FREQ/3; // period to switch notes
	reg[31:0] periodCounter = 0;

	reg editedClock = 0;
	reg[17:0] counter = 0;

	wire [17:0] noteCounterLimit = (SYSTEM_FREQ / (2 * FREQs[noteIndex])) - 1;

	always @(posedge clk) begin
		if (periodCounter < periodLimit)
			periodCounter <= periodCounter + 1;
		else begin
			periodCounter <= 0;
			noteIndex <= noteIndex + 1;
			if (noteIndex == 32)
				noteIndex <= 0;
		end

		if (counter < noteCounterLimit)
			counter <= counter + 1;
		else begin
			counter <= 0;
			editedClock <= ~editedClock;
		end
	end

	// Generate Note Output
	wire [9:0] audio_duty_cycle;
	assign audio_duty_cycle = editedClock ? 10'd1023 : 10'd0;

	PWMSerializer serialize(.clk(clk),.reset(1'b0), .duty_cycle(audio_duty_cycle), .signal(audioOut));

endmodule