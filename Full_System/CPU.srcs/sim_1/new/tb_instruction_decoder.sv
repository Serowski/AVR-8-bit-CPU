`timescale 1ns / 1ps


module tb_instruction_decoder;
    import avr_pkg::*;
    
    logic [15:0] instr;
    
    logic [5:0] itype;
    logic [4:0] rd_addr;
    logic [4:0] rr_addr;
    logic [7:0] imm;
    logic [4:0] alu_op;
    logic [15:0] pc;
    
    instruction_decoder dut(
        .i_instr(instr),
        .o_itype(itype),
        .o_rd_addr(rd_addr),
        .o_rr_addr(rr_addr),
        .o_imm(imm),
        .o_alu_op(alu_op),
        .o_pc(pc)
    );
    
    int pass_count = 0;
    int fail_count = 0;

    task automatic check(
        input string      test_name,
        input logic [5:0] got_itype,
        input logic [5:0] exp_itype,
        input logic [4:0] got_rd,
        input logic [4:0] exp_rd,
        input logic [4:0] got_rr,
        input logic [4:0] exp_rr,
        input logic [7:0] got_imm,
        input logic [7:0] exp_imm,
        input logic [4:0] got_aluop,
        input logic [4:0] exp_aluop,
        input logic [15:0] got_pc,
        input logic [15:0] exp_pc
    );
        if (got_itype === exp_itype && got_rd === exp_rd && got_rr === exp_rr && got_imm === exp_imm &&
            got_aluop === exp_aluop && got_pc === exp_pc) begin
            $display("[PASS] %-35s", test_name);
            pass_count++;
        end else begin
            $display("[FAIL] %-35s", test_name);
            if (got_itype !== exp_itype)
                $display("         itype  : got=0x%04h  exp=0x%04h", got_itype, exp_itype);
            if (got_rd !== exp_rd)
                $display("         rd : got=0b%04h  exp=0b%04h", got_rd, exp_rd);
            if (got_rr !== exp_rr)
                $display("         rr  : got=0x%04h  exp=0x%04h", got_rr, exp_rr);
            if (got_imm !== exp_imm)
                $display("         imm : got=0b%04h  exp=0b%04h", got_imm, exp_imm);
            if (got_aluop !== exp_aluop)
                $display("         aluop  : got=0x%04h  exp=0x%04h", got_aluop, exp_aluop);
            if (got_pc !== exp_pc)
                $display("         pc : got=0b%04h  exp=0b%04h", got_pc, exp_pc);

            fail_count++;
        end
    endtask
    
    initial begin
        instr = 16'h0000;   //NOP
        #10;
        instr = 16'h1C10;   //ADC r1, r0
        #10;
        check("ADC r1,r0", 
                itype, ITYPE_ADC,
                rd_addr, R1,
                rr_addr, R0,
                imm, '0,
                alu_op, ALU_ADC,
                pc, '0      
         );
        instr = 16'h1823;   //sub r2, r3
        #10;
        check("SUB r2,r3", 
                itype, ITYPE_SUB,
                rd_addr, R2,
                rr_addr, R3,
                imm, '0,
                alu_op, ALU_SUB,
                pc, '0      
         );
        instr = 16'h0845;   //sbc r4, r5
        #10;
        check("SBC r4,r5", 
                itype, ITYPE_SBC,
                rd_addr, R4,
                rr_addr, R5,
                imm, '0,
                alu_op, ALU_SBC,
                pc, '0      
         );
        instr = 16'h2067;   //and r6, r7
        #10;
        check("AND r6,r7", 
                itype, ITYPE_AND,
                rd_addr, R6,
                rr_addr, R7,
                imm, '0,
                alu_op, ALU_AND,
                pc, '0      
         );
        instr = 16'h2889;   //or r8, r9
        #10;
        check("OR r8,r9", 
                itype, ITYPE_OR,
                rd_addr, R8,
                rr_addr, R9,
                imm, '0,
                alu_op, ALU_OR,
                pc, '0      
         );
        instr = 16'h24AB;   //eor r10, r11
        #10;
        check("EOR r10,r11", 
                itype, ITYPE_EOR,
                rd_addr, R10,
                rr_addr, R11,
                imm, '0,
                alu_op, ALU_EOR,
                pc, '0      
         );
        instr = 16'h94C3;   //inc r12
        #10;
        check("INC R12", 
                itype, ITYPE_INC,
                rd_addr, R12,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_INC,
                pc, '0      
         );
        instr = 16'h94DA;   //dec r13
        #10;
        check("DEC R13", 
                itype, ITYPE_DEC,
                rd_addr, R13,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_DEC,
                pc, '0      
         );
        instr = 16'h2EF0;   //mov r15, r16
        #10;
        check("MOV r15,r16", 
                itype, ITYPE_MOV,
                rd_addr, R15,
                rr_addr, R16,
                imm, '0,
                alu_op, ALU_PASS,
                pc, '0      
         );
        instr = 16'hE313;   //ldi r17, 0x33
        #10;
        check("LDI r17,0x33", 
                itype, ITYPE_LDI,
                rd_addr, R17,
                rr_addr, '0,
                imm, 8'h33,
                alu_op, ALU_PASS,
                pc, '0      
         );
        instr = 16'h9120;   //lds r18, 0xAAAA
        #10;
        check("LDS r18,0xAAAA", 
                itype, ITYPE_LDS,
                rd_addr, R18,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, '0      
         );
        instr = 16'hAAAA;   //
        #10;
        instr = 16'h9330;   //sts 0xBBBB, r19
        #10;
        check("STS 0xBBBB,r19", 
                itype, ITYPE_STS,
                rd_addr, R19,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, '0      
         );
        instr = 16'hBBBB;   //
        #10;
        instr = 16'hC0CB;   //rjmp 0x00CC
        #10;
        check("RJMP 0x00CC", 
                itype, ITYPE_RJMP,
                rd_addr, '0,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, 16'h00CB      
         );
        instr = 16'hF089;   //breq 0x22
        #10;
        check("BREQ 0x22", 
                itype, ITYPE_BREQ,
                rd_addr, '0,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, 16'h0011      
         );
        instr = 16'hF7F9;   //brne 0x11
        #10;
        check("BRNE 0x11", 
                itype, ITYPE_BRNE,
                rd_addr, '0,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, 16'hffff      
         );
        instr = 16'h940C;   //jmp 0xDDDD
        #10;
        check("JMP 0xDDDD", 
                itype, ITYPE_JMP,
                rd_addr, '0,
                rr_addr, '0,
                imm, '0,
                alu_op, ALU_PASS,
                pc, 16'h0000      
         );
        instr = 16'hDDDD;   //
        #10;
        
        $display("=========================================");
        $display("  PASS: %0d  |  FAIL: %0d", pass_count, fail_count);
        $display("=========================================");
        $display("");
        $finish;
    end

endmodule
