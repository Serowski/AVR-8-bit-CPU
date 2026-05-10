`timescale 1ns / 1ps

module fsm_sequencer(
    input i_clk,
    input i_rst_n,
    
    // Wejścia z dekodera
    input [5:0] i_itype,
    input [4:0] i_rd_addr,
    
    // Wejscia z SREG
    input [7:0] i_flags,
    
    // Wyjscia na register file
    output logic [4:0] o_wr_addr,
    output logic o_wr_en,
    
    // Wyjscia na MUX do ALU
    output logic [1:0] o_sel_alu,
     
    // Wyjscia na SREG
    output logic o_sreg_we,
    
    // Wyjscia na Program Counter
    output logic [1:0] o_ctr_pc,
    output logic o_sel_id_rom,
    
    // Wyjscia na Data Memory
    output logic o_ram_we,
    output logic o_ram_re,
    
    // Sygnalizacja stanu
    output logic o_decode_en
    
    );
    import avr_pkg::*;
    
    // Rejestr na stan maszyny
    logic [1:0] state;
    int next_state;

    // itype_reg - rejestr na typ instrukcji zapisany podczas ST_DECODE
    // Inaczej ROM wystawia już kolejną instrukcję w Execute i jest kiszka
    logic [5:0] itype_reg;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            itype_reg <= ITYPE_NOP;
        else if (state == ST_DECODE)
            itype_reg <= i_itype;  
    end

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
    
    // Generacja sygnałów sterujących
    always_comb begin
        // Wartości domyślne - wszystko wyłączone
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

            // ST_FETCH: ROM czyta PC i wystawia instrukcję pod tym adresem
            ST_FETCH: begin
                o_ctr_pc = PC_INC;
            end

            // ST_DECODE: Czekamy aż ROM wystawi instrukcję do odczytania przez dekoder
            ST_DECODE: begin
                o_ctr_pc = PC_HOLD;
            end

            // ST_EXECUTE: wykonuje instrukcję według ITYPE
            ST_EXECUTE: begin
                o_ctr_pc = PC_HOLD;

                case(itype_reg)       
                    ITYPE_ADD, ITYPE_ADC,
                    ITYPE_SUB, ITYPE_SBC,
                    ITYPE_AND, ITYPE_OR,
                    ITYPE_EOR, ITYPE_LSR,
                    ITYPE_ASR, ITYPE_ROR,
                    ITYPE_LSL, ITYPE_ROL: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG[1:0];
                        o_sreg_we = 1'b1;
                    end

                    ITYPE_INC, ITYPE_DEC: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG[1:0];
                        o_sreg_we = 1'b1;
                    end

                    ITYPE_LDI: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_IMM[1:0];
                        o_sreg_we = 1'b0;
                    end

                    ITYPE_MOV: begin
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_REG[1:0];
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

            // ST_MEM: dodatkowy stan na zapis/odczyt danych z RAM
            ST_MEM: begin
                o_ctr_pc = PC_HOLD;
                case(itype_reg)
                    ITYPE_LDS: begin
                        o_ram_re  = 1'b1;
                        o_wr_en   = 1'b1;
                        o_wr_addr = i_rd_addr;
                        o_sel_alu = ALU_RAM[1:0];
                        o_sreg_we = 1'b0;
                    end
                    ITYPE_STS: begin
                        o_ram_we  = 1'b1;
                    end
                    default: begin end
                endcase
            end

            default: begin
                // bezpieczny powrót — domyślne wszystko jest 0
            end
        endcase
    end
endmodule
