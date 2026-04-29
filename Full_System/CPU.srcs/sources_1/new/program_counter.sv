`timescale 1ns / 1ps

module program_counter(
    input i_clk,
    input i_rst_n,
    // Sterowanie wartością pc 
    input [1:0] i_ctr_pc,
    input [15:0] i_load_val,
 
    output logic [15:0] o_pc
    );
    
    import avr_pkg::*;
    
    logic [15:0] sel_pc;
    // MUX wewnętrzby sterujący pc
    always_comb begin
        unique case(i_ctr_pc)
            PC_INC:      sel_pc = sel_pc + 1;
            PC_OFFSET:   sel_pc = sel_pc + i_load_val;
            PC_ABS_ADDR: sel_pc = i_load_val;
            PC_ZERO:     sel_pc = 16'h0000;
            default: sel_pc = sel_pc + 1;
        endcase
    end
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            o_pc <= 16'h0000;
        else 
            o_pc <= sel_pc; 
    end
endmodule
