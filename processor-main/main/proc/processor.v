/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB,                   // I: Data from port B of RegFile

    // Wrapper Data Interfacing
    player_position_x_raw_in,              // I: Data From IMU
    player_position_y_raw_in,              // I: Data From IMU
    // player_position_out,               // O: Position data from player position register
    // box_position,                      // O: Position data of the box
	// game_state,                        // O: Game state data to the VGA
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    // Data Interfacing
    input [9:0] player_position_x_raw_in;
    input [9:0] player_position_y_raw_in;

	/* YOUR CODE STARTS HERE */

    // Instantiate mult_div_stall_en, when 1, stalls all programs, hazard_stall_en, when 1, stalls fetch and PC, flush_en, when 1, flushes FD/DX IR latches
    wire mult_div_stall_en, hazard_stall_en, flush_en;
    assign flush_en = valid_branch | valid_jump;

    // ================FETCH STAGE=================== //

    // Program Counter
    wire[31:0] final_pc, pc_after_check_branch, fd_pc_out, incremented_PC;
    wire incremented_PC_Cout;
    cla increment_PC(incremented_PC, incremented_PC_Cout, address_imem, 32'b1, 1'b0);
    
    // Assign PC
    assign pc_after_check_branch = valid_branch ? alu_pc_out : incremented_PC;
    assign final_pc = valid_jump ? jump_pc : pc_after_check_branch;

    // Mux to get new instruction
    wire[31:0] f_new_instruction;
    assign f_new_instruction = flush_en ? 32'b0 : q_imem;

    // Latch PC
    register #(.WIDTH(32)) LATCH_FD_PC(.q(fd_pc_out), .d(final_pc), .clk(~clock), .en(!(mult_div_stall_en | hazard_stall_en)), .clr(reset));
    
    // Assign PC
    assign address_imem = fd_pc_out;

    // Latch imem/fetch instruction
    wire[31:0] fd_ir_out;
    register #(.WIDTH(32)) LATCH_FD_IR(.q(fd_ir_out), .d(f_new_instruction), .clk(~clock), .en(!(mult_div_stall_en | hazard_stall_en)), .clr(reset));

    // ================DECODE STAGE=================== //

    // Decode RS
    assign ctrl_readRegA = fd_ir_out[21:17];

    // Decode RT if R type, RStatus if bex, otherwise Decode RD
    wire[4:0] ctrl_read_RT_RD;
    assign ctrl_read_RT_RD = fd_ir_out[31:27] == 5'b0 ? fd_ir_out[16:12] : fd_ir_out[26:22];
    assign ctrl_readRegB = fd_ir_out[31:27] == 5'b10110 ? 5'b11110 : ctrl_read_RT_RD;

    // Mux to get new instruction and data
    wire[31:0] d_new_instruction, d_new_data_A, d_new_data_B;
    assign d_new_instruction = hazard_stall_en | flush_en ? 32'b0 : fd_ir_out;
    assign d_new_data_A = hazard_stall_en | flush_en ? 32'b0 : data_readRegA;
    assign d_new_data_B = hazard_stall_en | flush_en ? 32'b0 : data_readRegB;

    // Latch data from RS
    wire[31:0] dx_A_out;
    register #(.WIDTH(32)) LATCH_DX_Register_A(.q(dx_A_out), .d(d_new_data_A), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch data from RT
    wire[31:0] dx_B_out;
    register #(.WIDTH(32)) LATCH_DX_Register_B(.q(dx_B_out), .d(d_new_data_B), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch PC
    wire[31:0] dx_pc_out;
    register #(.WIDTH(32)) LATCH_DX_PC(.q(dx_pc_out), .d(fd_pc_out), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch decode instruction
    wire[31:0] dx_ir_out;
    register #(.WIDTH(32)) LATCH_DX_IR(.q(dx_ir_out), .d(d_new_instruction), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // ================EXECUTE STAGE=================== //

    // Process data with ALU
    wire[31:0] alu_math_out, alu_pc_out, alu_A, alu_B, immediate;
    wire[4:0] shamt, alu_r_op, alu_op;
    wire alu_A_select, alu_B_select, alu_math_isNotEqual, alu_math_isLessThan, alu_math_overflow, alu_pc_isNotEqual, alu_pc_isLessThan, alu_pc_overflow;
    
    // Compute immediate + shamt
    assign immediate = {{15{dx_ir_out[16]}}, dx_ir_out[16:0]};
    assign shamt = dx_ir_out[11:7];

    // ALU_A, put in 32'b0 instead of alu_A_final_bypass_out for bex to compare to 0
    assign alu_A_select = dx_ir_out[31:27] == 5'b10110;
    assign alu_A = alu_A_select ? 32'b0 : alu_A_final_bypass_out;

    // ALU_B, put in alu_B_final_bypass_out instead of immediate for R type, bne, blt, and bex
    assign alu_B_select = dx_ir_out[31:27] == 5'b0 | dx_ir_out[31:27] == 5'b00010 | dx_ir_out[31:27] == 5'b00110 | dx_ir_out[31:27] == 5'b10110;
    assign alu_B = alu_B_select ? alu_B_final_bypass_out : immediate;

    // Assign alu_op if it's an R type instruction
    assign alu_r_op = dx_ir_out[6:2];
    assign alu_op = dx_ir_out[31:27] == 5'b0 ? alu_r_op : 5'b0;

    // ALU_math
    alu ALU_math(alu_A, alu_B, alu_op, shamt, alu_math_out, alu_math_isNotEqual, alu_math_isLessThan, alu_math_overflow);

    // Update x_new_instruction and x_new_output during exceptions
    wire[31:0] x_new_instruction, x_new_output;
    wire ovf_select, add_ovf_select, addi_ovf_select, sub_ovf_select;

    assign add_ovf_select = dx_ir_out[31:27] == 5'b0 & dx_ir_out[6:2] == 5'b0 & alu_math_overflow;
    assign addi_ovf_select = dx_ir_out[31:27] == 5'b00101 & alu_math_overflow;
    assign sub_ovf_select = dx_ir_out[31:27] == 5'b0 & dx_ir_out[6:2] == 5'b00001 & alu_math_overflow;
    assign ovf_select = add_ovf_select | addi_ovf_select | sub_ovf_select;

    tri_state_buffer_32 x_alu_ovf_insn(x_new_instruction, {dx_ir_out[31:27], 5'b11110, dx_ir_out[21:0]}, ovf_select);
    tri_state_buffer_32 x_add_output(x_new_output, 32'd1, add_ovf_select);
    tri_state_buffer_32 x_addi_output(x_new_output, 32'd2, addi_ovf_select);
    tri_state_buffer_32 x_sub_output(x_new_output, 32'd3, sub_ovf_select);


    // ====BRANCH==== //
    // Calculate and assign PC for bne and blt
    alu ALU_PC(dx_pc_out, immediate, 5'b0, 5'b0, alu_pc_out, alu_pc_isNotEqual, alu_pc_isLessThan, alu_pc_overflow);

    // get valid_branch + RD_less_than_RS from alu_math_isLessThan which is RS < RD
    wire valid_branch, RD_less_than_RS;
    assign RD_less_than_RS = !alu_math_isLessThan & alu_math_isNotEqual;
    assign valid_branch = (dx_ir_out[31:27] == 5'b00010 & alu_math_isNotEqual) | (dx_ir_out[31:27] == 5'b00110 & RD_less_than_RS);


    // ====JUMP==== //
    // Compute Target
    wire[31:0] T;
    assign T = {{5{1'b0}}, dx_ir_out[26:0]};

    // Assign PC for j, jal, jr
    wire jr_select;
    wire[31:0] jump_pc;

    assign jr_select = dx_ir_out[31:27] == 5'b00100;
    assign jump_pc = jr_select ? alu_B_final_bypass_out : T;

    // get valid_jump
    wire valid_standard_jump, valid_bex_jump, valid_jump;
    assign valid_standard_jump = dx_ir_out[31:27] == 5'b00001 | dx_ir_out[31:27] == 5'b00011 | dx_ir_out[31:27] == 5'b00100;
    assign valid_bex_jump = (dx_ir_out[31:27] == 5'b10110) & alu_math_isNotEqual;
    assign valid_jump = valid_standard_jump | valid_bex_jump;

    // Modify instruction + output for jal to write back
    wire jal_select;
    assign jal_select = dx_ir_out[31:27] == 5'b00011;
    
    tri_state_buffer_32 x_jal_insn(x_new_instruction, {dx_ir_out[31:27], 5'b11111, dx_ir_out[21:0]}, jal_select);
    tri_state_buffer_32 x_jal_output(x_new_output, dx_pc_out, jal_select);

    // Modify instruction + output for setx to write back
    wire setx_select;
    assign setx_select = dx_ir_out[31:27] == 5'b10101;
    
    tri_state_buffer_32 x_setx_insn(x_new_instruction, {dx_ir_out[31:27], 5'b11110, dx_ir_out[21:0]}, setx_select);
    tri_state_buffer_32 x_setx_output(x_new_output, T, setx_select);


    // ====MULT DIV==== //
    wire mult_div_default, mult_en, mult_en2, ctrl_mult, div_en, div_en2, ctrl_div, mult_div_exception, pulse_mult_div_exception, mult_div_result_rdy;
    wire[31:0] mult_div_out;

    assign mult_en = (dx_ir_out[31:27] == 5'b0) & (dx_ir_out[6:2] == 5'b00110) & !(mult_div_result_rdy === 1'b1);
    assign div_en = (dx_ir_out[31:27] == 5'b0) & (dx_ir_out[6:2] == 5'b00111) & !(mult_div_result_rdy === 1'b1);

    // Convert mult_en and div_en into pulse signal for multdiv module
    register #(.WIDTH(1)) LATCH_CTRL_MULT(.q(mult_en2), .d(mult_en), .clk(clock), .en(1'b1), .clr(reset));
    register #(.WIDTH(1)) LATCH_CTRL_MULT2(.q(ctrl_mult), .d(mult_en & !mult_en2), .clk(clock), .en(1'b1), .clr(reset));
    
    register #(.WIDTH(1)) LATCH_CTRL_DIV(.q(div_en2), .d(div_en), .clk(clock), .en(1'b1), .clr(reset));
    register #(.WIDTH(1)) LATCH_CTRL_DIV2(.q(ctrl_div), .d(div_en & !div_en2), .clk(clock), .en(1'b1), .clr(reset));

    // mult div
    multdiv MULTDIV(alu_A, alu_B, ctrl_mult, ctrl_div, clock, mult_div_out, mult_div_exception, mult_div_result_rdy);
    assign pulse_mult_div_exception = mult_div_exception & (mult_div_result_rdy === 1'b1);

    // Get mult_div_stall_en, note that mult_div_result_rdy is high Z or 1'b1
    assign mult_div_stall_en = (mult_en | div_en) & !(mult_div_result_rdy === 1'b1) ? 1'b1 : 1'b0;

    // Mux alu_math_out with mult_div_out
    wire[31:0] final_math_out;
    assign final_math_out = (mult_en2 | div_en2) ? mult_div_out : alu_math_out;

    // Modify x_new_instruction and x_new output during exceptions
    tri_state_buffer_32 x_mult_div_ovf_insn(x_new_instruction, {dx_ir_out[31:27], 5'b11110, dx_ir_out[21:0]}, (mult_en2 | div_en2) & pulse_mult_div_exception);
    tri_state_buffer_32 x_mult_output(x_new_output, 32'd4, mult_en2 & pulse_mult_div_exception);
    tri_state_buffer_32 x_div_output(x_new_output, 32'd5, div_en2 & pulse_mult_div_exception);

    // Modify x_new_output for custom instructions
    wire player_x_select, player_y_select;
    wire [31:0] player_position_x_raw, player_position_y_raw;
    assign player_position_x_raw = {{22{player_position_x_raw_in[9]}}, player_position_x_raw_in[9:0]};
    assign player_position_y_raw = {{23{player_position_y_raw_in[8]}}, player_position_y_raw_in[8:0]};
    assign player_x_select = (dx_ir_out[31:27] == 5'b0 & dx_ir_out[6:0] == 7'b0100000);
    assign player_y_select = (dx_ir_out[31:27] == 5'b0 & dx_ir_out[6:0] == 7'b0100001);
    tri_state_buffer_32 x_player_x_output(x_new_output, player_position_x, player_x_select);
    tri_state_buffer_32 x_player_y_output(x_new_output, player_position_y, player_y_select);

    // ====Execute Bypassing==== //
    wire M_update_RD, W_update_RD;
    assign M_update_RD = (xm_ir_out[31:27] == 5'b0) | (xm_ir_out[31:27] == 5'b00101);
    assign W_update_RD = (mw_ir_out[31:27] == 5'b0) | (mw_ir_out[31:27] == 5'b00101) | (mw_ir_out[31:27] == 5'b01000);

    // alu_A bypassing, forward from M or W stage
    wire X_use_RS;
    assign X_use_RS = (dx_ir_out[31:27] == 5'b0) | (dx_ir_out[31:27] == 5'b00101) | (dx_ir_out[31:27] == 5'b00111) | (dx_ir_out[31:27] == 5'b01000) | (dx_ir_out[31:27] == 5'b00010) | (dx_ir_out[31:27] == 5'b00110);

    // forward M/W's RD to X's alu_A if RD is not 0
    wire alu_A_MX_RD_bypass_select, alu_A_WX_RD_bypass_select;
    assign alu_A_MX_RD_bypass_select = M_update_RD & X_use_RS & (xm_ir_out[26:22] != 5'b0) & (xm_ir_out[26:22] == dx_ir_out[21:17]);
    assign alu_A_WX_RD_bypass_select = W_update_RD & X_use_RS & (mw_ir_out[26:22] != 5'b0) & (mw_ir_out[26:22] == dx_ir_out[21:17]);

    // forward M/W's R30 to X's alu_A
    wire alu_A_MX_R30_bypass_select, alu_A_WX_R30_bypass_select;
    assign alu_A_MX_R30_bypass_select = (xm_ir_out[31:27] == 5'b10101) & X_use_RS & (dx_ir_out[21:17] == 5'b11110);
    assign alu_A_WX_R30_bypass_select = (mw_ir_out[31:27] == 5'b10101) & X_use_RS & (dx_ir_out[21:17] == 5'b11110);

    // forward M/W's R31 to X's alu_A
    wire alu_A_MX_R31_bypass_select, alu_A_WX_R31_bypass_select;
    assign alu_A_MX_R31_bypass_select = (xm_ir_out[31:27] == 5'b00011) & X_use_RS & (dx_ir_out[21:17] == 5'b11111);
    assign alu_A_WX_R31_bypass_select = (mw_ir_out[31:27] == 5'b00011) & X_use_RS & (dx_ir_out[21:17] == 5'b11111);

    // finish alu_A bypass, prioritizing MX bypass over WX bypass
    wire alu_A_MX_final_bypass_select, alu_A_WX_final_bypass_select;
    wire[31:0] alu_A_WX_bypass_out, alu_A_final_bypass_out;

    assign alu_A_MX_final_bypass_select = alu_A_MX_RD_bypass_select | alu_A_MX_R30_bypass_select | alu_A_MX_R31_bypass_select;
    assign alu_A_WX_final_bypass_select = alu_A_WX_RD_bypass_select | alu_A_WX_R30_bypass_select | alu_A_WX_R31_bypass_select;

    assign alu_A_WX_bypass_out = alu_A_WX_final_bypass_select ? data_writeReg : dx_A_out;
    assign alu_A_final_bypass_out = alu_A_MX_final_bypass_select ? xm_O_out : alu_A_WX_bypass_out;


    // alu_B bypassing, forward from M or W stage
    wire X_use_RT, X_use_RD, X_use_R30;
    assign X_use_RT = (dx_ir_out[31:27] == 5'b0);
    assign X_use_RD = (dx_ir_out[31:27] == 5'b00111) | (dx_ir_out[31:27] == 5'b00010) | (dx_ir_out[31:27] == 5'b00100) | (dx_ir_out[31:27] == 5'b00110);
    assign X_use_R30 = (dx_ir_out[31:27] == 5'b10110);

    // forward M/W's RD to X's alu_B
    wire alu_B_MX_RD_bypass_select, alu_B_WX_RD_bypass_select;
    assign alu_B_MX_RD_bypass_select = M_update_RD & (xm_ir_out[26:22] != 5'b0) & ((X_use_RT & xm_ir_out[26:22] == dx_ir_out[16:12]) | (X_use_RD & xm_ir_out[26:22] == dx_ir_out[26:22]) | (X_use_R30 & xm_ir_out[26:22] == 5'b11110));
    assign alu_B_WX_RD_bypass_select = W_update_RD & (mw_ir_out[26:22] != 5'b0) & ((X_use_RT & mw_ir_out[26:22] == dx_ir_out[16:12]) | (X_use_RD & mw_ir_out[26:22] == dx_ir_out[26:22]) | (X_use_R30 & mw_ir_out[26:22] == 5'b11110));

    // forward M/W's R30 to X's alu_B
    wire alu_B_MX_R30_bypass_select, alu_B_WX_R30_bypass_select;
    assign alu_B_MX_R30_bypass_select = (xm_ir_out[31:27] == 5'b10101) & ((X_use_RT & dx_ir_out[16:12] == 5'b11110) | (X_use_RD & dx_ir_out[26:22] == 5'b11110) | (X_use_R30));
    assign alu_B_WX_R30_bypass_select = (mw_ir_out[31:27] == 5'b10101) & ((X_use_RT & dx_ir_out[16:12] == 5'b11110) | (X_use_RD & dx_ir_out[26:22] == 5'b11110) | (X_use_R30));

    // forward M/W's R31 to X's alu_B
    wire alu_B_MX_R31_bypass_select, alu_B_WX_R31_bypass_select;
    assign alu_B_MX_R31_bypass_select = (xm_ir_out[31:27] == 5'b00011) & ((X_use_RT & dx_ir_out[16:12] == 5'b11111) | (X_use_RD & dx_ir_out[26:22] == 5'b11111));
    assign alu_B_WX_R31_bypass_select = (mw_ir_out[31:27] == 5'b00011) & ((X_use_RT & dx_ir_out[16:12] == 5'b11111) | (X_use_RD & dx_ir_out[26:22] == 5'b11111));

    // finish alu_B bypassing, prioritizing MX bypass over WX bypass
    wire alu_B_MX_final_bypass_select, alu_B_WX_final_bypass_select;
    wire[31:0] alu_B_WX_bypass_out, alu_B_final_bypass_out;

    assign alu_B_MX_final_bypass_select = alu_B_MX_RD_bypass_select | alu_B_MX_R30_bypass_select | alu_B_MX_R31_bypass_select;
    assign alu_B_WX_final_bypass_select = alu_B_WX_RD_bypass_select | alu_B_WX_R30_bypass_select | alu_B_WX_R31_bypass_select;
    
    assign alu_B_WX_bypass_out = alu_B_WX_final_bypass_select ? data_writeReg : dx_B_out;
    assign alu_B_final_bypass_out = alu_B_MX_final_bypass_select ? xm_O_out : alu_B_WX_bypass_out;


    // ====Execute Stalling==== //
    wire D_use_RS, D_use_RD, hazard_stall_baseline, hazard_stall_RS_en, hazard_stall_RD_en, hazard_stall_R30_en;
    assign hazard_stall_baseline = (dx_ir_out[31:27] == 5'b01000) & (fd_ir_out[31:27] != 5'b00111);

    assign D_use_RS = (fd_ir_out[31:27] == 5'b0) | (fd_ir_out[31:27] == 5'b00101) | (fd_ir_out[31:27] == 5'b00111) | (fd_ir_out[31:27] == 5'b01000) | (fd_ir_out[31:27] == 5'b00010) | (fd_ir_out[31:27] == 5'b00110);
    assign D_use_RD = (fd_ir_out[31:27] == 5'b00111) | (fd_ir_out[31:27] == 5'b01000) | (fd_ir_out[31:27] == 5'b00010) | (fd_ir_out[31:27] == 5'b00100) | (fd_ir_out[31:27] == 5'b00110);
    
    assign hazard_stall_RS_en = hazard_stall_baseline & D_use_RS & ((fd_ir_out[21:17] == dx_ir_out[26:22]) | (fd_ir_out[16:12] == dx_ir_out[26:22]));
    assign hazard_stall_RD_en = hazard_stall_baseline & D_use_RD & (fd_ir_out[26:22] == dx_ir_out[26:22]);
    assign hazard_stall_R30_en = hazard_stall_baseline & (fd_ir_out[31:27] == 5'b10110) & (dx_ir_out[26:22] == 5'b11110);
    assign hazard_stall_en = hazard_stall_RS_en | hazard_stall_RD_en | hazard_stall_R30_en;

    // ====Latch + Instruction Handler==== //
    // Mux new instruction/output with original instruction/output
    // Note pulse_mult_div_exception is on for a whole cycle, but only want to use it until next falling edge to not mess up following instruction
    wire[31:0] x_instruction, x_output;
    assign x_instruction = (ovf_select | jal_select | setx_select | (pulse_mult_div_exception & clock)) ? x_new_instruction : dx_ir_out;
    assign x_output = (ovf_select | jal_select | setx_select | player_x_select | player_y_select | (pulse_mult_div_exception & clock)) ? x_new_output : final_math_out;

    // Latch execute output result
    wire[31:0] xm_O_out;
    register #(.WIDTH(32)) LATCH_ALU_O(.q(xm_O_out), .d(x_output), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch B value
    wire[31:0] xm_B_out;
    register #(.WIDTH(32)) LATCH_XM_B(.q(xm_B_out), .d(alu_B_final_bypass_out), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch execute instruction
    wire[31:0] xm_ir_out;
    register #(.WIDTH(32)) LATCH_XM_IR(.q(xm_ir_out), .d(x_instruction), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // ================MEMORY STAGE=================== //

    // Store/Load word address
    assign address_dmem = lw_sw_final_bypass_address_out;
    assign data = sw_final_bypass_data_out;

    // Enable dmem WE for Store Word, otherwise disable
    assign wren = xm_ir_out[31:27] == 5'b00111 ? 1'b1 : 1'b0;

    // ====Memory Bypassing==== //
    wire W_update_Data; // if instruction at W has updated RD
    assign W_update_Data = (mw_ir_out[31:27] == 5'b0) | (mw_ir_out[31:27] == 5'b00101) | (mw_ir_out[31:27] == 5'b01000);

    // SW bypassing, forward from W stage
    wire M_use_Data;
    assign M_use_Data = (xm_ir_out[31:27] == 5'b00111) | (xm_ir_out[31:27] == 5'b01000);

    // forward W's output to M's data
    wire sw_bypass_data_select, lw_sw_bypass_address_select;
    assign sw_bypass_data_select = W_update_Data & (xm_ir_out[31:27] == 5'b00111) & (mw_ir_out[26:22] == xm_ir_out[26:22]);
    assign lw_sw_bypass_address_select = W_update_Data & M_use_Data & (mw_ir_out[26:22] == xm_ir_out[21:17]) & (xm_ir_out[16:0] == 17'b0);

    // finish SW bypassing
    wire[31:0] sw_final_bypass_data_out, lw_sw_final_bypass_address_out;
    assign sw_final_bypass_data_out = sw_bypass_data_select ? data_writeReg : xm_B_out;
    assign lw_sw_final_bypass_address_out = lw_sw_bypass_address_select ? data_writeReg : xm_O_out;


    // Latch data from dmem
    wire[31:0] mw_D_out;
    register #(.WIDTH(32)) LATCH_MW_D(.q(mw_D_out), .d(q_dmem), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch alu out from xm again
    wire[31:0] mw_O_out;
    register #(.WIDTH(32)) LATCH_MW_O(.q(mw_O_out), .d(xm_O_out), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // Latch memory instruction
    wire[31:0] mw_ir_out;
    register #(.WIDTH(32)) LATCH_MW_IR(.q(mw_ir_out), .d(xm_ir_out), .clk(~clock), .en(!mult_div_stall_en), .clr(reset));

    // ================WRITEBACK STAGE=================== //

    // Set destination register
    assign ctrl_writeReg = mw_ir_out[26:22];

    // Create write selects
    wire write_lw_select, write_R_type_select, write_addi_select, write_jal_select, write_setx_select;
    assign write_lw_select = mw_ir_out[31:27] == 5'b01000;
    assign write_R_type_select = mw_ir_out[31:27] == 5'b0;
    assign write_addi_select = mw_ir_out[31:27] == 5'b00101;
    assign write_jal_select = mw_ir_out[31:27] == 5'b00011;
    assign write_setx_select = mw_ir_out[31:27] == 5'b10101;

    // Set write data
    assign data_writeReg = write_lw_select ? mw_D_out : mw_O_out;

    // Write to RD only if it's LW or R type or addi or jal or setx instruction
    assign ctrl_writeEnable = write_lw_select | write_R_type_select | write_addi_select | write_jal_select | write_setx_select;

	/* END CODE */

endmodule
