`timescale 1ns / 1ps

module UART_Tx(
    input i_clk,
    input i_rst,
    input [7:0] i_data,        // Bajt do wysłania
    input       i_start,       // Puls startu transmisji (podłącz do UART_Rx.o_prog_we)
    
    output logic o_Tx_data     // Linia szeregowa TX
    );
    
    import avr_pkg::*;
    
    // Rejestry pomocnicze
    logic [2:0]  state;
    logic [10:0] clk_count;
    logic [2:0]  bit_idx;
    logic [7:0]  tx_shift;     // Zatrzaśnięty bajt do wysłania
    
    // Główna maszyna stanów
    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            state     <= UART_IDLE;
            clk_count <= '0;
            bit_idx   <= '0;
            tx_shift  <= '0;
            o_Tx_data <= 1'b1;     // Linia IDLE = HIGH
        end else begin
            case(state)
                UART_IDLE: begin
                    o_Tx_data <= 1'b1;     // Linia IDLE = HIGH
                    clk_count <= '0;
                    bit_idx   <= '0;
                    
                    if(i_start) begin
                        tx_shift <= i_data;    // Zatrzaśnij bajt
                        state    <= UART_START_BIT;
                    end
                end
                
                UART_START_BIT: begin
                    o_Tx_data <= 1'b0;     // Bit START = LOW
                    
                    if(clk_count < UART_CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= '0;
                        state     <= UART_DATA_BITS;
                    end
                end
                
                UART_DATA_BITS: begin
                    o_Tx_data <= tx_shift[bit_idx];    // LSB first
                    
                    if(clk_count < UART_CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= '0;
                        
                        if(bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= '0;
                            state   <= UART_STOP_BIT;
                        end
                    end
                end
                
                UART_STOP_BIT: begin
                    o_Tx_data <= 1'b1;     // Bit STOP = HIGH
                    
                    if(clk_count < UART_CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= '0;
                        state     <= UART_IDLE;
                    end
                end
                
                default: state <= UART_IDLE;
            endcase
        end
    end
    
endmodule

