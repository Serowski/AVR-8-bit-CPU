`timescale 1ns / 1ps

module tb_alu();

    logic [7:0] i_Rd;       
    logic [7:0] i_Rr;
    logic       i_C_in;
    logic [5:0] i_alu_op;
    logic [7:0] o_Res;  
    logic [5:0] o_Flag;
    
    alu uut(
        .i_Rd(i_Rd),
        .i_Rr(i_Rr),
        .i_C_in(i_C_in),
        .i_alu_op(i_alu_op),
        .o_Res(o_Res),
        .o_Flag(o_Flag)
    );
    
    initial begin
       i_Rd = 0;
       i_Rr = 0;
       i_C_in = 0;
       i_alu_op = 0;

       #10;
       i_Rd = 8'b11111111;
       i_Rr = 2;
       i_alu_op = 6'b000111;
       
       #10;
       i_Rd = 3;
       i_Rr = 4;
       i_alu_op = 1;
       
       #10;
       i_Rd = 5;
       i_Rr = 6;
       i_alu_op = 2;
       
       #10;
       i_Rd = 7;
       i_Rr = 8;
       i_alu_op = 3;
       
       #10;
       i_Rd = 9;
       i_Rr = 10;
       i_alu_op = 4;
       
       #10;
       i_Rd = 11;
       i_Rr = 12;
       i_alu_op = 5;
       
       #10;
       i_Rd = 13;
       i_Rr = 14;
       i_alu_op = 6;
       
       #10;
       i_Rd = 15;
       i_Rr = 16;
       i_alu_op = 7;
       
       #10;
       i_Rd = 17;
       i_Rr = 18;
       i_alu_op = 8;
       
       #10;
       i_Rd = 19;
       i_Rr = 20;
       i_alu_op = 9;
       
       #10;
       i_Rd = 21;
       i_Rr = 22;
       i_alu_op = 10;
        
    end
endmodule
