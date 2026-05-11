`timescale 1ns / 1ps

module tb_execution_unit;

    import avr_pkg::*;

    logic        clk;
    logic        rst_n;
    logic        wr_en;
    logic [4:0]  wr_addr;
    logic [4:0]  rd_addr1;
    logic [4:0]  rd_addr2;
    logic [7:0]  imm;
    logic [1:0]  sel_alu;
    logic [5:0]  alu_op;
    logic        C_in;
    logic        sreg_we;
    logic        pc_load;
    logic [15:0] load_val;
    logic        pc_inc;
    logic [7:0]  o_data;
    logic [7:0]  o_Flag;
    logic [15:0] o_pc;


    execution_unit dut (
        .i_clk      (clk),
        .i_rst_n    (rst_n),
        .i_wr_en    (wr_en),
        .i_wr_addr  (wr_addr),
        .i_rd_addr1 (rd_addr1),
        .i_rd_addr2 (rd_addr2),
        .i_imm      (imm),
        .i_sel_alu  (sel_alu),
        .i_alu_op   (alu_op),
        .i_C_in     (C_in),
        .i_sreg_we  (sreg_we),
        .i_load     (pc_load),
        .i_load_val (load_val),
        .i_inc      (pc_inc),
        .o_data     (o_data),
        .o_Flag     (o_Flag),
        .o_pc       (o_pc)
    );


    initial clk = 1'b0;
    always #5 clk = ~clk;


    task automatic eu_ldi(
        input logic [4:0] reg_addr,
        input logic [7:0] value
    );
        wr_en    = 1'b1;
        wr_addr  = reg_addr;
        sel_alu  = ALU_IMM;   
        alu_op   = ALU_PASS;
        imm      = value;
        sreg_we  = 1'b0;   
        rd_addr1 = 5'd0;   
        rd_addr2 = 5'd0;   
        @(negedge clk);     
        wr_en    = 1'b0;    
    endtask


    task automatic eu_add(
        input logic [4:0] reg_dst,
        input logic [4:0] reg_rd,
        input logic [4:0] reg_rr
    );
        pc_inc = 1'b1;
        wr_en    = 1'b1;
        wr_addr  = reg_dst;
        rd_addr1 = reg_rd;  
        rd_addr2 = reg_rr;  
        sel_alu  = ALU_REG;    
        alu_op   = ALU_ADD;
        imm      = 8'h00;
        sreg_we  = 1'b1;    
        @(negedge clk);     
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        pc_inc = 1'b0;
    endtask

    task automatic eu_and(
        input logic [4:0] reg_dst,
        input logic [4:0] reg_rd,
        input logic [4:0] reg_rr
    );
        pc_inc = 1'b1;
        wr_en    = 1'b1;
        wr_addr  = reg_dst;
        rd_addr1 = reg_rd;   
        rd_addr2 = reg_rr;   
        sel_alu  = ALU_REG;   
        alu_op   = ALU_AND;
        imm      = 8'h00;
        sreg_we  = 1'b1;    
        @(negedge clk);     
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        pc_inc = 1'b0;
    endtask

    task automatic eu_read(
        input  logic [4:0] reg_addr,
        output logic [7:0] out_data,
        output logic [7:0] out_flags
    );
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        rd_addr1 = reg_addr;
        sel_alu  = ALU_REG;    
        alu_op   = ALU_PASS; 
        @(negedge clk);     
        out_data  = o_data; 
        out_flags = o_Flag;
    endtask


    task automatic eu_idle(input int n);
        wr_en   = 1'b0;
        sreg_we = 1'b0;
        repeat(n) @(negedge clk);
    endtask


    int pass_count = 0;
    int fail_count = 0;

    task automatic check(
        input string      test_name,
        input logic [7:0] got_data,
        input logic [7:0] exp_data,
        input logic [7:0] got_flags,
        input logic [7:0] exp_flags
    );
        if (got_data === exp_data && got_flags === exp_flags) begin
            $display("[PASS] %-35s | data=0x%02h | flags=0b%08b",
                     test_name, got_data, got_flags);
            pass_count++;
        end else begin
            $display("[FAIL] %-35s", test_name);
            if (got_data !== exp_data)
                $display("         data  : got=0x%02h  exp=0x%02h", got_data, exp_data);
            if (got_flags !== exp_flags)
                $display("         flags : got=0b%08b  exp=0b%08b", got_flags, exp_flags);
            fail_count++;
        end
    endtask


    logic [7:0] result_data;
    logic [7:0] result_flags;

    initial begin

        rst_n    = 1'b0;
        wr_en    = 1'b0;
        wr_addr  = 5'd0;
        rd_addr1 = 5'd0;
        rd_addr2 = 5'd0;
        imm      = 8'h00;
        sel_alu  = 2'b00;
        alu_op   = ALU_ADD;
        C_in     = 1'b0;
        sreg_we  = 1'b0;
        pc_load  = 1'b0;
        load_val = 16'h0000;
        pc_inc   = 1'b0;

        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        $display("=========================================");
        $display("  Testbench: execution_unit ");
        $display("=========================================");


        eu_ldi(R1, 8'h0F);             
        eu_ldi(R2, 8'h05);          
        eu_and(R1, R1, R2);        
        eu_read(R1, result_data, result_flags);
        check("TC1: 0b00001111 & 0x00000101 = 0x00000101",
              result_data,  8'h05,
              result_flags, 8'b0000_0000);
        eu_idle(2);


        eu_ldi(R3, 8'hC8);              
        eu_ldi(R4, 8'h64);              
        eu_add(R3, R3, R4);         
        eu_read(R3, result_data, result_flags);
        check("TC2: 0xC8 + 0x64 = 0x2C, C=1",
              result_data,  8'h2C,
              result_flags, 8'b0000_0001);
        eu_idle(2);

        eu_ldi(R4, 8'h00);             
        eu_ldi(R5, 8'h00);            
        eu_add(R4, R4, R5);       
        eu_read(R4, result_data, result_flags);
        check("TC3: 0x00 + 0x00 = 0x00, Z=1",
              result_data,  8'h00,
              result_flags, 8'b0000_0010);
        eu_idle(2);

        eu_ldi(R6, 8'h7F);             
        eu_ldi(R7, 8'h01);              
        eu_add(R6, R6, R7);      
        eu_read(R6, result_data, result_flags);
        check("TC4: 0x7F + 0x01 = 0x80, N=1 S=1",
              result_data,  8'h80,
              result_flags, 8'b0001_0100);
        eu_idle(3);

        $display("=========================================");
        $display("  PASS: %0d  |  FAIL: %0d", pass_count, fail_count);
        $display("=========================================");
        $finish;
    end

endmodule
