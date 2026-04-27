`timescale 1ns / 1ps



module instruction_decoder(
    input [15:0] i_instr,
    
    output logic [4:0] o_itype,
    output logic [4:0] o_rd_addr,
    output logic [4:0] o_rr_addr,
    output logic [7:0] o_imm,
    output logic [15:0] o_sram_addr,
    output logic [15:0] o_pc_val
    );
    
    import avr_pkg::*;
    
    always_comb begin
        // Domyślne wartości
        o_itype = ITYPE_NOP;
        o_rd_addr = i_instr[8:4];
        o_rr_addr = {i_instr[9], i_instr[3:0]};
        o_imm = {i_instr[11:8], i_instr[3:0]};
        o_sram_addr = i_instr;
        o_pc_val = i_instr[11:0];
        
        unique casez(i_instr)
            //NOP
            16'b0000_0000_0000_0000: begin
            
            end
            //AND
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //ADC
            16'b0001_11zz_zzzz_zzzz: begin
                
            end
            //SUB
            16'b0001_10zz_zzzz_zzzz: begin
                
            end
            //SBC
            16'b0000_10zz_zzzz_zzzz: begin
                
            end
            //AND
            16'b0010_00zz_zzzz_zzzz: begin
                
            end
            //OR
            16'b0010_10zz_zzzz_zzzz: begin
                
            end
            //EOR
            16'b0010_01zz_zzzz_zzzz: begin
                
            end
            //INC
            16'b1001_010z_zzzz_0010: begin
                
            end
            //DEC
            16'b1001_010z_zzzz_1010: begin
                
            end
            //CLR
            16'b0010_01zz_zzzz_zzzz: begin
                
            end
            //SER
            16'b1110_1111_zzzz_1111: begin
                
            end
            //MOV
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //LDI
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //LDS
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //STS
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //RJMP
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //BREQ
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //BRNE
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
            //JMP
            16'b0000_11zz_zzzz_zzzz: begin
                
            end
        endcase
            
         
    end
endmodule
