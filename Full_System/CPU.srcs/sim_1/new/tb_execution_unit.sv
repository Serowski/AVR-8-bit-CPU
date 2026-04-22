`timescale 1ns / 1ps

// ============================================================
//  Testbench: tb_execution_unit (wersja waveform-friendly)
//
//  Schemat każdego testu (4 cykle zegara):
//
//   CLK   ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
//   FAZA   LOAD_Rd | LOAD_Rr | ADD    | READ
//
//  Sygnały zmieniane na OPADAJĄCYM zboczu (negedge) → 
//  stabilne przez cały następny cykl → 
//  czytelny przebieg czasowy na wykresie.
// ============================================================
module tb_execution_unit;

    // --------------------------------------------------------
    // Parametry
    // --------------------------------------------------------
    localparam int CLK_PERIOD = 10; // 10 ns → 100 MHz

    // Kody ALU (muszą zgadzać się z avr_pkg.sv)
    localparam logic [5:0] ALU_ADD  = 6'd0;
    localparam logic [5:0] ALU_PASS = 6'd11;
    import avr_pkg::*;
    // --------------------------------------------------------
    // Sygnały DUT
    // --------------------------------------------------------
    logic        clk;
    logic        rst_n;
    logic        wr_en;
    logic [4:0]  wr_addr;
    logic [4:0]  rd_addr1;
    logic [4:0]  rd_addr2;
    logic [7:0]  imm;
    logic [1:0]  sel_alu;
    logic [5:0]  alu_op;
    logic        C_in;
    logic        sreg_we;
    logic        pc_load;
    logic [15:0] load_val;
    logic        pc_inc;

    logic [7:0]  o_data;
    logic [7:0]  o_Flag;
    logic [15:0] o_pc;

    // --------------------------------------------------------
    // Instancja DUT
    // --------------------------------------------------------
    execution_unit dut (
        .i_clk      (clk),
        .i_rst_n    (rst_n),
        .i_wr_en    (wr_en),
        .i_wr_addr  (wr_addr),
        .i_rd_addr1 (rd_addr1),
        .i_rd_addr2 (rd_addr2),
        .i_imm      (imm),
        .i_sel_alu  (sel_alu),
        .i_alu_op   (alu_op),
        .i_C_in     (C_in),
        .i_sreg_we  (sreg_we),
        .i_load     (pc_load),
        .i_load_val (load_val),
        .i_inc      (pc_inc),
        .o_data     (o_data),
        .o_Flag     (o_Flag),
        .o_pc       (o_pc)
    );

    // --------------------------------------------------------
    // Generator zegara
    // --------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;
    //initial begin 
    //   $dumpfile("dump.vcd");
    //   $dumpvars;
    // end
    // --------------------------------------------------------
    // Sekwencja testów
    // Zasada:  zmiany sygnałów ZAWSZE na @(negedge clk)
    //          → sygnały stabilne przez cały następny cykl
    // --------------------------------------------------------
    initial begin
        // Inicjalizacja (t=0)
        rst_n = '0;
        wr_en = '0;
        wr_addr = '0;
        rd_addr1 = '0;
        rd_addr2 = '0;
        imm = '0;
        sel_alu = '0;
        alu_op = '0;
        C_in = '0;
        sreg_we = '0;
        pc_load = '0;
        load_val = '0;
        pc_inc = '0;
        
        o_data = '0;
        o_Flag = '0;
        o_pc = '0;
        
        // Reset 
        @(negedge clk);   
        @(negedge clk);   

        rst_n = 1'b1;     
    
        // LDI R0, 0x0F 
        @(negedge clk);
        
        wr_en   = 1'b1;
        wr_addr = R0;
        sel_alu = ALU_IMM;
        alu_op  = ALU_PASS;
        imm     = 8'h0F;
    
        // LDI R1, 0x05
        @(negedge clk);
        
        wr_addr = R1;
        imm     = 8'h05;
    
        // ADD R0, R1
        @(negedge clk);
        
        wr_addr  = R0;
        rd_addr1 = R0;
        rd_addr2 = R1;
        sel_alu  = ALU_REG;
        alu_op   = ALU_ADD;
        sreg_we  = 1'b1;
    
        // STS x, R0
        @(negedge clk);
        wr_en   = 1'b0;
        sreg_we = 1'b0;
        rd_addr1 = R0;

        // VIEW R1
        @(negedge clk);
        rd_addr1 = R1;
        // Zakończenie

        @(negedge clk);
        @(negedge clk);
        $finish;
    end


endmodule