`ifndef AXI_SPI_INTERFACE_SV
`define AXI_SPI_INTERFACE_SV

interface axi_spi_interface (
    input logic clk, 
    input logic reset
);
    // AXI4-Lite 신호 정의
    logic [3:0]  awaddr;  logic awvalid; logic awready;
    logic [31:0] wdata;   logic wvalid;  logic wready;
    logic [1:0]  bresp;   logic bvalid;  logic bready;
    logic [3:0]  araddr;  logic arvalid; logic arready;
    logic [31:0] rdata;   logic [1:0] rresp; logic rvalid; logic rready;

    // SPI 물리 핀 및 모니터 신호
    logic sclk, mosi, miso, cs_n;
    logic [7:0] s_tx_data, s_rx_data;
    logic       s_done;

    // ---------------------------------------------------------
    // AXI Write Task 
    // ---------------------------------------------------------
    task axi_write(input [3:0] addr, input [31:0] data);
        $display("[%0t] [AXI_WRITE] Start - Addr:0x%h, Data:0x%h", $time, addr, data);
        @(posedge clk);
        awaddr  <= addr;
        awvalid <= 1'b1;
        wdata   <= data;
        wvalid  <= 1'b1;
        bready  <= 1'b1;

        $display("[%0t] [AXI_WRITE] Waiting for AWREADY & WREADY...", $time);
        wait (awready && wready); 
        
        $display("[%0t] [AXI_WRITE] AWREADY & WREADY OK!", $time);
        @(posedge clk);
        awvalid <= 1'b0;
        wvalid  <= 1'b0;
        
        $display("[%0t] [AXI_WRITE] Waiting for BVALID...", $time);
        wait (bvalid);
        
        $display("[%0t] [AXI_WRITE] BVALID OK! Write Done.", $time);
        @(posedge clk);
        bready  <= 1'b0;
    endtask

    // ---------------------------------------------------------
    // AXI Read Task 
    // ---------------------------------------------------------
    task axi_read(input [3:0] addr, output [31:0] data);
        $display("[%0t] [AXI_READ] Start - Addr:0x%h", $time, addr);
        @(posedge clk);
        araddr  <= addr;
        arvalid <= 1'b1;
        rready  <= 1'b1;

        $display("[%0t] [AXI_READ] Waiting for ARREADY...", $time);
        wait (arready);
        
        $display("[%0t] [AXI_READ] ARREADY OK!", $time);
        @(posedge clk);
        arvalid <= 1'b0;
        
        $display("[%0t] [AXI_READ] Waiting for RVALID...", $time);
        wait (rvalid);
        
        data = rdata;
        $display("[%0t] [AXI_READ] RVALID OK! Data:0x%h", $time, data);
        @(posedge clk);
        rready <= 1'b0;
    endtask

    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input sclk, mosi, miso, cs_n, s_rx_data, s_done, s_tx_data;
    endclocking

endinterface
`endif