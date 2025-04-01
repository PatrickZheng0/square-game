`timescale 1ns / 100ps
module add_sub_tb;
    wire[32:0] S_add, S_sub, Exp_add, Exp_sub;
    wire Cout_add, Cout_sub, Eq_add, Eq_sub;
    wire[32:0] A, B;

    integer Ai, Bi, C, i;
    assign A = {Ai, C[0]};
    assign B = {Bi, C[1]};

    assign Exp_add = A + B;
    assign Eq_add = Exp_add == S_add;

    assign Exp_sub = A - B;
    assign Eq_sub = Exp_sub == S_sub;

    // assign A = 32'd4294967295;
    // assign B = 32'd4294967295;

    add_33 a_add_33(S_add, Cout_add, A, B);
    sub_33 a_sub_33(S_sub, Cout_sub, A, B);

    initial begin
        for (i = 0; i < 10; i = i+1) begin
            Ai = $random;
            Bi = $random;
            C = $random;
            
            #20;
            // $display("A:%b, B:%b, => S_add:%b, Exp_add:%b, Eq_add:%b, S_sub:%b, Exp_sub:%b, Eq_sub:%b", A, B, S_add, Exp_add, Eq_add, S_sub, Exp_sub, Eq_sub);
            $display("A:%b, B:%b, => Eq_add:%b, Eq_sub:%b", A, B, Eq_add, Eq_sub);
        end
        $finish;
    end
endmodule