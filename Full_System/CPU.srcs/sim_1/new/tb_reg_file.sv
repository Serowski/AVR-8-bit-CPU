`timescale 1ns / 1ps


module tb_reg_file();
    //
    localparam int ADDR_WIDTH = 5;
    localparam int D_WIDTH = 8;
    logic aclk;    
    // Dwa porty do odczytu
    logic [ADDR_WIDTH-1:0] i_rd_addr1;
    logic [ADDR_WIDTH-1:0] i_rd_addr2;
    logic [D_WIDTH-1:0] o_rd_data1;
    logic [D_WIDTH-1:0] o_rd_data2;
        
    //Jeden port do zapisu
    logic i_wr_en;
    logic [ADDR_WIDTH-1:0] i_wr_addr;
    logic [D_WIDTH-1:0] i_wr_data;
    
    reg_file #(
        .D_WIDTH(D_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REG_COUNT(32)
    )dut(
        .aclk(aclk),
        .i_rd_addr1(i_rd_addr1),
        .i_rd_addr2(i_rd_addr2), 
        .o_rd_data1(o_rd_data1), 
        .o_rd_data2(o_rd_data2),
        .i_wr_en(i_wr_en),
        .i_wr_addr(i_wr_addr),
        .i_wr_data(i_wr_data)         
    );
    
    
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end
    
    initial begin
        i_wr_en   = 0;
        i_wr_addr = 0;
        i_wr_data = 0;
        i_rd_addr1 = 0;
        i_rd_addr2 = 0;
        
        // Czekamy na pierwszy pełny cykl zegara, żeby wszystko się ustabilizowało
        #10;
        i_rd_addr1 = 5'd16; // Sprawdzamy R16
        i_rd_addr2 = 5'd17; // Sprawdzamy R17
        #10;

        // --- TEST 2: Zapis do rejestru R16 ---
        $display("\n--- TEST 2: Zapis wartości 0xAA do R16 ---");
        // Dobra praktyka: sygnały sterujące zmieniamy na opadającym zboczu zegara,
        // aby były stabilne, gdy przyjdzie zbocze rosnące (zapisujące).
        @(negedge aclk); 
        i_wr_en   = 1;
        i_wr_addr = 5'd01;    // Zapisz do R16
        i_wr_data = 8'hAA;    // Wartość do zapisania
        
        @(negedge aclk); // Czekamy jeden cykl, zapis dokonał się na zboczu rosnącym w międzyczasie
        i_wr_en   = 0;    // Wyłączamy zapis
        
        // Odczyt R16 przez port 1 (dane powinny pojawić się "natychmiast" dzięki assign)
        i_rd_addr1 = 5'd01; 
        #10;

        // --- TEST 3: Zapis do R17 i jednoczesny odczyt ---
        $display("\n--- TEST 3: Zapis 0xBB do R17 i odczyt dwóch różnych rejestrów ---");
        @(negedge aclk);
        i_wr_en   = 1;
        i_wr_addr = 5'd17;
        i_wr_data = 8'hBB;
        
        @(negedge aclk);
        i_wr_en   = 0;
        
        i_rd_addr1 = 5'd01; // Czytamy R16 na porcie 1 (powinno być AA)
        i_rd_addr2 = 5'd17; // Czytamy R17 na porcie 2 (powinno być BB)
        #10;

        // --- TEST 4: Próba zapisu z wyłączonym Write Enable (Zabezpieczenie) ---
        $display("\n--- TEST 4: Próba zapisu do R16 z i_wr_en = 0 (nie powinno zmienić danych) ---");
        @(negedge aclk);
        i_wr_en   = 0;         // ZAPIS WYŁĄCZONY!
        i_wr_addr = 5'd01;
        i_wr_data = 8'hFF;     // Próbujemy nadpisać AA na FF
        
        @(negedge aclk);
        i_rd_addr1 = 5'd01;    // Sprawdzamy R16 (nadal powinno być AA!)
        #10;

        $display("\nKoniec symulacji!");
        $finish; // Zakończenie pracy symulatora
    end
    
endmodule
