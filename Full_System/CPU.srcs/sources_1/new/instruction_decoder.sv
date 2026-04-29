`timescale 1ns / 1ps



module instruction_decoder(
    input [15:0] i_instr,
    
    output logic [5:0] o_itype,
    output logic [4:0] o_rd_addr,
    output logic [4:0] o_rr_addr,
    output logic [7:0] o_imm,
    output logic [5:0] o_alu_op,
    output logic [1:0] o_ctr_pc,
    output logic [15:0] o_pc,
    output logic [15:0] o_sram_addr
    );
    
    import avr_pkg::*;
    
    always_comb begin
        // Domyślne wartości
        o_itype = ITYPE_NOP;
        o_rd_addr = i_instr[8:4];
        o_rr_addr = {i_instr[9], i_instr[3:0]};
        o_imm = {i_instr[11:8], i_instr[3:0]};
        o_alu_op = ALU_PASS;
        o_ctr_pc = PC_INC;
        o_sram_addr = i_instr;
        o_pc = i_instr;
        
        unique casez(i_instr)
            //NOP
            16'b0000_0000_0000_0000: begin
                o_itype = ITYPE_NOP;
                o_ctr_pc = PC_INC;          
            end
            //ADD
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_ADD;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_ADD;
            end
            //ADC
            16'b0001_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_ADC;
            end
            //SUB
            16'b0001_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_SUB;
            end
            //SBC
            16'b0000_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_SBC;
            end
            //AND
            16'b0010_00zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_AND;
            end
            //OR
            16'b0010_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_OR;
            end
            //EOR
            16'b0010_01zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_EOR;
            end
            //INC
            16'b1001_010z_zzzz_0010: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_alu_op = ALU_INC;
            end
            //DEC
            16'b1001_010z_zzzz_1010: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_alu_op = ALU_DEC;
            end
            //CLR
            16'b0010_01zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[8:4];
                o_rr_addr = {i_instr[9], i_instr[3:0]};
                o_alu_op = ALU_CLR;
            end
            //SER
            16'b1110_1111_zzzz_1111: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[7:4];
                o_alu_op = ALU_SER;
            end
            //MOV  !!
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //LDI
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
                o_rd_addr = i_instr[7:4];
                o_imm = {i_instr[11:8], i_instr[3:0]};
            end
            //LDS
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //STS
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //RJMP
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //BREQ
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //BRNE
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            //JMP
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_ctr_pc = PC_INC;
            end
            
            default: o_itype = ITYPE_NOP;
        endcase
            
         
    end
endmodule
