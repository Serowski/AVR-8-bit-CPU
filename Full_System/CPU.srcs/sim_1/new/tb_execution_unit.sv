`timescale 1ns / 1ps

// ============================================================
//  Testbench: tb_execution_unit
//
//  Używa tasków (task) do opakowania operacji na DUT:
//
//    eu_ldi  (reg, val)         → LDI  Rd, K     (ładuj wartość natychmiastową)
//    eu_add  (dst, rd, rr)      → ADD  Rd, Rr    (dodaj dwa rejestry)
//    eu_read (reg, data, flags) → odczytaj rejestr i flagi do zmiennych
//    eu_idle (n)                → N cykli przerwy (separacja wizualna)
// ============================================================
module tb_execution_unit;

    // --------------------------------------------------------
    // Parametry i stałe
    // --------------------------------------------------------
    localparam int CLK_PERIOD = 10; // 10 ns → 100 MHz

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
    always #(CLK_PERIOD / 2) clk = ~clk;

    // ========================================================
    //  TASKI — opakowania operacji procesora
    //
    //  Zasada działania:
    //    1. Sygnały są ustawiane natychmiast po wywołaniu taska
    //    2. @(negedge clk) czeka na OPADAJĄCE zbocze, po którym
    //       ROSNĄCE zbocze (za pół okresu) spowoduje rejestrację
    //    3. Po powrocie z taska wszystkie sygnały są gotowe
    // ========================================================

    // --------------------------------------------------------
    // eu_ldi(reg_addr, value)
    //
    //  Odpowiednik instrukcji: LDI Rd, K
    //  Ładuje wartość natychmiastową 'value' do rejestru 'reg_addr'
    //  Mechanizm: ALU_PASS z i_imm → wynik ALU → zapis do reg_file
    // --------------------------------------------------------
    task automatic eu_ldi(
        input logic [4:0] reg_addr,
        input logic [7:0] value
    );
        wr_en    = 1'b1;
        wr_addr  = reg_addr;
        sel_alu  = ALU_IMM;    // MUX: wybierz i_imm jako wejście ALU
        alu_op   = ALU_PASS; // ALU przepuszcza i_Rr (= i_imm) bez zmian
        imm      = value;
        sreg_we  = 1'b0;     // nie aktualizuj flag przy ładowaniu
        rd_addr1 = 5'd0;     // bez znaczenia przy PASS
        rd_addr2 = 5'd0;     // bez znaczenia przy PASS
        @(negedge clk);      // czekaj → na następnym posedge reg zapisze value
        wr_en    = 1'b0;     // wyłącz zapis po operacji
    endtask

    // --------------------------------------------------------
    // eu_add(reg_dst, reg_rd, reg_rr)
    //
    //  Odpowiednik instrukcji: ADD Rd, Rr
    //  Dodaje rejestry reg_rd i reg_rr, wynik → reg_dst
    //  Aktualizuje flagi SREG (C, Z, N, S)
    // --------------------------------------------------------
    task automatic eu_add(
        input logic [4:0] reg_dst,
        input logic [4:0] reg_rd,
        input logic [4:0] reg_rr
    );
        pc_inc = 1'b1;
        wr_en    = 1'b1;
        wr_addr  = reg_dst;
        rd_addr1 = reg_rd;   // i_Rd → pierwszy operand ALU
        rd_addr2 = reg_rr;   // i_Rr → drugi operand ALU (przez MUX=00)
        sel_alu  = ALU_REG;    // MUX: wybierz rd_data2 (z rejestru)
        alu_op   = ALU_ADD;
        imm      = 8'h00;
        sreg_we  = 1'b1;     // zapisz flagi do SREG
        @(negedge clk);      // czekaj → wynik i flagi zapisane
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        pc_inc = 1'b0;
    endtask

    task automatic eu_and(
        input logic [4:0] reg_dst,
        input logic [4:0] reg_rd,
        input logic [4:0] reg_rr
    );
        pc_inc = 1'b1;
        wr_en    = 1'b1;
        wr_addr  = reg_dst;
        rd_addr1 = reg_rd;   // i_Rd → pierwszy operand ALU
        rd_addr2 = reg_rr;   // i_Rr → drugi operand ALU (przez MUX=00)
        sel_alu  = ALU_REG;    // MUX: wybierz rd_data2 (z rejestru)
        alu_op   = ALU_AND;
        imm      = 8'h00;
        sreg_we  = 1'b1;     // zapisz flagi do SREG
        @(negedge clk);      // czekaj → wynik i flagi zapisane
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        pc_inc = 1'b0;
    endtask

    // --------------------------------------------------------
    // eu_read(reg_addr, out_data, out_flags)
    //
    //  Odczytuje wartość rejestru i aktualne flagi SREG
    //  Wyniki są zwracane przez argumenty wyjściowe (output)
    //
    //  Mechanizm: ALU_PASS(rd_data2) → o_data = wartość rejestru
    //             o_Flag = wyjście SREG (nie zmienia się, sreg_we=0)
    // --------------------------------------------------------
    task automatic eu_read(
        input  logic [4:0] reg_addr,
        output logic [7:0] out_data,
        output logic [7:0] out_flags
    );
        wr_en    = 1'b0;
        sreg_we  = 1'b0;
        rd_addr1 = reg_addr; // czytaj rejestr przez port 2
        sel_alu  = ALU_REG;    // MUX: rd_data2 → i_Rr
        alu_op   = ALU_PASS; // ALU przepuszcza i_Rr = wartość rejestru
        @(negedge clk);      // poczekaj jeden cykl (sygnały stabilne)
        out_data  = o_data;  // zapamiętaj wynik (kombinacyjne wyjście ALU)
        out_flags = o_Flag;  // zapamiętaj stan SREG (rejestrowane)
    endtask

    // --------------------------------------------------------
    // eu_idle(n)
    //
    //  Odczekaj 'n' cykli bez wykonywania operacji
    //  Używane do wizualnej separacji testów na wykresie
    // --------------------------------------------------------
    task automatic eu_idle(input int n);
        wr_en   = 1'b0;
        sreg_we = 1'b0;
        repeat(n) @(negedge clk);
    endtask

    // --------------------------------------------------------
    // check(test_name, got_data, exp_data, got_flags, exp_flags)
    //
    //  Porównuje wynik z oczekiwaną wartością i wypisuje raport
    // --------------------------------------------------------
    int pass_count = 0;
    int fail_count = 0;

    task automatic check(
        input string      test_name,
        input logic [7:0] got_data,
        input logic [7:0] exp_data,
        input logic [7:0] got_flags,
        input logic [7:0] exp_flags
    );
        if (got_data === exp_data && got_flags === exp_flags) begin
            $display("[PASS] %-35s | data=0x%02h | flags=0b%08b",
                     test_name, got_data, got_flags);
            pass_count++;
        end else begin
            $display("[FAIL] %-35s", test_name);
            if (got_data !== exp_data)
                $display("         data  : got=0x%02h  exp=0x%02h", got_data, exp_data);
            if (got_flags !== exp_flags)
                $display("         flags : got=0b%08b  exp=0b%08b", got_flags, exp_flags);
            fail_count++;
        end
    endtask

    // ========================================================
    //  GŁÓWNA SEKWENCJA TESTÓW
    // ========================================================
    logic [7:0] result_data;
    logic [7:0] result_flags;

    initial begin

        // ---- Inicjalizacja sygnałów ----
        rst_n    = 1'b0;
        wr_en    = 1'b0;
        wr_addr  = 5'd0;
        rd_addr1 = 5'd0;
        rd_addr2 = 5'd0;
        imm      = 8'h00;
        sel_alu  = 2'b00;
        alu_op   = ALU_ADD;
        C_in     = 1'b0;
        sreg_we  = 1'b0;
        pc_load  = 1'b0;
        load_val = 16'h0000;
        pc_inc   = 1'b0;

        // ---- Reset ----
        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        $display("");
        $display("=========================================");
        $display("  Testbench: execution_unit — ADD");
        $display("=========================================");

        // ============================================================
        // TC1: 0x0F + 0x05 = 0x14  (wynik normalny, brak flag)
        // ============================================================
        eu_ldi(R1, 8'h0F);              // R0 = 15
        eu_ldi(R2, 8'h05);              // R1 = 5
        eu_and(R1, R1, R2);         // R0 = R0 + R1 = 20 = 0x14
        eu_read(R1, result_data, result_flags);
        check("TC1: 0b00001111 & 0x00000101 = 0x00000101",
              result_data,  8'h05,
              result_flags, 8'b0000_0000);
        eu_idle(2);

        // ============================================================
        // TC2: 0xC8 + 0x64 = 0x2C  (przeniesienie C=1)
        // ============================================================
        eu_ldi(R3, 8'hC8);              // R2 = 200
        eu_ldi(R4, 8'h64);              // R3 = 100
        eu_add(R3, R3, R4);         // R2 = 200 + 100 → 0x2C, C=1
        eu_read(R3, result_data, result_flags);
        check("TC2: 0xC8 + 0x64 = 0x2C, C=1",
              result_data,  8'h2C,
              result_flags, 8'b0000_0001);
        eu_idle(2);

        // ============================================================
        // TC3: 0x00 + 0x00 = 0x00  (flaga Z=1)
        // ============================================================
        eu_ldi(R4, 8'h00);              // R4 = 0
        eu_ldi(R5, 8'h00);              // R5 = 0
        eu_add(R4, R4, R5);         // R4 = 0 + 0 = 0, Z=1
        eu_read(R4, result_data, result_flags);
        check("TC3: 0x00 + 0x00 = 0x00, Z=1",
              result_data,  8'h00,
              result_flags, 8'b0000_0010);
        eu_idle(2);

        // ============================================================
        // TC4: 0x7F + 0x01 = 0x80  (wynik ujemny N=1, S=1)
        // ============================================================
        eu_ldi(R6, 8'h7F);              // R6 = 127
        eu_ldi(R7, 8'h01);              // R7 = 1
        eu_add(R6, R6, R7);         // R6 = 127 + 1 = 128 = 0x80, N=1, S=1
        eu_read(R6, result_data, result_flags);
        check("TC4: 0x7F + 0x01 = 0x80, N=1 S=1",
              result_data,  8'h80,
              result_flags, 8'b0001_0100);
        eu_idle(3);

        // ---- Podsumowanie ----
        $display("=========================================");
        $display("  PASS: %0d  |  FAIL: %0d", pass_count, fail_count);
        $display("=========================================");
        $display("");
        $finish;
    end

endmodule
