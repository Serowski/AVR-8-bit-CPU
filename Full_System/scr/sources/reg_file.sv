`timescale 1ns / 1ps

module reg_file#(
    // USELESS parameter definitions - dont care to remove them
    parameter int D_WIDTH = 8,
    parameter int ADDR_WIDTH = 5,
    parameter int REG_COUNT = 32
)(
    input logic                  i_clk,
    
    // Two ports for reading data
    input logic [ADDR_WIDTH-1:0] i_rd_addr1,
    input logic [ADDR_WIDTH-1:0] i_rd_addr2,
    output logic [D_WIDTH-1:0]   o_rd_data1,
    output logic [D_WIDTH-1:0]   o_rd_data2,
    
    // One port to write data
    input logic                  i_wr_en,
    input logic [ADDR_WIDTH-1:0] i_wr_addr,
    input logic [D_WIDTH-1:0]    i_wr_data       
);
    // Memory declaration
    logic [D_WIDTH-1:0] regs [0:REG_COUNT-1];
    
    // LUTRAM memory initialization
    initial begin
        for(int i = 0; i < REG_COUNT; i++) begin
            regs[i] = '0;
        end
    end
    
    // Asynchronous read
    always_comb begin
        o_rd_data1 = regs[i_rd_addr1];
        o_rd_data2 = regs[i_rd_addr2];
    end
    
    // Synchronous write
    always_ff @(posedge i_clk) begin
        if(i_wr_en) begin
            regs[i_wr_addr] <= i_wr_data;
        end
    end
endmodule
