module alu(
    input [7:0] i_Rd,       
    input [7:0] i_Rr,
    input       i_C_in,
    input  [5:0] i_alu_op,
    output logic [7:0] o_Res,  
    output logic [5:0] o_Flag  
);
    import avr_pkg::*;
    
    logic [8:0] f_Res;
    
    always_comb begin
        
        o_Res = 8'h00;
        o_Flag = 6'b000000;
        
        case(i_alu_op)
            ALU_ADD: begin
                f_Res = {1'b0, i_Rd} + {1'b0, i_Rr};       
                 
            end
            ALU_ADC: begin
                f_Res = {1'b0, i_Rd} + {1'b0, i_Rr} + i_C_in;  
            end
            ALU_SUB: begin
                f_Res = {1'b0, i_Rd} - {1'b0, i_Rr};     
            end   
            ALU_SBC: begin
                f_Res = {1'b0, i_Rd} - {1'b0, i_Rr} - i_C_in;  
            end
            ALU_AND: begin
                f_Res[7:0] = i_Rd & i_Rr;
            end         
            ALU_OR: begin 
                f_Res[7:0] = i_Rd | i_Rr;        
            end
            ALU_EOR: begin
                f_Res[7:0] = i_Rd ^ i_Rr;        
            end
            ALU_INC: begin
                f_Res[7:0] = i_Rd + 8'h01;           
            end
            ALU_DEC: begin
                f_Res[7:0] = i_Rd - 8'h01;            
            end
            ALU_CLR: begin
                f_Res[7:0] = 8'h00;              
            end
            ALU_SER: begin
                f_Res[7:0] = 8'hFF;               
            end
            ALU_PASS: begin
                f_Res[7:0] = i_Rr;               
            end
            default: f_Res[7:0] = '0;
        endcase
        
        // Przepisanie wyniku 
        o_Res = f_Res[7:0];
        
        // Flagi wspólne
        o_Flag[SREG_Z] = (o_Res == 8'h00);
        o_Flag[SREG_N] = o_Res[7];
        o_Flag[SREG_C] = o_Flag[SREG_C] | f_Res[8];
        o_Flag[SREG_S] = o_Flag[SREG_N] ^ o_Flag[SREG_V]; 
    end
endmodule
