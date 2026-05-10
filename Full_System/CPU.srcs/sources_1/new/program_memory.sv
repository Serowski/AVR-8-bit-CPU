`timescale 1ns / 1ps

module program_memory(
    input i_clk,
    // PORT A - odczyt instrukcji dla 4096 słów
    input [11:0] i_pc_addr,
    output logic [15:0] o_instruction,

    // PORT B - do zapisu przez UART - 8192 bajty
    input  logic [12:0] i_uart_addr,
    input  logic [7:0]  i_uart_data,
    input  logic        i_uart_we
);

    // Inicjalizacja BRAM
    logic [15:0] memory_array [0:4095];

    // Sygnały do sterowania zapisem z UART
    logic [11:0] word_addr;
    logic        byte_select;

    // 12 górnych bitów to adres 16-bitowego słowa w pamięci
    // 1 najmłodszy bit (LSB) mówi nam, czy to lewa czy prawa połówka (bajt)
    assign word_addr   = i_uart_addr[12:1];
    assign byte_select = i_uart_addr[0];
    
    // Synchroniczny zapis i odczyt z ROM
    always_ff @(posedge i_clk) begin
        // PORT B: Zapis z UART 
        if (i_uart_we) begin
            if (byte_select == 1'b0) begin
                // Zapis młodszego bajtu
                memory_array[word_addr][7:0] <= i_uart_data;
            end else begin
                // Zapis starszego bajtu
                memory_array[word_addr][15:8] <= i_uart_data;
            end
        end
        // PORT A: Odczyt instrukcji 
        o_instruction <= memory_array[i_pc_addr];
        
    end

    // Inicjalizacja pamięci plikiem .mem
    initial begin
        // $readmemh("moj_program.mem", memory_array);
    end

endmodule
