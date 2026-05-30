`timescale 1ns / 1ps

module execution_unit(
    input               i_clk,
    input               i_rst_n,
    // Register File controls
    input               i_wr_en,
    input [4:0]         i_wr_addr,
    input [4:0]         i_rd_addr1,
    input [4:0]         i_rd_addr2,
    // MUX going to ALU control
    input [7:0]         i_imm,
    input [1:0]         i_sel_alu,
    // ALU control
    input [4:0]         i_alu_op,
    input               i_C_in,
    // SREG control
    input               i_sreg_we,
    // Program Counter control
    input [1:0]         i_ctr_pc,
    input [15:0]        i_load_val,
    // RAM data in
    input [7:0]         i_RAM,
    // Outputs
    output logic [7:0]  o_data,
    output logic [7:0]  o_Flag,
    output logic [15:0] o_pc
);
    
    import avr_pkg::*;
    
    // Internal connections
    logic [7:0] alu_flags;
    logic [7:0] rd_data1, rd_data2;
    logic [7:0] alu_result;
    logic [7:0] alu_input_sel;
    
    // MUX to choose data source entering ALU
    always_comb begin
        unique case (i_sel_alu)
            2'b00: alu_input_sel = rd_data2;  
            2'b01: alu_input_sel = i_imm;
            2'b10: alu_input_sel = i_RAM;
            2'b11: alu_input_sel = 8'h01;
        endcase
    end
    
    // Rd_data1 used as access point - storing to RAM
    always_comb begin
        o_data = rd_data1;
    end
    
    // Modules instances
    alu eu_alu(
        .i_Rd(rd_data1),
        .i_Rr(alu_input_sel),
        .i_C_in(i_C_in),
        .i_alu_op(i_alu_op),
        .o_Res(alu_result),
        .o_Flag(alu_flags)
    );
    
    reg_file eu_reg_file(
        .i_clk(i_clk),
        .i_rd_addr1(i_rd_addr1),
        .i_rd_addr2(i_rd_addr2),
        .o_rd_data1(rd_data1),
        .o_rd_data2(rd_data2),
        .i_wr_en(i_wr_en),
        .i_wr_addr(i_wr_addr),
        .i_wr_data(alu_result)
    );
    
    sreg eu_sreg(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sreg_we(i_sreg_we),
        .i_flags(alu_flags),
        .o_flags(o_Flag) 
    );
    
    program_counter eu_program_counter(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_ctr_pc(i_ctr_pc),
        .i_load_val(i_load_val),
        .o_pc(o_pc)
    );
    
endmodule
    
    

