`timescale 1ns / 1ps
// ============================================================
//  tb_UART_Rx.sv — testbench dla modułu UART_Rx
//  Zegar: 12 MHz, Baudrate: 9600, Format: 8N1
// ============================================================
module tb_UART_Rx;

    // Parametry czasowe
    localparam CLK_PERIOD = 83.333;                  // 12 MHz → ~83.3 ns
    localparam BIT_PERIOD = 1_000_000_000 / 9600;    // 9600 baud → ~104166 ns

    // Sygnały
    logic i_clk    = 0;
    logic i_rst    = 1;
    logic i_Rx_data = 1;   // Linia IDLE = HIGH

    logic [7:0]  o_prog_data;
    logic        o_prog_we;
    logic [12:0] o_prog_addr;

    // Instancja DUT
    UART_Rx dut (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_Rx_data   (i_Rx_data),
        .o_prog_data (o_prog_data),
        .o_prog_we   (o_prog_we),
        .o_prog_addr (o_prog_addr)
    );

    // Generator zegara 12 MHz
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // ---- Task: wysłanie jednego bajtu przez UART (8N1, LSB first) ----
    task automatic send_byte(input [7:0] byte_val);
        integer i;
        begin
            // Bit START
            i_Rx_data = 1'b0;
            #(BIT_PERIOD);

            // 8 bitów danych (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                i_Rx_data = byte_val[i];
                #(BIT_PERIOD);
            end

            // Bit STOP
            i_Rx_data = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // ---- Licznik odebranych bajtów i weryfikacja ----
    integer rx_count = 0;
    logic [7:0] expected_bytes [0:5];
    integer pass_count = 0;
    integer fail_count = 0;

    // Monitor zapisu do pamięci
    always @(posedge i_clk) begin
        if (o_prog_we && !i_rst) begin
            $display("  [RX #%0d] addr=%04h  data=%02h  (oczekiwane: %02h) %s",
                rx_count,
                o_prog_addr,
                o_prog_data,
                expected_bytes[rx_count],
                (o_prog_data === expected_bytes[rx_count]) ? "PASS" : "FAIL"
            );
            if (o_prog_data === expected_bytes[rx_count])
                pass_count = pass_count + 1;
            else
                fail_count = fail_count + 1;

            rx_count = rx_count + 1;
        end
    end

    // ---- Główna sekwencja testowa ----
    initial begin
        // Definicja oczekiwanych bajtów
        expected_bytes[0] = 8'h05;   // 0x05 — młodszy bajt instrukcji E005
        expected_bytes[1] = 8'hE0;   // 0xE0 — starszy bajt instrukcji E005
        expected_bytes[2] = 8'hAA;   // 0xAA — wzorzec bitowy 10101010
        expected_bytes[3] = 8'h55;   // 0x55 — wzorzec bitowy 01010101
        expected_bytes[4] = 8'h00;   // 0x00 — same zera
        expected_bytes[5] = 8'hFF;   // 0xFF — same jedynki

        $display("=== UART_Rx Testbench START ===");
        $display("Zegar: 12 MHz | Baudrate: 9600 | Format: 8N1");
        $display("");

        // Reset aktywny (UART w resecie)
        i_rst = 1;
        #(CLK_PERIOD * 10);

        // Zwolnienie resetu — UART zaczyna działać
        i_rst = 0;
        #(CLK_PERIOD * 5);

        // Wysyłanie 6 bajtów testowych
        $display("--- Wysylanie bajtu 0: 0x05 ---");
        send_byte(8'h05);
        #(BIT_PERIOD * 2);

        $display("--- Wysylanie bajtu 1: 0xE0 ---");
        send_byte(8'hE0);
        #(BIT_PERIOD * 2);

        $display("--- Wysylanie bajtu 2: 0xAA ---");
        send_byte(8'hAA);
        #(BIT_PERIOD * 2);

        $display("--- Wysylanie bajtu 3: 0x55 ---");
        send_byte(8'h55);
        #(BIT_PERIOD * 2);

        $display("--- Wysylanie bajtu 4: 0x00 ---");
        send_byte(8'h00);
        #(BIT_PERIOD * 2);

        $display("--- Wysylanie bajtu 5: 0xFF ---");
        send_byte(8'hFF);
        #(BIT_PERIOD * 2);

        // Podsumowanie
        $display("");
        $display("=== PODSUMOWANIE ===");
        $display("Odebrano:  %0d / 6 bajtow", rx_count);
        $display("PASS:      %0d", pass_count);
        $display("FAIL:      %0d", fail_count);
        $display("Koncowy adres: %04h (oczekiwany: 0006)", o_prog_addr);

        if (pass_count == 6 && fail_count == 0 && o_prog_addr == 13'h0006)
            $display(">>> WSZYSTKIE TESTY PRZESZLY! <<<");
        else
            $display(">>> WYKRYTO BLEDY! <<<");

        $display("=== UART_Rx Testbench DONE ===");
        $finish;
    end

endmodule
