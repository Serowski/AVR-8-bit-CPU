`timescale 1ns / 1ps

module UART_top(
    input i_clk,
    input i_rst,
    input i_Rx_data,
    
    output logic [7:0] o_uart_data,
    output logic [12:0] o_uart_addr,
    output logic o_uart_we,
    output logic o_Tx_data
    );
    
    // Połączenia wewnętrzne
    logic r_uart_we;
    logic [7:0] r_data;
    
    always_comb begin
        o_uart_data = r_data;
        o_uart_we   = r_uart_we;
    end
    
    // Instancje modułów
    UART_Rx u_UART_Rx(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_Rx_data(i_Rx_data),
        .o_prog_data(r_data),
        .o_prog_we(r_uart_we),
        .o_prog_addr(o_uart_addr)
    );
    
    UART_Tx u_UART_Tx(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(r_data),
        .i_start(r_uart_we),
        .o_Tx_data(o_Tx_data)
    );
endmodule
