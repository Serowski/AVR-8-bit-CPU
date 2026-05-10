`timescale 1ns / 1ps

module cpu_top (
    input        i_clk,
    input        i_rst_n,
    // GPIO...
    inout  [7:0] io_gpio
);
    import avr_pkg::*;

    // Sygnały wewnętrzne
    wire [15:0] w_instr;        
    wire [15:0] w_pc;           
    wire [7:0]  w_flags;        
    wire [7:0]  w_ram_rdata;    
    wire [7:0]  w_eu_data;     
    
    wire [4:0]  w_rd_addr1, w_rr_addr;
    wire [4:0]  w_wr_addr;
    wire        w_wr_en;
    wire [1:0]  w_sel_alu;
    wire [4:0]  w_alu_op;
    wire        w_sreg_we;
    wire [7:0]  w_imm;
    wire [1:0]  w_ctr_pc;
    wire [15:0] w_load_val;
    wire        w_ram_we, w_ram_re;

    program_memory u_program_memory (
        .i_clk        (i_clk),
        .i_pc_addr    (w_pc[11:0]),     
        .o_instruction(w_instr),
        // PORT B  UART bootloader
        .i_uart_addr  (13'h0000),
        .i_uart_data  (8'h00),
        .i_uart_we    (1'b0)
    );


    control_unit u_control_unit (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_instr     (w_instr),         
        .i_flags     (w_flags),         
        .o_rd_addr1  (w_rd_addr1),      
        .o_rr_addr   (w_rr_addr),      
        .o_wr_addr   (w_wr_addr),
        .o_wr_en     (w_wr_en),
        .o_sel_alu   (w_sel_alu),
        .o_alu_op    (w_alu_op),
        .o_imm       (w_imm),
        .o_ctr_pc    (w_ctr_pc),
        .o_load_val  (w_load_val),      
        .o_sreg_we   (w_sreg_we),
        .o_ram_we    (w_ram_we),
        .o_ram_re    (w_ram_re)
    );

    execution_unit u_execution_unit (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_wr_en     (w_wr_en),
        .i_wr_addr   (w_wr_addr),
        .i_rd_addr1  (w_rd_addr1),     
        .i_rd_addr2  (w_rr_addr),     
        .i_imm       (w_imm),
        .i_sel_alu   (w_sel_alu),
        .i_alu_op    (w_alu_op),
        .i_C_in      (w_flags[0]),      
        .i_sreg_we   (w_sreg_we),
        .i_ctr_pc    (w_ctr_pc),
        .i_load_val  (w_load_val),
        .i_RAM       (w_ram_rdata),
        .o_data      (w_eu_data),      
        .o_Flag      (w_flags),         
        .o_pc        (w_pc)            
    );

    data_memory u_data_memory (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_addr  (w_instr),         
        .i_data  (w_eu_data),       
        .i_we    (w_ram_we),
        .i_re    (w_ram_re),
        .o_rdata (w_ram_rdata)    
    );

endmodule
