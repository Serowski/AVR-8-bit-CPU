`timescale 1ns / 1ps

module fsm_sequencer(
    input              i_clk,
    input              i_rst_n,
    // Inputs from instruction decoder
    input [5:0]        i_itype,
    input [4:0]        i_rd_addr,
    // Input flags from SREG
    input [7:0]        i_flags,
    // Register File controls
    output logic [4:0] o_wr_addr,
    output logic       o_wr_en,
    // Controls for MUX going to ALU
    output logic [1:0] o_sel_alu,
    // SREG control
    output logic       o_sreg_we,
    // Program Counter controls
    output logic [1:0] o_ctr_pc,
    output logic       o_sel_id_rom,
    // Data Memory controls
    output logic       o_ram_we,
    output logic       o_ram_re,
    // State signal
    output logic       o_decode_en
    );
    
    import avr_pkg::*;
    
    // FSM state register
    logic [1:0] state;
    int next_state;

    // Register for instruction latched during DECODE
    logic [5:0] itype_reg;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            itype_reg <= ITYPE_NOP;
        else if (state == ST_DECODE)
            itype_reg <= i_itype;  
    end

    // FSM
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            state <= ST_FETCH;
        else
            state <= next_state;
    end
    
    // FSM - state transitions
    always_comb begin
        next_state = ST_FETCH;
        unique case(state)
            ST_FETCH:  next_state = ST_DECODE;
            ST_DECODE: next_state = ST_EXECUTE;
            ST_EXECUTE: begin
                case(itype_reg)        
                    ITYPE_LDS: next_state = ST_MEM;
                    ITYPE_STS: next_state = ST_MEM;
                    default:   next_state = ST_FETCH;
                endcase
            end
            ST_MEM: next_state = ST_FETCH;
            default: next_state = ST_FETCH;
        endcase
    end
    
    // Control signal generation
    always_comb begin
        // Default values
        o_wr_addr    = 5'd0;
        o_wr_en      = 1'b0;
        o_sel_alu    = ALU_REG[1:0];
        o_sreg_we    = 1'b0;
        o_ctr_pc     = PC_HOLD;
        o_sel_id_rom = 1'b0;
        o_ram_we     = 1'b0;
        o_ram_re     = 1'b0;
        o_decode_en  = (state == ST_DECODE);

        unique case(state)
            // ST_FETCH: ROM reads PC and outputs instruction corresponding to the address
            ST_FETCH: begin
                o_ctr_pc = PC_INC;
            end

            // ST_DECODE: One cycle wait state for BRAM used in ROM to output the instruction
            ST_DECODE: begin
                o_ctr_pc = PC_HOLD;
            end

            // ST_EXECUTE: execute instruction according to ITYPE
            ST_EXECUTE: begin
                o_ctr_pc = PC_HOLD;

                case(itype_reg)       
                    ITYPE_ADD, ITYPE_ADC,
                    ITYPE_SUB, ITYPE_SBC,
                    ITYPE_AND, ITYPE_OR,
                    ITYPE_EOR, ITYPE_LSR,
                    ITYPE_ASR, ITYPE_ROR,
                    ITYPE_LSL, ITYPE_ROL,
                    ITYPE_COM, ITYPE_NEG,
                    ITYPE_INC, ITYPE_DEC: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG;
                        o_sreg_we = 1'b1;
                    end
                    /*
                    ITYPE_INC, ITYPE_DEC: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG[1:0];
                        o_sreg_we = 1'b1;
                    end
                    */
                    ITYPE_LDI: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_IMM;
                        o_sreg_we = 1'b0;
                    end

                    ITYPE_MOV: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG;
                        o_sreg_we = 1'b0;
                    end

                    ITYPE_RJMP: begin
                        o_ctr_pc     = PC_OFFSET;
                        o_sel_id_rom = 1'b0;
                    end

                    ITYPE_JMP: begin
                        o_ctr_pc     = PC_ABS_ADDR;
                        o_sel_id_rom = 1'b1; 
                    end

                    ITYPE_BREQ: begin
                        if (i_flags[SREG_Z]) begin
                            o_ctr_pc     = PC_OFFSET;
                            o_sel_id_rom = 1'b0;
                        end
                    end

                    ITYPE_BRNE: begin
                        if (!i_flags[SREG_Z]) begin
                            o_ctr_pc     = PC_OFFSET;
                            o_sel_id_rom = 1'b0;
                        end
                    end

                    ITYPE_LDS: begin
                        o_ctr_pc     = PC_INC;
                        o_sel_id_rom = 1'b1;
                        o_ram_re     = 1'b1;
                    end

                    ITYPE_STS: begin
                        o_ctr_pc     = PC_INC;
                        o_sel_id_rom = 1'b1;
                    end

                    ITYPE_NOP: begin end

                    default: begin end
                endcase
            end

            // ST_MEM: additional state to read/write data from RAM
            ST_MEM: begin
                o_ctr_pc = PC_HOLD;
                case(itype_reg)
                    ITYPE_LDS: begin
                        o_ram_re  = 1'b1;
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_RAM;
                        o_sreg_we = 1'b0;
                    end
                    ITYPE_STS: begin
                        o_ram_we  = 1'b1;
                    end
                    default: begin end
                endcase
            end

            default: begin
                // safe return to default - everything 0
            end
        endcase
    end
endmodule
