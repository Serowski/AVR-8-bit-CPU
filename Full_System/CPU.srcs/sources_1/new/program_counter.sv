`timescale 1ns / 1ps

module program_counter(
    input i_clk,
    input i_rst_n,
    input i_load,
    input [15:0] i_load_val,
    input i_inc,
    output logic [15:0] o_pc
    );
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            o_pc <= 16'h0000;
        else if(i_load)
            o_pc <= i_load_val;
        else if(i_inc)
            o_pc <= o_pc + 1'b1;
    end
endmodule
