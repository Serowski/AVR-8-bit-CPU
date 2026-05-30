`timescale 1ns / 1ps

module program_memory(
    input               i_clk,
    // PORT A - 4096 bytes of addressable words 
    input [11:0]        i_pc_addr,
    output logic [15:0] o_instruction,
    // PORT B - 8192 bytes to write to 
    input  logic [12:0] i_uart_addr,
    input  logic [7:0]  i_uart_data,
    input  logic        i_uart_we
);

    // BRAM memory initialization
    logic [15:0] memory_array [0:4095];

    // UART write control signals
    logic [11:0] word_addr;
    logic        byte_select;

    // Bits [12:1] - address of 16-bit word in memory 
    // Bit  [0]    - low or high part a the 16-bit word
    assign word_addr   = i_uart_addr[12:1];
    assign byte_select = i_uart_addr[0];
    
    // Synchronous read/write from ROM
    always_ff @(posedge i_clk) begin
        // PORT B: Write bytes from UART 
        if (i_uart_we) begin
            if (byte_select == 1'b0) begin
                // Low byte write
                memory_array[word_addr][7:0] <= i_uart_data;
            end else begin
                // High byte write
                memory_array[word_addr][15:8] <= i_uart_data;
            end
        end
        // PORT A: Read instruction 
        o_instruction <= memory_array[i_pc_addr];
        
    end

    // Possible to initialize ROM memory from .mem file
    initial begin
        // $readmemh("xxx.mem", memory_array);
    end

endmodule
