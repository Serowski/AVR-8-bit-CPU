`timescale 1ns / 1ps
// ============================================================
//  tb_UART_progMem.sv — test zapisu przez UART do program_memory
//  Instancjonuje UART_top + program_memory, wysyła 6 bajtów
//  (3 instrukcje 16-bit), sprawdza echo TX oraz zawartość BRAM.
//  Zegar: 12 MHz | Baudrate: 9600 | Format: 8N1
// ============================================================
module tb_UART_progMem;

    localparam CLK_PERIOD = 83.333;               // 12 MHz
    localparam BIT_PERIOD = 1_000_000_000 / 9600;  // ~104166 ns

    // Sygnały
    logic        i_clk     = 0;
    logic        i_rst     = 1;
    logic        i_Rx_data = 1;   // IDLE = HIGH

    // UART_top → program_memory
    logic [7:0]  w_uart_data;
    logic [12:0] w_uart_addr;
    logic        w_uart_we;
    logic        w_Tx_data;

    // program_memory PORT A (odczyt CPU — do weryfikacji)
    logic [11:0] pc_addr;
    logic [15:0] instruction;

    // ---- Instancje DUT ----
    UART_top u_uart_top (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_Rx_data   (i_Rx_data),
        .o_uart_data (w_uart_data),
        .o_uart_addr (w_uart_addr),
        .o_uart_we   (w_uart_we),
        .o_Tx_data   (w_Tx_data)
    );

    program_memory u_prog_mem (
        .i_clk        (i_clk),
        .i_pc_addr    (pc_addr),
        .o_instruction(instruction),
        .i_uart_addr  (w_uart_addr),
        .i_uart_data  (w_uart_data),
        .i_uart_we    (w_uart_we)
    );

    // Generator zegara 12 MHz
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // ---- Task: wyślij bajt przez linię RX (symuluje PC) ----
    task automatic send_byte(input [7:0] val);
        integer i;
        begin
            // START bit
            i_Rx_data = 1'b0;
            #(BIT_PERIOD);
            // 8 bitów danych LSB first
            for (i = 0; i < 8; i++) begin
                i_Rx_data = val[i];
                #(BIT_PERIOD);
            end
            // STOP bit
            i_Rx_data = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // ---- Task: odbierz bajt z linii TX (symuluje PC odbierający echo) ----
    task automatic receive_byte(output [7:0] val);
        integer i;
        begin
            // Czekaj na START bit (opadające zbocze)
            @(negedge w_Tx_data);
            // Próbkuj w środku bitu START
            #(BIT_PERIOD / 2);
            // Odczytaj 8 bitów danych
            for (i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                val[i] = w_Tx_data;
            end
            // Przeczekaj STOP bit
            #(BIT_PERIOD);
        end
    endtask

    // ---- Dane testowe: 3 instrukcje AVR (6 bajtów) ----
    // Instrukcja 0: 0xE005 (LDI R16, 5)  → bajty: 0x05 (lo), 0xE0 (hi)
    // Instrukcja 1: 0xE013 (LDI R17, 3)  → bajty: 0x13 (lo), 0xE0 (hi)
    // Instrukcja 2: 0x0F01 (ADD R16, R17) → bajty: 0x01 (lo), 0x0F (hi)
    localparam int NUM_BYTES = 6;
    logic [7:0] test_bytes [0:NUM_BYTES-1];

    logic [7:0] echo_byte;
    integer pass_count = 0;
    integer fail_count = 0;

    // ---- Główna sekwencja testowa ----
    initial begin
        test_bytes[0] = 8'h05;   // LDI R16,5  — low byte
        test_bytes[1] = 8'hE0;   // LDI R16,5  — high byte
        test_bytes[2] = 8'h13;   // LDI R17,3  — low byte
        test_bytes[3] = 8'hE0;   // LDI R17,3  — high byte
        test_bytes[4] = 8'h01;   // ADD R16,R17 — low byte
        test_bytes[5] = 8'h0F;   // ADD R16,R17 — high byte

        pc_addr = 12'h000;

        $display("=== tb_UART_progMem START ===");
        $display("Wysylanie %0d bajtow (3 instrukcje AVR)", NUM_BYTES);
        $display("");

        // Reset aktywny
        i_rst = 1;
        #(CLK_PERIOD * 10);

        // Zwolnij reset — UART zaczyna działać
        i_rst = 0;
        #(CLK_PERIOD * 5);

        // ---- Faza 1: Wysyłanie bajtów + weryfikacja echa ----
        $display("--- FAZA 1: Wysylanie + Echo ---");
        for (int b = 0; b < NUM_BYTES; b++) begin
            $display("  Wysylam bajt[%0d] = 0x%02h ...", b, test_bytes[b]);

            fork
                send_byte(test_bytes[b]);
                receive_byte(echo_byte);
            join

            if (echo_byte === test_bytes[b]) begin
                $display("    Echo OK: 0x%02h == 0x%02h  PASS", echo_byte, test_bytes[b]);
                pass_count++;
            end else begin
                $display("    Echo FAIL: 0x%02h != 0x%02h", echo_byte, test_bytes[b]);
                fail_count++;
            end

            // Krótka przerwa między ramkami
            #(BIT_PERIOD * 2);
        end

        // ---- Faza 2: Weryfikacja zawartości BRAM (PORT A) ----
        $display("");
        $display("--- FAZA 2: Weryfikacja BRAM ---");

        // Odczytaj instrukcję 0 (adres 0)
        pc_addr = 12'h000;
        #(CLK_PERIOD * 3);  // BRAM latency
        $display("  memory[0] = 0x%04h (oczekiwane: 0xE005) %s",
            instruction, (instruction === 16'hE005) ? "PASS" : "FAIL");
        if (instruction === 16'hE005) pass_count++; else fail_count++;

        // Odczytaj instrukcję 1 (adres 1)
        pc_addr = 12'h001;
        #(CLK_PERIOD * 3);
        $display("  memory[1] = 0x%04h (oczekiwane: 0xE013) %s",
            instruction, (instruction === 16'hE013) ? "PASS" : "FAIL");
        if (instruction === 16'hE013) pass_count++; else fail_count++;

        // Odczytaj instrukcję 2 (adres 2)
        pc_addr = 12'h002;
        #(CLK_PERIOD * 3);
        $display("  memory[2] = 0x%04h (oczekiwane: 0x0F01) %s",
            instruction, (instruction === 16'h0F01) ? "PASS" : "FAIL");
        if (instruction === 16'h0F01) pass_count++; else fail_count++;

        // ---- Podsumowanie ----
        $display("");
        $display("=== PODSUMOWANIE ===");
        $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display(">>> WSZYSTKIE TESTY PRZESZLY! <<<");
        else
            $display(">>> WYKRYTO BLEDY! <<<");

        $display("=== tb_UART_progMem DONE ===");
        //$finish;
    end

endmodule
