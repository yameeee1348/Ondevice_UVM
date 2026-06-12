`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;


`include "axi_spi_pkg.sv"
import axi_spi_pkg::*;

`include "axi_spi_interface.sv"

module tb_top ();

    logic clk;
    logic reset;
    logic aresetn;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset   = 1;
        aresetn = 0;
        repeat (10) @(posedge clk);
        reset   = 0;
        aresetn = 1;
    end

  
    axi_spi_interface vif(.clk(clk), .reset(reset), .aresetn(aresetn));

    axi_spi_m_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        .s00_axi_aclk    (clk),
        .s00_axi_aresetn (aresetn),
        .s00_axi_awaddr  (vif.awaddr),  .s00_axi_awprot (3'b0),
        .s00_axi_awvalid (vif.awvalid), .s00_axi_awready(vif.awready),
        .s00_axi_wdata   (vif.wdata),   .s00_axi_wstrb  (4'hF),
        .s00_axi_wvalid  (vif.wvalid),  .s00_axi_wready (vif.wready),
        .s00_axi_bresp   (vif.bresp),   .s00_axi_bvalid (vif.bvalid),
        .s00_axi_bready  (vif.bready),
        .s00_axi_araddr  (vif.araddr),  .s00_axi_arprot (3'b0),
        .s00_axi_arvalid (vif.arvalid), .s00_axi_arready(vif.arready),
        .s00_axi_rdata   (vif.rdata),   .s00_axi_rresp  (vif.rresp),
        .s00_axi_rvalid  (vif.rvalid),  .s00_axi_rready (vif.rready),
        .sclk (vif.sclk),
        .mosi (vif.mosi),
        .miso (vif.miso),
        .cs_n (vif.cs_n)
    );

    SPI_slave dummy_slave (
        .clk     (clk),
        .reset   (reset),
        .cpol    (dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg1[1]),
        .cpha    (dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg1[2]),
        .tx_data (vif.s_tx_data),
        .sclk    (vif.sclk),
        .mosi    (vif.mosi),
        .cs_n    (vif.cs_n),
        .miso    (vif.miso),
        .rx_data (vif.s_rx_data),
        .done    (vif.s_done)
    );

    assign vif.bd_spi_rx_data = dut.axi_spi_m_v1_0_S00_AXI_inst.spi_rx_data;

    initial begin
        uvm_config_db#(virtual axi_spi_interface)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        $fsdbDumpfile("axi_spi_test.fsdb");
        $fsdbDumpvars(0, tb_top);
        $fsdbDumpMDA();
    end

endmodule