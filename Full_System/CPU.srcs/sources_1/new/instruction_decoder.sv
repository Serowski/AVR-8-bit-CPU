`timescale 1ns / 1ps

module instruction_decoder(
    input [15:0] i_instr,
    
    output logic [5:0] o_itype,
    output logic [4:0] o_rd_addr,
    output logic [4:0] o_rr_addr,
    output logic [7:0] o_imm,
    output logic [4:0] o_alu_op,
    output logic [15:0] o_pc
    );
    
    import avr_pkg::*;
    
    always_comb begin
        // Domyślne wartości
        o_itype = ITYPE_NOP;
        o_rd_addr = i_instr[8:4];
        o_rr_addr = {i_instr[9], i_instr[3:0]};
        o_alu_op = ALU_PASS;
        
        o_imm = '0;
        o_pc = '0;
        
        unique casez(i_instr)
            //NOP
            16'b0000_0000_0000_0000: begin
                o_itype = ITYPE_NOP;
            end
            //ADD
            16'b0000_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_ADD;
                o_alu_op = ALU_ADD;
            end
            //ADC
            16'b0001_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_ADC;
                o_alu_op = ALU_ADC;
            end
            //SUB
            16'b0001_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_SUB;
                o_alu_op = ALU_SUB;
            end
            //SBC
            16'b0000_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_SBC;
                o_alu_op = ALU_SBC;
            end
            //AND
            16'b0010_00zz_zzzz_zzzz: begin
                o_itype = ITYPE_AND;
                o_alu_op = ALU_AND;
            end
            //OR
            16'b0010_10zz_zzzz_zzzz: begin
                o_itype = ITYPE_OR;
                o_alu_op = ALU_OR;
            end
            //EOR
            16'b0010_01zz_zzzz_zzzz: begin
                o_itype = ITYPE_EOR;
                o_alu_op = ALU_EOR;
            end
            //INC
            16'b1001_010z_zzzz_0011: begin
                o_itype = ITYPE_INC;
                o_rr_addr = '0;
                o_alu_op = ALU_INC;
            end
            //DEC
            16'b1001_010z_zzzz_1010: begin
                o_itype = ITYPE_DEC;
                o_rr_addr = '0;
                o_alu_op = ALU_DEC;
            end
            //MOV  
            16'b0010_11zz_zzzz_zzzz: begin
                o_itype = ITYPE_MOV;
                o_alu_op = ALU_PASS;
            end
            //LDI
            16'b1110_zzzz_zzzz_zzzz: begin
                o_itype = ITYPE_LDI;
                o_rd_addr = {1'b1, i_instr[7:4]};
                o_rr_addr = '0;
                o_imm = {i_instr[11:8], i_instr[3:0]};
                o_alu_op = ALU_PASS;
            end
            //LDS
            16'b1001_000z_zzzz_0000: begin
                o_itype = ITYPE_LDS;
                o_rr_addr = '0;
            end
            //STS
            16'b1001_001z_zzzz_0000: begin
                o_itype = ITYPE_STS;
                o_rr_addr = '0;
            end
            //RJMP
            16'b1100_zzzz_zzzz_zzzz: begin
                o_itype = ITYPE_RJMP;
                o_rd_addr = '0;
                o_rr_addr = '0;
                o_pc = {{4{i_instr[11]}}, i_instr[11:0]};
            end
            //BREQ
            16'b1111_00zz_zzzz_z001: begin
                o_itype = ITYPE_BREQ;
                o_rd_addr = '0;
                o_rr_addr = '0;
                o_pc = {{9{i_instr[9]}} ,i_instr[9:3]};
            end
            //BRNE
            16'b1111_01zz_zzzz_z001: begin
                o_itype = ITYPE_BRNE;
                o_rd_addr = '0;
                o_rr_addr = '0;
                o_pc = {{9{i_instr[9]}} ,i_instr[9:3]};
            end
            //JMP
            16'b1001_010z_zzzz_110z: begin
                o_itype = ITYPE_JMP;
                o_rd_addr = '0;
                o_rr_addr = '0;
                o_pc = {i_instr[8:4], i_instr[0]};
            end
            
            default: o_itype = ITYPE_NOP;
        endcase
            
         
    end
endmodule
