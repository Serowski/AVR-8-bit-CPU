`timescale 1ns / 1ps


module tb_reg_file();

    localparam int ADDR_WIDTH = 5;
    localparam int D_WIDTH = 8;
    logic aclk;    
    // two read ports
    logic [ADDR_WIDTH-1:0] i_rd_addr1;
    logic [ADDR_WIDTH-1:0] i_rd_addr2;
    logic [D_WIDTH-1:0] o_rd_data1;
    logic [D_WIDTH-1:0] o_rd_data2;
        
    // single write port
    logic i_wr_en;
    logic [ADDR_WIDTH-1:0] i_wr_addr;
    logic [D_WIDTH-1:0] i_wr_data;
    
    reg_file #(
        .D_WIDTH(D_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REG_COUNT(32)
    )dut(
        .aclk(aclk),
        .i_rd_addr1(i_rd_addr1),
        .i_rd_addr2(i_rd_addr2), 
        .o_rd_data1(o_rd_data1), 
        .o_rd_data2(o_rd_data2),
        .i_wr_en(i_wr_en),
        .i_wr_addr(i_wr_addr),
        .i_wr_data(i_wr_data)         
    );
    
    
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end
    
    initial begin
        i_wr_en   = 0;
        i_wr_addr = 0;
        i_wr_data = 0;
        i_rd_addr1 = 0;
        i_rd_addr2 = 0;
        
        #10;
        i_rd_addr1 = 5'd16;
        i_rd_addr2 = 5'd17; 
        #10;

        $display("\n--- TEST 2: Write 0xAA to R16 ---");

        @(negedge aclk); 
        i_wr_en   = 1;
        i_wr_addr = 5'd01;    
        i_wr_data = 8'hAA;    
        
        @(negedge aclk); 
        i_wr_en   = 0;   
        
        i_rd_addr1 = 5'd01; 
        #10;

        
        $display("\n--- TEST 3: Write 0xBB to R17 and read two different registers ---");
        @(negedge aclk);
        i_wr_en   = 1;
        i_wr_addr = 5'd17;
        i_wr_data = 8'hBB;
        
        @(negedge aclk);
        i_wr_en   = 0;
        
        i_rd_addr1 = 5'd01; 
        i_rd_addr2 = 5'd17;
        #10;

        $display("\n--- TEST 4: Attempt write to R16 with i_wr_en = 0 (data should not change) ---");
        @(negedge aclk);
        i_wr_en   = 0;         
        i_wr_addr = 5'd01;
        i_wr_data = 8'hFF;  
        
        @(negedge aclk);
        i_rd_addr1 = 5'd01; 
        #10;

        $display("\nSimulation finished!");
        $finish;
    end
    
endmodule
