`timescale 100ns / 100ps
// ============================================================
//  tb_cpu_all.sv — End-to-end test: UART upload + CPU execution
//  1) i_rst_n=0: UART wysyła program do BRAM
//  2) i_rst_n=1: CPU wykonuje program
//  3) Weryfikacja rejestrów
//  Zegar: 12 MHz | Baudrate: 9600 | Format: 8N1
// ============================================================
module tb_cpu_all;

    localparam CLK_PERIOD = 83.333;
    localparam BIT_PERIOD = 1_000_000_000 / 9600;

    logic        i_clk     = 0;
    logic        i_rst_n   = 0;    // Start: CPU w resecie, UART aktywny
    logic        i_Rx_data = 1;    // UART IDLE = HIGH
    logic        o_Tx_data;
    logic [5:0]  o_leds;
    wire  [31:0] io_gpio;

    // DUT — cały procesor z UART
    cpu_top dut (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_Rx_data (i_Rx_data),
        .o_Tx_data (o_Tx_data),
        .io_gpio   (io_gpio),
        .o_leds    (o_leds)
    );

    // Zegar 12 MHz
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // ---- Task: wyślij bajt UART ----
    task automatic send_byte(input [7:0] val);
        integer i;
        begin
            i_Rx_data = 1'b0;          // START
            #(BIT_PERIOD);
            for (i = 0; i < 8; i++) begin
                i_Rx_data = val[i];    // DATA LSB first
                #(BIT_PERIOD);
            end
            i_Rx_data = 1'b1;          // STOP
            #(BIT_PERIOD);
        end
    endtask

    // ---- Task: odbierz echo ----
    task automatic receive_byte(output [7:0] val);
        integer i;
        begin
            @(negedge o_Tx_data);      // Czekaj na START
            #(BIT_PERIOD / 2);         // Środek START bitu
            for (i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                val[i] = o_Tx_data;
            end
            #(BIT_PERIOD);             // STOP
        end
    endtask

    // ---- Task: wyślij + weryfikuj echo ----
    task automatic send_and_verify(input [7:0] val, input string name);
        logic [7:0] echo;
        begin
            fork
                send_byte(val);
                receive_byte(echo);
            join
            if (echo === val)
                $display("  [UART] %s: 0x%02h echo OK", name, val);
            else
                $display("  [UART] %s: FAIL! sent=0x%02h echo=0x%02h", name, val, echo);
            #(BIT_PERIOD);
        end
    endtask

    // ---- Główna sekwencja testowa ----
    initial begin
        $display("=== tb_cpu_all: END-TO-END TEST ===");
        $display("");

        // Zaczynamy od stanu zwolnionego przycisku (i_rst_n = 1)
        // Wtedy CPU dziala, a UART jest w resecie (i_rst = 1)
        i_rst_n = 1;
        #(CLK_PERIOD * 10);

        // ============================================
        // FAZA 1: Upload programu przez UART
        //   i_rst_n = 0 → CPU stoi, UART działa
        // ============================================
        // Wciskamy przycisk (i_rst_n = 0), co aktywuje UART
        i_rst_n = 0;
        #(CLK_PERIOD * 20);

        $display("--- FAZA 1: Upload programu przez UART ---");
        $display("  Program: LDI R16,5 | LDI R17,3 | ADD R16,R17 | RJMP -1");
        $display("");

        // Instrukcja 0: LDI R16, 5  (0xE005)
        send_and_verify(8'h05, "LDI_R16_lo");
        send_and_verify(8'hE0, "LDI_R16_hi");

        // Instrukcja 1: LDI R17, 3  (0xE013)
        send_and_verify(8'h13, "LDI_R17_lo");
        send_and_verify(8'hE0, "LDI_R17_hi");

        // Instrukcja 2: ADD R16, R17  (0x0F01)
        send_and_verify(8'h01, "ADD_lo    ");
        send_and_verify(8'h0F, "ADD_hi    ");

        // Instrukcja 3: RJMP -1  (0xCFFF) — pętla nieskończona
        //send_and_verify(8'hFF, "RJMP_lo   ");
        //send_and_verify(8'hCF, "RJMP_hi   ");

        $display("");
        $display("  Upload zakonczony! 4 instrukcje (8 bajtow)");
        $display(dut.u_program_memory.memory_array[0]);
        $display(dut.u_program_memory.memory_array[1]);
        $display(dut.u_program_memory.memory_array[2]);
        // ============================================
        // FAZA 2: Uruchomienie CPU
        //   i_rst_n = 1 → CPU startuje, UART w resecie
        // ============================================
        $display("");
        $display("--- FAZA 2: Uruchomienie CPU ---");

        #(CLK_PERIOD * 5);
        i_rst_n = 1;
        $display("  i_rst_n = 1 (CPU START) at t=%0t", $time);

        // Czekaj na wykonanie programu (4 instrukcje × 4 cykle FSM = ~16 cykli, dajemy 50)
        repeat(50) @(posedge i_clk);

        // ============================================
        // FAZA 3: Weryfikacja rejestrów
        // ============================================
        $display("");
        $display("--- FAZA 3: Weryfikacja rejestrow ---");

        $display("  R16 = %0d (oczekiwane: 8)",
            dut.u_execution_unit.eu_reg_file.regs[16]);
        $display("  R17 = %0d (oczekiwane: 3)",
            dut.u_execution_unit.eu_reg_file.regs[17]);
        $display("  PC  = 0x%04h",
            dut.u_execution_unit.o_pc);

        if (dut.u_execution_unit.eu_reg_file.regs[16] === 8'd8 &&
            dut.u_execution_unit.eu_reg_file.regs[17] === 8'd3) begin
            $display("");
            $display(">>> WSZYSTKIE TESTY PRZESZLY! <<<");
        end else begin
            $display("");
            $display(">>> WYKRYTO BLEDY! <<<");
        end

        $display("");
        $display("=== tb_cpu_all DONE ===");
        $finish;
    end
    
        // Ważne sygnały obserwowane co cykl
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            $display("t=%0t | PC=%04h | state=%0d | itype_reg=%0d | wr_en=%b | wr_addr=R%0d | instr=%04h | o_rd_data1=%08b | o_rd_data2=%08b | i_alu_op=%0d",
                $time,
                dut.u_program_memory.i_pc_addr,
                dut.u_control_unit.cu_fsm_sequencer.state,
                dut.u_control_unit.cu_fsm_sequencer.itype_reg,
                dut.u_control_unit.o_wr_en,
                dut.u_control_unit.o_wr_addr,
                dut.u_program_memory.o_instruction,
                dut.u_execution_unit.eu_reg_file.o_rd_data1,
                dut.u_execution_unit.eu_reg_file.o_rd_data2,
                dut.u_execution_unit.i_alu_op
            );
        end
        if(dut.u_program_memory.i_uart_we) begin
            $display(dut.u_program_memory.i_uart_addr);
            $display(dut.u_program_memory.i_uart_data);
        end
    end

endmodule
