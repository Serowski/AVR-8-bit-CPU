`timescale 1ns / 1ps
// tb_UART_progMem.sv
// Tests writing through UART into program_memory.
// Instantiates UART_top + program_memory, pushes 6 bytes
// (3 x 16-bit instructions), then checks TX echo and BRAM contents.
// Clock: 12 MHz | Baud: 9600 | Frame: 8N1
module tb_UART_progMem;

    localparam CLK_PERIOD = 83.333;               // 12 MHz
    localparam BIT_PERIOD = 1_000_000_000 / 9600;  // ~104166 ns

    // signals
    logic        i_clk     = 0;
    logic        i_rst     = 1;
    logic        i_Rx_data = 1;   // IDLE = HIGH

    // UART_top -> program_memory
    logic [7:0]  w_uart_data;
    logic [12:0] w_uart_addr;
    logic        w_uart_we;
    logic        w_Tx_data;

    // program_memory PORT A (CPU read port, used here for verification)
    logic [11:0] pc_addr;
    logic [15:0] instruction;

    // DUT instances
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

    // 12 MHz clock
    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    // push one byte onto the RX line (simulates a PC sending data)
    task automatic send_byte(input [7:0] val);
        integer i;
        begin
            // START bit
            i_Rx_data = 1'b0;
            #(BIT_PERIOD);
            // 8 data bits, LSB first
            for (i = 0; i < 8; i++) begin
                i_Rx_data = val[i];
                #(BIT_PERIOD);
            end
            // STOP bit
            i_Rx_data = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // grab one byte from the TX line (simulates a PC reading back the echo)
    task automatic receive_byte(output [7:0] val);
        integer i;
        begin
            // wait for falling edge = start bit
            @(negedge w_Tx_data);
            // sample at mid-bit of START
            #(BIT_PERIOD / 2);
            // read 8 data bits
            for (i = 0; i < 8; i++) begin
                #(BIT_PERIOD);
                val[i] = w_Tx_data;
            end
            // ride out the stop bit
            #(BIT_PERIOD);
        end
    endtask

    // test data: 3 AVR instructions (6 bytes total)
    // Instr 0: 0xE005 (LDI R16, 5)  -> bytes: 0x05 (lo), 0xE0 (hi)
    // Instr 1: 0xE013 (LDI R17, 3)  -> bytes: 0x13 (lo), 0xE0 (hi)
    // Instr 2: 0x0F01 (ADD R16, R17) -> bytes: 0x01 (lo), 0x0F (hi)
    localparam int NUM_BYTES = 6;
    logic [7:0] test_bytes [0:NUM_BYTES-1];

    logic [7:0] echo_byte;
    integer pass_count = 0;
    integer fail_count = 0;

    // main test
    initial begin
        test_bytes[0] = 8'h05;   // LDI R16,5  -- low byte
        test_bytes[1] = 8'hE0;   // LDI R16,5  -- high byte
        test_bytes[2] = 8'h13;   // LDI R17,3  -- low byte
        test_bytes[3] = 8'hE0;   // LDI R17,3  -- high byte
        test_bytes[4] = 8'h01;   // ADD R16,R17 -- low byte
        test_bytes[5] = 8'h0F;   // ADD R16,R17 -- high byte

        pc_addr = 12'h000;

        $display("=== tb_UART_progMem START ===");
        $display("Sending %0d bytes (3 AVR instructions)", NUM_BYTES);
        $display("");

        // assert reset
        i_rst = 1;
        #(CLK_PERIOD * 10);

        // release reset -- UART goes active
        i_rst = 0;
        #(CLK_PERIOD * 5);

        // -- Phase 1: send bytes and verify echo --
        $display("--- PHASE 1: TX + Echo check ---");
        for (int b = 0; b < NUM_BYTES; b++) begin
            $display("  sending byte[%0d] = 0x%02h ...", b, test_bytes[b]);

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

            // short gap between frames
            #(BIT_PERIOD * 2);
        end

        // -- Phase 2: read back BRAM via PORT A --
        $display("");
        $display("--- PHASE 2: BRAM readback ---");

        // instruction 0 (addr 0)
        pc_addr = 12'h000;
        #(CLK_PERIOD * 3);  // BRAM latency
        $display("  memory[0] = 0x%04h (expected: 0xE005) %s",
            instruction, (instruction === 16'hE005) ? "PASS" : "FAIL");
        if (instruction === 16'hE005) pass_count++; else fail_count++;

        // instruction 1 (addr 1)
        pc_addr = 12'h001;
        #(CLK_PERIOD * 3);
        $display("  memory[1] = 0x%04h (expected: 0xE013) %s",
            instruction, (instruction === 16'hE013) ? "PASS" : "FAIL");
        if (instruction === 16'hE013) pass_count++; else fail_count++;

        // instruction 2 (addr 2)
        pc_addr = 12'h002;
        #(CLK_PERIOD * 3);
        $display("  memory[2] = 0x%04h (expected: 0x0F01) %s",
            instruction, (instruction === 16'h0F01) ? "PASS" : "FAIL");
        if (instruction === 16'h0F01) pass_count++; else fail_count++;

        // summary
        $display("");
        $display("=== SUMMARY ===");
        $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display(">>> ALL TESTS PASSED <<<");
        else
            $display(">>> ERRORS DETECTED <<<");

        $display("=== tb_UART_progMem DONE ===");
        //$finish;
    end

endmodule
