`timescale 1ns / 1ps


module execution_unit(
    // Ogólne sygnały
    input i_clk,
    input i_rst_n,
    // Plik rejestrów
    input i_wr_en,
    input [4:0] i_wr_addr,
    input [4:0] i_rd_addr1,
    input [4:0] i_rd_addr2,
    // MUX do wyboru wejścia do alu
    input [7:0] i_imm,
    input i_sel,
    // Sygnały ALU
    input [5:0] i_alu_op,
    // Sygnały SREG
    input i_sreg_we,
    // Sygnały program counter
    input i_load,
    input [15:0] i_load_val,
    input i_inc,
    //Wyjścia
    output logic [7:0] o_data,
    output logic [7:0] o_Flag,
    output logic [15:0] o_pc
);
    
    import avr_pkg::*;
    
    
    
    
endmodule
