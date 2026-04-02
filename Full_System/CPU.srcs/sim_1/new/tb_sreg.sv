`timescale 1ns / 1ps

`timescale 1ns / 1ps

module tb_sreg;
    //
    logic       clk;
    logic       rst_n;
    logic       sreg_we;
    logic [7:0] flags_in;
    logic [7:0] flags_out;

    sreg u_dut (
        .i_clk     (clk),
        .i_rst_n   (rst_n),
        .i_sreg_we (sreg_we),
        .i_flags   (flags_in),
        .o_flags   (flags_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    int errors = 0;

    task apply_and_check(
        input logic       we,
        input logic [7:0] data,
        input logic [7:0] expected,
        input string      test_name
    );
        sreg_we  = we;
        flags_in = data;
        @(posedge clk);
        #1; // małe opóźnienie - odczyt po zboczu
        if (flags_out !== expected) begin
            $display("FAIL [%0t ns] %s | WE=%b IN=0x%02X | got=0x%02X expected=0x%02X",
                     $time, test_name, we, data, flags_out, expected);
            errors++;
        end else begin
            $display("PASS [%0t ns] %s | WE=%b IN=0x%02X | out=0x%02X",
                     $time, test_name, we, data, flags_out);
        end
    endtask


    task do_reset();
        rst_n    = 0;
        sreg_we  = 0;
        flags_in = 8'h00;
        @(posedge clk);
        #1;
        if (flags_out !== 8'h00) begin
            $display("FAIL [%0t ns] Reset | got=0x%02X expected=0x00", $time, flags_out);
            errors++;
        end else
            $display("PASS [%0t ns] Reset | out=0x%02X", $time, flags_out);
        @(negedge clk);
        rst_n = 1;
    endtask

    // =========================================================
    // Główna sekwencja testów
    // =========================================================
    initial begin
        $display("=== TB SREG START ===");

        // --- Test 1: Reset asynchroniczny ---
        $display("--- Test 1: Reset ---");
        flags_in = 8'hFF;
        sreg_we  = 1;
        rst_n    = 0;
        #3; // reset W ŚRODKU cyklu - sprawdzamy asynchroniczność
        if (flags_out !== 8'h00) begin
            $display("FAIL Async reset: got=0x%02X expected=0x00", flags_out);
            errors++;
        end else
            $display("PASS Async reset w środku cyklu");
        @(posedge clk); #1;
        rst_n = 1;

        // --- Test 2: Zapis ze znakiem WE=1 ---
        $display("--- Test 2: Zapis WE=1 ---");
        apply_and_check(1, 8'hAA, 8'hAA, "Zapis 0xAA");
        apply_and_check(1, 8'h55, 8'h55, "Zapis 0x55");
        apply_and_check(1, 8'hFF, 8'hFF, "Zapis 0xFF");
        apply_and_check(1, 8'h00, 8'h00, "Zapis 0x00");

        // --- Test 3: Brak zapisu gdy WE=0 ---
        $display("--- Test 3: Hold WE=0 ---");
        // Najpierw zapisz wartość
        apply_and_check(1, 8'h3C, 8'h3C, "Setup 0x3C");
        // Teraz zmieniaj wejście przy WE=0 - wyjście ma się NIE zmieniać
        apply_and_check(0, 8'hAA, 8'h3C, "Hold przy 0xAA");
        apply_and_check(0, 8'h00, 8'h3C, "Hold przy 0x00");
        apply_and_check(0, 8'hFF, 8'h3C, "Hold przy 0xFF");

        // --- Test 4: Poszczególne bity SREG ---
        $display("--- Test 4: Flagi individualne ---");
        // Bit C (0)
        apply_and_check(1, 8'b0000_0001, 8'b0000_0001, "Flaga C");
        apply_and_check(1, 8'b0000_0000, 8'b0000_0000, "Kasuj C");
        // Bit Z (1)
        apply_and_check(1, 8'b0000_0010, 8'b0000_0010, "Flaga Z");
        // Bit N (2)
        apply_and_check(1, 8'b0000_0100, 8'b0000_0100, "Flaga N");
        // Bit V (3)
        apply_and_check(1, 8'b0000_1000, 8'b0000_1000, "Flaga V");
        // Bit S (4)
        apply_and_check(1, 8'b0001_0000, 8'b0001_0000, "Flaga S");
        // Bit H (5)
        apply_and_check(1, 8'b0010_0000, 8'b0010_0000, "Flaga H");
        // Bit T (6)
        apply_and_check(1, 8'b0100_0000, 8'b0100_0000, "Flaga T");
        // Bit I (7)
        apply_and_check(1, 8'b1000_0000, 8'b1000_0000, "Flaga I");

        // --- Test 5: Reset w trakcie działania ---
        $display("--- Test 5: Reset w trakcie ---");
        apply_and_check(1, 8'hBE, 8'hBE, "Setup przed resetem");
        rst_n = 0; // reset asynchroniczny
        #2;
        if (flags_out !== 8'h00) begin
            $display("FAIL Reset mid-operation: got=0x%02X", flags_out);
            errors++;
        end else
            $display("PASS Reset mid-operation");
        @(posedge clk); #1;
        rst_n = 1;

        // --- Test 6: Szybkie zmiany WE ---
        $display("--- Test 6: Naprzemienne WE ---");
        apply_and_check(1, 8'h12, 8'h12, "Zapis 0x12");
        apply_and_check(0, 8'h99, 8'h12, "Hold");
        apply_and_check(1, 8'h34, 8'h34, "Zapis 0x34");
        apply_and_check(0, 8'hAB, 8'h34, "Hold");
        apply_and_check(1, 8'h56, 8'h56, "Zapis 0x56");

        // =========================================================
        // Wynik końcowy
        // =========================================================
        $display("=== TB SREG KONIEC === Błędy: %0d ===", errors);
        if (errors == 0)
            $display(">>> WSZYSTKIE TESTY ZALICZONE <<<");
        else
            $display(">>> WYKRYTO %0d BŁĘDÓW <<<", errors);

        $finish;
    end


endmodule


