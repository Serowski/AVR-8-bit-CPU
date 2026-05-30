`timescale 1ns / 1ps

module UART_Tx(
    input        i_clk,
    input        i_rst,
    // Input byte to echo back
    input [7:0]  i_data,
    input        i_start,
    // Output serial echoed byte
    output logic o_Tx_data    
    );
    
    import avr_pkg::*;
    
    // Internal registers
    logic [2:0]  state;
    logic [10:0] clk_count;
    logic [2:0]  bit_idx;
    // Latched byte to send
    logic [7:0]  tx_shift;
    
    // Main FSM definition
    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            state     <= UART_IDLE;
            clk_count <= '0;
            bit_idx   <= '0;
            tx_shift  <= '0;
            o_Tx_data <= 1'b1;
        end else begin
            case(state)
                UART_IDLE: begin
                    o_Tx_data <= 1'b1;
                    clk_count <= '0;
                    bit_idx   <= '0;
                    
                    if(i_start) begin
                        tx_shift <= i_data;
                        state    <= UART_START_BIT;
                    end
                end
                
                UART_START_BIT: begin
                    o_Tx_data <= 1'b0;
                    
                    if(clk_count < UART_CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= '0;
                        state     <= UART_DATA_BITS;
                    end
                end
                
                UART_DATA_BITS: begin
                    o_Tx_data <= tx_shift[bit_idx];
                    
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
                    o_Tx_data <= 1'b1;
                    
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

