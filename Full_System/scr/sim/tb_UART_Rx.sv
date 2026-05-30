`timescale 1ns / 1ps
// tb_UART_Rx.sv
// Testbench for the UART receiver module
// Clock: 12 MHz, Baud: 9600, Frame: 8N1
module tb_UART_Rx;

    // timing constants
    localparam CLK_PERIOD = 83.333;                  // 12 MHz -> ~83.3 ns
    localparam BIT_PERIOD = 1_000_000_000 / 9600;    // 9600 baud -> ~104166 ns

    // signals
    logic i_clk    = 0;
    logic i_rst    = 1;
    logic i_Rx_data = 1;   // line idles HIGH

    logic [7:0]  o_prog_data;
    logic        o_prog_we;
    logic [12:0] o_prog_addr;

    // DUT
    UART_Rx dut (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_Rx_data   (i_Rx_data),
        .o_prog_data (o_prog_data),
        .o_prog_we   (o_prog_we),
        .o_prog_addr (o_prog_addr)
    );

    // 12 MHz clock
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // send a single byte over UART (8N1, LSB first)
    task automatic send_byte(input [7:0] byte_val);
        integer i;
        begin
            // start bit
            i_Rx_data = 1'b0;
            #(BIT_PERIOD);

            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                i_Rx_data = byte_val[i];
                #(BIT_PERIOD);
            end

            // stop bit
            i_Rx_data = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // byte counter + checking
    integer rx_count = 0;
    logic [7:0] expected_bytes [0:5];
    integer pass_count = 0;
    integer fail_count = 0;

    // watch for writes to memory
    always @(posedge i_clk) begin
        if (o_prog_we && !i_rst) begin
            $display("  [RX #%0d] addr=%04h  data=%02h  (expected: %02h) %s",
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

    // main test sequence
    initial begin
        // set up expected values
        expected_bytes[0] = 8'h05;   // low byte of instruction E005
        expected_bytes[1] = 8'hE0;   // high byte of instruction E005
        expected_bytes[2] = 8'hAA;   // bit pattern 10101010
        expected_bytes[3] = 8'h55;   // bit pattern 01010101
        expected_bytes[4] = 8'h00;   // all zeros
        expected_bytes[5] = 8'hFF;   // all ones

        $display("=== UART_Rx Testbench START ===");
        $display("Clock: 12 MHz | Baud: 9600 | Frame: 8N1");
        $display("");

        // hold reset
        i_rst = 1;
        #(CLK_PERIOD * 10);

        // release reset, UART starts running
        i_rst = 0;
        #(CLK_PERIOD * 5);

        // send 6 test bytes
        $display("--- sending byte 0: 0x05 ---");
        send_byte(8'h05);
        #(BIT_PERIOD * 2);

        $display("--- sending byte 1: 0xE0 ---");
        send_byte(8'hE0);
        #(BIT_PERIOD * 2);

        $display("--- sending byte 2: 0xAA ---");
        send_byte(8'hAA);
        #(BIT_PERIOD * 2);

        $display("--- sending byte 3: 0x55 ---");
        send_byte(8'h55);
        #(BIT_PERIOD * 2);

        $display("--- sending byte 4: 0x00 ---");
        send_byte(8'h00);
        #(BIT_PERIOD * 2);

        $display("--- sending byte 5: 0xFF ---");
        send_byte(8'hFF);
        #(BIT_PERIOD * 2);

        // results
        $display("");
        $display("=== SUMMARY ===");
        $display("Received:  %0d / 6 bytes", rx_count);
        $display("PASS:      %0d", pass_count);
        $display("FAIL:      %0d", fail_count);
        $display("Final addr: %04h (expected: 0006)", o_prog_addr);

        if (pass_count == 6 && fail_count == 0 && o_prog_addr == 13'h0006)
            $display(">>> ALL TESTS PASSED <<<");
        else
            $display(">>> ERRORS DETECTED <<<");

        $display("=== UART_Rx Testbench DONE ===");
        $finish;
    end

endmodule
