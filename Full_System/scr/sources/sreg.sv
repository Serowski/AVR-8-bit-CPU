`timescale 1ns / 1ps

module sreg(
    // Zegar i reset
    input i_clk,
    input i_rst_n,
    // Write Enable dla niektórych instrukcji
    input i_sreg_we,
    input [7:0] i_flags,
    
    output logic [7:0] o_flags 
    );
    
    // Synchroniczny zapis Flag
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            o_flags <= 8'h00;
        else if(i_sreg_we)
            o_flags <= i_flags;
    end
endmodule
