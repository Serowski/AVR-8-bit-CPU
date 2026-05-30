`timescale 1ns / 1ps


module tb_data_memory();

    logic i_clk;
    logic i_rst_n;
    logic [15:0] i_addr;
    logic [7:0] i_data;
    logic i_we;
    logic i_re;
    logic [7:0] o_rdata;

    // bidirectional GPIO bus
    wire [31:0] io_gpio;

    logic [31:0] tb_gpio_drive;
    logic [31:0] tb_gpio_oe;

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : tb_buffers
            assign io_gpio[i] = tb_gpio_oe[i] ? tb_gpio_drive[i] : 1'bz;
        end
    endgenerate

    data_memory dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_addr(i_addr),
        .i_data(i_data),
        .i_we(i_we),
        .i_re(i_re),
        .o_rdata(o_rdata),
        .io_gpio(io_gpio)
    );

    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

    task write_io(input [15:0] t_addr, input [7:0] t_data);
        begin
            @(posedge i_clk);
            i_addr = t_addr;
            i_data = t_data;
            i_we = 1'b1;
            i_re = 1'b0;
            @(posedge i_clk);
            i_we = 1'b0;
        end
    endtask

    task read_check_io(input [15:0] t_addr, input [7:0] expected);
        begin
            @(posedge i_clk);
            i_addr = t_addr;
            i_we = 1'b0;
            i_re = 1'b1;
            
            @(posedge i_clk); 
            i_re = 1'b0;
            
            #1;
            if (o_rdata === expected)
                $display("PASS: Read from addr %04X returned correct value %02X", t_addr, o_rdata);
            else
                $error("FAIL: Expected %02X at addr %04X, but got %02X", expected, t_addr, o_rdata);
        end
    endtask


    initial begin
        i_rst_n = 0;
        i_addr = 0; i_data = 0; i_we = 0; i_re = 0;
        tb_gpio_drive = 32'h0; tb_gpio_oe = 32'h0; 
        #20;
        i_rst_n = 1; 
        #20;

        $display("\n=== TEST 1: PORT B AS OUTPUT ===");

        write_io(16'h0024, 8'hFF); 
        write_io(16'h0025, 8'hAA);
        #10;
        if (io_gpio[7:0] === 8'hAA) 
            $display("PASS: Physical PORT B pins read 0xAA");
        else 
            $error("FAIL: Physical PORT B pins are %02X", io_gpio[7:0]);


        $display("\n=== TEST 2: PORT C AS INPUT ===");
        write_io(16'h0027, 8'h00); 

        tb_gpio_drive[15:8] = 8'h55; 
        tb_gpio_oe[15:8]    = 8'hFF; 
        #10;
        
        read_check_io(16'h0026, 8'h55);

        $display("\n=== TEST 3: PORT D MIXED (HALF IN / HALF OUT) ===");

        write_io(16'h002A, 8'h0F); 

        write_io(16'h002B, 8'h0A); 

        tb_gpio_drive[23:16] = 8'hB0;
        tb_gpio_oe[23:16]    = 8'hF0;
        #10;

        if (io_gpio[23:16] === 8'hBA) 
            $display("PASS: Physical PORT D pins correctly mixed I/O (0xBA)");
        else 
            $error("FAIL: Physical PORT D pins are %02X", io_gpio[23:16]);

        read_check_io(16'h0029, 8'hBA);


        $display("\n=== SIMULATION FINISHED ===");
        $finish;
    end

endmodule