module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // add your code here:

    wire[31:0] ADD, SUB, AND, OR, NOT_B, SLL, SRA;
    wire Cout_add, Cout_sub;

    // ADD, SUB

    not_32 not_B(NOT_B, data_operandB);
    cla cla1(ADD, Cout_add, data_operandA, data_operandB, 1'd0);
    cla cla2(SUB, Cout_sub, data_operandA, NOT_B, 1'd1);

    // AND, OR, SLL, SRA

    and_32 AND32(AND, data_operandA, data_operandB);
    or_32 OR32(OR, data_operandA, data_operandB);
    sll SLL1(SLL, data_operandA, ctrl_shiftamt);
    sra SRA1(SRA, data_operandA, ctrl_shiftamt);

    // equality

    wire check_eq1, check_eq2, check_eq3, check_eq4;
    or eq1(check_eq1, SUB[0], SUB[1], SUB[2], SUB[3], SUB[4], SUB[5], SUB[6], SUB[7]);
    or eq2(check_eq2, SUB[8], SUB[9], SUB[10], SUB[11], SUB[12], SUB[13], SUB[14], SUB[15]);
    or eq3(check_eq3, SUB[16], SUB[17], SUB[18], SUB[19], SUB[20], SUB[21], SUB[22], SUB[23]);
    or eq4(check_eq4, SUB[24], SUB[25], SUB[26], SUB[27], SUB[28], SUB[29], SUB[30], SUB[31]);
    or eq5(isNotEqual, check_eq1, check_eq2, check_eq3, check_eq4);
    
    // overflow

    wire ovf1, ovf2, ovf3, ovf4, not_op1, not_op2, is_sub;
    not not1(not_op1, ctrl_ALUopcode[1]);
    not not2(not_op2, ctrl_ALUopcode[2]);
    and get_is_sub(is_sub, ctrl_ALUopcode[0], not_op1, not_op2);

    wire not_A_msb, not_B_msb, not_add_msb, not_sub_msb, is_add;
    not get_is_add(is_add, is_sub);
    not msb_A(not_A_msb, data_operandA[31]);
    not msb_B(not_B_msb, data_operandB[31]);
    not Cout_a(not_add_msb, ADD[31]);
    not Cout_s(not_sub_msb, SUB[31]);

    and get_ovf1(ovf1, is_add, not_A_msb, not_B_msb, ADD[31]);
    and get_ovf2(ovf2, is_add, data_operandA[31], data_operandB[31], not_add_msb);
    and get_ovf3(ovf3, is_sub, not_A_msb, data_operandB[31], SUB[31]);
    and get_ovf4(ovf4, is_sub, data_operandA[31], not_B_msb, not_sub_msb);
    or get_ovf(overflow, ovf1, ovf2, ovf3, ovf4);
    
    // less than
    
    wire no_ovf_less_than, not_ovf3, exclude_ovf3_less_than;
    not get_not_ovf3(not_ovf3, ovf3);
    assign no_ovf_less_than = SUB[31] ? 1 : 0; // isLessThan value without overflows
    or exclude_ovf3(exclude_ovf3_less_than, no_ovf_less_than, ovf4); // ovf if ovf4 or isLessThan without overflow
    and get_less_than(isLessThan, exclude_ovf3_less_than, not_ovf3); // not less than if ovf3 happens

    // output

    mux_8 mux(data_result, ctrl_ALUopcode[2:0], ADD, SUB, AND, OR, SLL, SRA, 0, 0);

endmodule