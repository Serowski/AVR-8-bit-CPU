`timescale 1ns / 1ps

module data_memory(
    input i_clk,
    input i_rst_n,
    
    // Połaczenie z CPU
    input [15:0] i_addr,
    input [7:0] i_data,
    input i_we,
    input i_re,
    output logic [7:0] o_rdata
    
    // Piny GPIO
    );
    
    // Inicjalizujemy 2048 bajtów pamięci RAM  
    logic [7:0] sram [0:2047];
    logic [7:0] sram_rdata;
    
    // Zapis i odczyt synchroniczny -> używane bloki BRAM 
    always_ff @(posedge i_clk) begin
        if(i_we)
            sram[i_addr] <= i_data;
        if(i_re)
            sram_rdata <= sram[i_addr];
    end
    
    assign o_rdata = sram_rdata;
    
endmodule
