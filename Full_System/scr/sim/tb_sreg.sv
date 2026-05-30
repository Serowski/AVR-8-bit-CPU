`timescale 1ns / 1ps

module tb_sreg;

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
        #1; // small settle time after the edge
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
    // test sequence
    // =========================================================
    initial begin
        $display("=== TB SREG START ===");

        // --- Test 1: async reset ---
        $display("--- Test 1: Reset ---");
        flags_in = 8'hFF;
        sreg_we  = 1;
        rst_n    = 0;
        #3; // reset mid-cycle -- should clear immediately (async)
        if (flags_out !== 8'h00) begin
            $display("FAIL Async reset: got=0x%02X expected=0x00", flags_out);
            errors++;
        end else
            $display("PASS Async reset mid-cycle");
        @(posedge clk); #1;
        rst_n = 1;

        // --- Test 2: write with WE=1 ---
        $display("--- Test 2: Write WE=1 ---");
        apply_and_check(1, 8'hAA, 8'hAA, "Write 0xAA");
        apply_and_check(1, 8'h55, 8'h55, "Write 0x55");
        apply_and_check(1, 8'hFF, 8'hFF, "Write 0xFF");
        apply_and_check(1, 8'h00, 8'h00, "Write 0x00");

        // --- Test 3: output should hold when WE=0 ---
        $display("--- Test 3: Hold WE=0 ---");
        // first load a known value
        apply_and_check(1, 8'h3C, 8'h3C, "Setup 0x3C");
        // now toggle input with WE deasserted -- output must not change
        apply_and_check(0, 8'hAA, 8'h3C, "Hold with 0xAA");
        apply_and_check(0, 8'h00, 8'h3C, "Hold with 0x00");
        apply_and_check(0, 8'hFF, 8'h3C, "Hold with 0xFF");

        // --- Test 4: individual flag bits ---
        $display("--- Test 4: Individual flags ---");
        // C (bit 0)
        apply_and_check(1, 8'b0000_0001, 8'b0000_0001, "Flag C");
        apply_and_check(1, 8'b0000_0000, 8'b0000_0000, "Clear C");
        // Z (bit 1)
        apply_and_check(1, 8'b0000_0010, 8'b0000_0010, "Flag Z");
        // N (bit 2)
        apply_and_check(1, 8'b0000_0100, 8'b0000_0100, "Flag N");
        // V (bit 3)
        apply_and_check(1, 8'b0000_1000, 8'b0000_1000, "Flag V");
        // S (bit 4)
        apply_and_check(1, 8'b0001_0000, 8'b0001_0000, "Flag S");
        // H (bit 5)
        apply_and_check(1, 8'b0010_0000, 8'b0010_0000, "Flag H");
        // T (bit 6)
        apply_and_check(1, 8'b0100_0000, 8'b0100_0000, "Flag T");
        // I (bit 7)
        apply_and_check(1, 8'b1000_0000, 8'b1000_0000, "Flag I");

        // --- Test 5: reset while running ---
        $display("--- Test 5: Mid-run reset ---");
        apply_and_check(1, 8'hBE, 8'hBE, "Setup before reset");
        rst_n = 0; // async reset
        #2;
        if (flags_out !== 8'h00) begin
            $display("FAIL Reset mid-operation: got=0x%02X", flags_out);
            errors++;
        end else
            $display("PASS Reset mid-operation");
        @(posedge clk); #1;
        rst_n = 1;

        // --- Test 6: rapid WE toggling ---
        $display("--- Test 6: Alternating WE ---");
        apply_and_check(1, 8'h12, 8'h12, "Write 0x12");
        apply_and_check(0, 8'h99, 8'h12, "Hold");
        apply_and_check(1, 8'h34, 8'h34, "Write 0x34");
        apply_and_check(0, 8'hAB, 8'h34, "Hold");
        apply_and_check(1, 8'h56, 8'h56, "Write 0x56");

        // =========================================================
        // final result
        // =========================================================
        $display("=== TB SREG DONE === Errors: %0d ===", errors);
        if (errors == 0)
            $display(">>> ALL TESTS PASSED <<<");
        else
            $display(">>> %0d ERROR(S) FOUND <<<", errors);

        $finish;
    end


endmodule
