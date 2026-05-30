`timescale 1ns / 1ps

module data_memory(
    input              i_clk,
    input              i_rst_n,
    // Connection to CPU
    input [15:0]       i_addr,
    input [7:0]        i_data,
    input              i_we,
    input              i_re,
    output logic [7:0] o_rdata,
    // GPIO pins
    inout [31:0]       io_gpio
    );
    
    import avr_pkg::*;
    
    // SRAM with 4096 bytes declaration
    logic [7:0] sram [0:4095];
    logic [7:0] sram_rdata;
     
    // Read/Write synchronous -> BRAM blocks used
    always_ff @(posedge i_clk) begin
        // Write to RAM space onyl when addr > 0x0100
        if(i_we && (i_addr >= 16'h0100))
            sram[i_addr[11:0]] <= i_data;
        // Read
        if(i_re)
            sram_rdata <= sram[i_addr[11:0]];
    end
    
    // GPIO Registers -> PORTx, DDRx
    logic [7:0] reg_portb, reg_ddrb;
    logic [7:0] reg_portc, reg_ddrc;
    logic [7:0] reg_portd, reg_ddrd;
    logic [7:0] reg_porte, reg_ddre;
    
    // Read from pin -> PINx
    wire [7:0] pin_b = io_gpio[7:0];
    wire [7:0] pin_c = io_gpio[15:8];
    wire [7:0] pin_d = io_gpio[23:16];
    wire [7:0] pin_e = io_gpio[31:24];
    
    // Temporary register for data from GPIO
    logic [7:0] io_rdata_reg;
    logic       is_io_read_reg;

    // Read and Write in GPIO address space
    always_ff @(posedge i_clk) begin
        // Reset values in registers
        if (!i_rst_n) begin
            reg_portb <= 8'h00; 
            reg_ddrb <= 8'h00;
            reg_portc <= 8'h00; 
            reg_ddrc <= 8'h00;
            reg_portd <= 8'h00; 
            reg_ddrd <= 8'h00;
            reg_porte <= 8'h00; 
            reg_ddre <= 8'h00;
            is_io_read_reg <= 1'b0;
            io_rdata_reg   <= 8'h00;
        end else begin
            // Write to GPIO registers
            if (i_we) begin
                case(i_addr)
                    // PORT B
                    DDRB:  reg_ddrb  <= i_data;
                    PORTB: reg_portb <= i_data;
                    // PORT C
                    DDRC:  reg_ddrc  <= i_data;
                    PORTC: reg_portc <= i_data;
                    // PORT D
                    DDRD:  reg_ddrd  <= i_data;
                    PORTD: reg_portd <= i_data;
                    // PORT E
                    DDRE:  reg_ddre  <= i_data;
                    PORTE: reg_porte <= i_data;
                endcase
            end
            
            // Read from GPIO registers
            if (i_re) begin
                is_io_read_reg <= (i_addr < 16'h0100);
                
                case(i_addr)
                    // PORT B
                    PINB:  io_rdata_reg <= pin_b;
                    DDRB:  io_rdata_reg <= reg_ddrb;
                    PORTB: io_rdata_reg <= reg_portb;
                    // PORT C
                    PINC:  io_rdata_reg <= pin_c;
                    DDRC:  io_rdata_reg <= reg_ddrc;
                    PORTC: io_rdata_reg <= reg_portc;
                    // PORT D
                    PIND:  io_rdata_reg <= pin_d;
                    DDRD:  io_rdata_reg <= reg_ddrd;
                    PORTD: io_rdata_reg <= reg_portd;
                    // PORT E
                    PINE:  io_rdata_reg <= pin_e;
                    DDRE:  io_rdata_reg <= reg_ddre;
                    PORTE: io_rdata_reg <= reg_porte;
                    
                    default:  io_rdata_reg <= 8'h00;
                endcase
            end
        end
    end

    // MUX to choose output data source: GPIO/SRAM
    assign o_rdata = is_io_read_reg ? io_rdata_reg : sram_rdata;

    // Tristate buffers generation for GPIO ports
    // When DDRx = 1, then PINx = PORTx
    // When DDRx = 0, then PINx = z
    // All PINx are automatically pulled-up to Vcc
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : gpio_buffers
            assign io_gpio[i]    = reg_ddrb[i] ? reg_portb[i] : 1'bz;
            assign io_gpio[8+i]  = reg_ddrc[i] ? reg_portc[i] : 1'bz;
            assign io_gpio[16+i] = reg_ddrd[i] ? reg_portd[i] : 1'bz;
            assign io_gpio[24+i] = reg_ddre[i] ? reg_porte[i] : 1'bz;
        end
    endgenerate

endmodule
