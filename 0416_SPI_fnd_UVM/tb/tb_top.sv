`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;


`include "spi_interface.sv"
`include "spi_item.sv"
`include "spi_sequence.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"

`include "spi_agent.sv" 
`include "spi_scoreboard.sv"
`include "spi_coverage.sv"
`include "spi_env.sv"
`include "spi_test.sv"

module tb_top ();

 
    logic clk;
    logic reset;

  
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

   
    initial begin
        reset = 1;
        repeat (10) @(posedge clk);
        reset = 0;
    end


    spi_if vif(
        .clk(clk),
        .reset(reset)
    );

 
    SPI_Core_Top dut (
        .clk        (clk),
        .reset      (reset),
        
        // Master Control
        .m_cpol     (vif.m_cpol),
        .m_cpha     (vif.m_cpha),
        .m_clk_div  (vif.m_clk_div),
        .m_start    (vif.m_start),
        .m_tx_data  (vif.m_tx_data),
        .m_rx_data  (vif.m_rx_data),
        .m_done     (vif.m_done),
        .m_busy     (vif.m_busy),

        // Slave Control
        .s_tx_data  (vif.s_tx_data),
        .s_rx_data  (vif.s_rx_data),
        .s_done     (vif.s_done)
        
      
    );

  
    initial begin
        // Virtual Interface를 UVM DB에 등록
        uvm_config_db#(virtual spi_if)::set(null, "*", "vif", vif);
        
        // 시뮬레이션 실행 
        run_test();
    end


    initial begin
        $fsdbDumpfile("spi_test.fsdb");
        $fsdbDumpvars(0, tb_top, "+all");
    end

endmodule