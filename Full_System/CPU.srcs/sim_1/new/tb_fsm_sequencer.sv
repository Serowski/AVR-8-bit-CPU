`timescale 1ns / 1ps


module tb_fsm_sequencer();
    logic clk;
    logic rst;
    logic [5:0] itype;
    logic [1:0] state;
    
    
    fsm_sequencer dut(
        .i_clk(clk),
        .i_rst_n(rst),
        .i_itype(itype),
        .state(state)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        rst = 1'b1;
        itype = '0;
        
        @(negedge clk);
        
        
    
    end

endmodule
