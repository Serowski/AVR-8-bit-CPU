`timescale 1ns / 1ps

module cpu_top (
    input        i_clk,
    input        i_rst_n,
    // UART
    //input i_uart_data,
    // GPIO...
    inout  [31:0] io_gpio
    //output logic [5:0] o_leds
);
    import avr_pkg::*;
    
    // Sygnały wewnętrzne
    logic [15:0] w_instr;        
    logic [15:0] w_pc;           
    logic [7:0]  w_flags;        
    logic [7:0]  w_ram_rdata;    
    logic [7:0]  w_eu_data;     
    
    logic [4:0]  w_rd_addr1, w_rr_addr;
    logic [4:0]  w_wr_addr;
    logic        w_wr_en;
    logic [1:0]  w_sel_alu;
    logic [4:0]  w_alu_op;
    logic        w_sreg_we;
    logic [7:0]  w_imm;
    logic [1:0]  w_ctr_pc;
    logic [15:0] w_load_val;
    logic        w_ram_we, w_ram_re;

/*
    always_comb begin
        o_leds = '0;
        if(!i_rst_n) begin
            o_leds[0] = 1'b1;
            o_leds[3] = 1'b1;
        end else begin
            o_leds[1] = 1'b1;
            o_leds[4] = 1'b1;
        end
    end
  */  
    
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
        .o_rdata (w_ram_rdata),    
        .io_gpio (io_gpio)
    );

endmodule
