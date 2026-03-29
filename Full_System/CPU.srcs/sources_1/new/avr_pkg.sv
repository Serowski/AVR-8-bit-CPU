package avr_pkg;
    
    // Operacje dla ALU
    typedef enum logic [5:0] {
        ADD = 6'b000000,
        ADC = 6'b000001,
        SUB = 6'b000010,
        SBC = 6'b000011,
        ANDD = 6'b000100,
        ORR = 6'b000101,
        EOR = 6'b000110,
        INC = 6'b000111,
        DEC = 6'b001000,
        CLR = 6'b001001,
        SER = 6'b001010
    }alu_op;
    
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
