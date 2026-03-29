package avr_pkg;
    
    // Operacje dla ALU
    parameter int ALU_ADD = 0;
    parameter int ALU_ADC = 1;
    parameter int ALU_SUB = 2;
    parameter int ALU_SBC = 3;
    parameter int ALU_AND = 4;
    parameter int ALU_OR = 5;
    parameter int ALU_EOR = 6;
    parameter int ALU_INC = 7;
    parameter int ALU_DEC = 8;
    parameter int ALU_CLR = 9;
    parameter int ALU_SER = 10;

    
    // Flagi
    parameter int SREG_C = 0;
    parameter int SREG_Z = 1;
    parameter int SREG_N = 2;
    parameter int SREG_V = 3;
    parameter int SREG_S = 4;
    parameter int SREG_H = 5;
    parameter int SREG_T = 6;
    parameter int SREG_I = 7;
endpackage : avr_pkg
