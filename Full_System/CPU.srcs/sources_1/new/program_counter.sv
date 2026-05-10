`timescale 1ns / 1ps

module program_counter(
    input i_clk,
    input i_rst_n,
    // Sterowanie wartością PC 
    input [1:0] i_ctr_pc,
    input [15:0] i_load_val,
 
    output logic [15:0] o_pc
    );
    
    import avr_pkg::*;
    
    // Wewnętrzny rejestr - PC register
    logic [15:0] sel_pc;
    
    // MUX wewnętrzny sterujący PC
    always_comb begin
        unique case(i_ctr_pc)
            PC_HOLD:     sel_pc = o_pc;              // PC bez zmian
            PC_INC:      sel_pc = o_pc + 16'd1;      // PC + 1
            PC_OFFSET:   sel_pc = o_pc + i_load_val; // PC + offset ze znakiem 
            PC_ABS_ADDR: sel_pc = i_load_val;        // Adres bezwzględny 
            default:     sel_pc = o_pc;
        endcase
    end
    
    // Synchroniczna zmiana licznika 
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            o_pc <= 16'h0000;
        else 
            o_pc <= sel_pc; 
    end
endmodule
