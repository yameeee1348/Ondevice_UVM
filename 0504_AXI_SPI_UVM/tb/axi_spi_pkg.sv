`ifndef AXI_SPI_PKG_SV
`define AXI_SPI_PKG_SV

package axi_spi_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"


    `include "axi_spi_item.sv"
    `include "axi_spi_sequence.sv"
    `include "axi_spi_driver.sv"
    `include "axi_spi_monitor.sv"
    `include "axi_spi_agent.sv"
    `include "axi_spi_scoreboard.sv"
    `include "axi_spi_coverage.sv"
    `include "axi_spi_env.sv"
    `include "axi_spi_test.sv"
endpackage

`endif