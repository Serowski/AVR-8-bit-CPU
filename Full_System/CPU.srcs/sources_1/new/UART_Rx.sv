`timescale 1ns / 1ps

module UART_Rx(
    input i_clk,
    input i_rst,
    input i_Rx_data,
    
    output logic [7:0] o_prog_data,
    output logic o_prog_we,
    output logic [12:0] o_prog_addr
    );
    
    import avr_pkg::*;
    
    // Rejestry pomocnicze
    logic [2:0] state;
    logic [10:0] clk_count;
    logic [2:0] bit_idx;
    logic [7:0] read_byte;
    logic prog_we;
    logic [12:0] addr_counter;
    
    // Podwójny rejestr na wchodzące dane
    // Eliminacja zjawiska metastabilności
    logic data_in, data;
    
    always_ff @(posedge i_clk) begin
        data_in <= i_Rx_data;
        data <= data_in;    
    end
    
    // Główna maszyna stanów — jeden blok always_ff
    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            state        <= UART_IDLE;
            clk_count    <= '0;
            bit_idx      <= '0;
            read_byte    <= '0;
            prog_we      <= 1'b0;
            addr_counter <= '0;
        end else begin
            prog_we <= 1'b0;
            
            case(state)
                UART_IDLE: begin
                    clk_count <= '0;
                    bit_idx   <= '0;
                    
                    if(data == 1'b0)
                        state <= UART_START_BIT;
                end
                
                UART_START_BIT: begin
                    if(clk_count == (UART_CLK_PER_BIT / 2)) begin
                        if(data == 1'b0) begin
                            clk_count <= '0;
                            state     <= UART_DATA_BITS;
                        end else begin
                            state <= UART_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                UART_DATA_BITS: begin
                    if(clk_count < UART_CLK_PER_BIT) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= '0;
                        read_byte[bit_idx] <= data;
                        
                        if(bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= '0;
                            state   <= UART_STOP_BIT;
                        end
                    end      
                end
                
                UART_STOP_BIT: begin
                    if(clk_count < UART_CLK_PER_BIT) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        prog_we   <= 1'b1;
                        clk_count <= '0;
                        state     <= UART_END;
                    end
                end
                
                UART_END: begin
                    prog_we      <= 1'b0;
                    addr_counter <= addr_counter + 1;
                    state        <= UART_IDLE;
                end
                
                default: state <= UART_IDLE; 
            endcase
        end
    end
    
    // Wyjścia — każdy sygnał ma dokładnie jedno źródło
    assign o_prog_data = read_byte;
    assign o_prog_we   = prog_we;
    assign o_prog_addr = addr_counter;
    
endmodule
