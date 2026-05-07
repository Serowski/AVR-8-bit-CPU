`timescale 1ns / 1ps

module fsm_sequencer(
    input i_clk,
    input i_rst_n,
    
    // Wejścia z dekodera
    input [5:0] i_itype,
    input [4:0] i_rd_addr,
    
    // Wejscia z SREG
    input [7:0] i_flags,
    
    //Wejscia z Program Memory - STS, LDS
    input [15:0] i_ram_addr,
    
    // Wyjscia na register file
    output logic [4:0] o_wr_addr,
    output logic o_wr_en,
    
    // Wyjscia na MUX do ALU
    output logic [1:0] o_sel_alu,
     
    //Wyjscia na SREG
    output logic o_sreg_wr,
    
    //Wyjscia na Program Counter
    output logic [1:0] o_ctr_pc,
    output logic o_sel_id_rom,
    
    //Wyjscia na Data Memory
    output o_ram_we,
    output [15:0] o_ram_addr
    
    );
    import avr_pkg::*;
    

    logic [1:0] state;
    int next_state;
    // Rejestr stanu
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            state <= ST_FETCH;
        else
            state <= next_state;
    end
    // Przejścia stanów
    always_comb begin
        next_state = ST_FETCH;
        unique case(state)
            ST_FETCH:  next_state = ST_DECODE;
            ST_DECODE: next_state = ST_EXECUTE;
            ST_EXECUTE: begin
                case(i_itype)
                    ITYPE_LDS: next_state = ST_MEM;
                    ITYPE_STS: next_state = ST_MEM;
                    default: next_state = ST_FETCH;
                endcase
            end
            ST_MEM: next_state = ST_FETCH;
            default: next_state = ST_FETCH;
        endcase
    end
endmodule
