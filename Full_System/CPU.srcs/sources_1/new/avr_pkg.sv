package avr_pkg;
    
    // Operacje dla ALU
    parameter int ALU_ADD =  5'd0;
    parameter int ALU_ADC =  5'd1;
    parameter int ALU_SUB =  5'd2;
    parameter int ALU_SBC =  5'd3;
    parameter int ALU_AND =  5'd4;
    parameter int ALU_OR =   5'd5;
    parameter int ALU_EOR =  5'd6;
    parameter int ALU_INC =  5'd7;
    parameter int ALU_DEC =  5'd8;
    parameter int ALU_CLR =  5'd9;
    parameter int ALU_SER =  5'd10;
    parameter int ALU_PASS = 5'd11;
    parameter int ALU_COM =  5'd12;
    parameter int ALU_NEG =  5'd13;
    parameter int ALU_LSR =  5'd14;
    parameter int ALU_ASR =  5'd15;
    parameter int ALU_ROR =  5'd16;
    parameter int ALU_LSL =  5'd17;
    parameter int ALU_ROL =  5'd18;

    
    // Flagi    I - T - H - S - V - N - Z - C 
    parameter int SREG_C = 0;
    parameter int SREG_Z = 1;
    parameter int SREG_N = 2;
    parameter int SREG_V = 3;
    parameter int SREG_S = 4;
    parameter int SREG_H = 5;
    parameter int SREG_T = 6;
    parameter int SREG_I = 7;
    
    // Rejestry R0:R31
    parameter int R0 = 5'd0;
    parameter int R1 = 5'd1;
    parameter int R2 = 5'd2;
    parameter int R3 = 5'd3;
    parameter int R4 = 5'd4;
    parameter int R5 = 5'd5;
    parameter int R6 = 5'd6;
    parameter int R7 = 5'd7;
    parameter int R8 = 5'd8;
    parameter int R9 = 5'd9;
    parameter int R10 = 5'd10;
    parameter int R11 = 5'd11;
    parameter int R12 = 5'd12;
    parameter int R13 = 5'd13;
    parameter int R14 = 5'd14;
    parameter int R15 = 5'd15;
    parameter int R16 = 5'd16;
    parameter int R17 = 5'd17;
    parameter int R18 = 5'd18;
    parameter int R19 = 5'd19;
    parameter int R20 = 5'd20;
    parameter int R21 = 5'd21;
    parameter int R22 = 5'd22;
    parameter int R23 = 5'd23;
    parameter int R24 = 5'd24;
    parameter int R25 = 5'd25;
    parameter int R26 = 5'd26;
    parameter int R27 = 5'd27;
    parameter int R28 = 5'd28;
    parameter int R29 = 5'd29;
    parameter int R30 = 5'd30;
    parameter int R31 = 5'd31;
    
    // ALU Mux do wejścia Rr
    parameter int ALU_REG =  2'b00;
    parameter int ALU_IMM =  2'b01;
    parameter int ALU_RAM = 2'b10;
    parameter int ALU_ONE =  2'b11;
    
    // Typy instrukcji:
    parameter int ITYPE_NOP =  6'd0;
    parameter int ITYPE_ADD =  6'd1;
    parameter int ITYPE_ADC =  6'd2;
    parameter int ITYPE_SUB =  6'd3;
    parameter int ITYPE_SBC =  6'd4;
    parameter int ITYPE_AND =  6'd5;
    parameter int ITYPE_OR =   6'd6;
    parameter int ITYPE_EOR =  6'd7;
    parameter int ITYPE_INC =  6'd8;
    parameter int ITYPE_DEC =  6'd9;
    parameter int ITYPE_MOV =  6'd10;
    parameter int ITYPE_LDI =  6'd11;
    parameter int ITYPE_LDS =  6'd12;
    parameter int ITYPE_STS =  6'd13;
    parameter int ITYPE_RJMP = 6'd14;
    parameter int ITYPE_BREQ = 6'd15;
    parameter int ITYPE_BRNE = 6'd16;
    parameter int ITYPE_JMP =  6'd17;
    parameter int ITYPE_COM =  6'd18;
    parameter int ITYPE_NEG =  6'd19;
    parameter int ITYPE_LSR =  6'd20;
    parameter int ITYPE_ASR =  6'd21;
    parameter int ITYPE_ROR =  6'd22;
    parameter int ITYPE_LSL =  6'd23;
    parameter int ITYPE_ROL =  6'd24;
    
    // Sterowanie PC
    parameter int PC_HOLD     = 2'b00;
    parameter int PC_INC      = 2'b01;
    parameter int PC_OFFSET   = 2'b10;
    parameter int PC_ABS_ADDR = 2'b11;
    
    // Stany FSM
    parameter int ST_FETCH =   2'b00;
    parameter int ST_DECODE =  2'b01;
    parameter int ST_EXECUTE = 2'b10;
    parameter int ST_MEM =     2'b11;
    
endpackage : avr_pkg
