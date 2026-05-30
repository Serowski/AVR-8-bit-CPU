`timescale 1ns / 1ps

module control_unit(
    input               i_clk,
    input               i_rst_n,
    // ROM instruction input 
    input [15:0]        i_instr,
    // Input flags from SREG
    input [7:0]         i_flags,
    // Execution Unit controls
    output logic [4:0]  o_rd_addr1,
    output logic [4:0]  o_rr_addr,
    output logic [7:0]  o_imm,
    output logic [4:0]  o_alu_op,
    output logic [15:0] o_load_val,
    // Register File controls
    output logic [4:0]  o_wr_addr,
    output logic        o_wr_en,
    // Controls for MUX going to ALU
    output logic [1:0]  o_sel_alu,
    // SREG control
    output logic        o_sreg_we,
    // Program Counter controls
    output logic [1:0]  o_ctr_pc,
    // Data Memory controls
    output logic        o_ram_we,
    output logic        o_ram_re
    );
    
    import avr_pkg::*;
    
    // Internal connections
    logic [5:0]  itype;
    logic [4:0]  rd_addr;
    logic        sel_id_rom;
    logic [15:0] pc_val;       
    // FSM signal to latch instruction during ST_DECODE
    logic        decode_en;
    
    assign o_rd_addr1 = rd_addr;
    
    // MUX controlling PC value: Offset/Absolute Value
    always_comb begin
        case(sel_id_rom)
            1'b0: o_load_val = pc_val;
            1'b1: o_load_val = i_instr;
        endcase
    end
    
    // Modules instances
    fsm_sequencer cu_fsm_sequencer(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_itype(itype),
        .i_rd_addr(rd_addr),
        .i_flags(i_flags),
        .o_wr_addr(o_wr_addr),   
        .o_wr_en(o_wr_en),
        .o_sel_alu(o_sel_alu),
        .o_sreg_we(o_sreg_we),
        .o_ctr_pc(o_ctr_pc),
        .o_sel_id_rom(sel_id_rom),
        .o_ram_we(o_ram_we),
        .o_ram_re(o_ram_re),
        .o_decode_en(decode_en)
    );
     
    // Register to prevent instruction drift
    // ROM generates new instruction during EXECUTE cycle
    // It latches previous instruction
    logic [15:0] instr_reg;
    always_ff @(posedge i_clk) begin
        if (decode_en) begin
            instr_reg <= i_instr;
        end
    end
    
    // MUX to latch instruction only during DECODE
    logic [15:0] instr_for_dec;
    assign instr_for_dec = decode_en ? i_instr : instr_reg;
    
    instruction_decoder cu_instruction_decoder(
        .i_instr(instr_for_dec),
        .o_itype(itype),
        .o_rd_addr(rd_addr),
        .o_rr_addr(o_rr_addr),
        .o_imm(o_imm),
        .o_alu_op(o_alu_op),
        .o_pc(pc_val)
    );
endmodule
