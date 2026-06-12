`ifndef AXI_SPI_COVERAGE_SV
`define AXI_SPI_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_spi_item.sv"

class axi_spi_coverage extends uvm_subscriber #(axi_spi_item);
    `uvm_component_utils(axi_spi_coverage)
    
    axi_spi_item tx;

  
    covergroup spi_cg;
        
        cp_cpol : coverpoint tx.cpol_val {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        
        cp_cpha : coverpoint tx.cpha_val {
            bins first_edge  = {1'b0};
            bins second_edge = {1'b1};
        }

       
        cx_mode : cross cp_cpol, cp_cpha;

  
        cp_master_data : coverpoint tx.master_data {
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            bins toggling  = {8'hAA, 8'h55};
            bins others    = default;
        }

     
        cp_slave_data : coverpoint tx.slave_data {
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            bins others    = default;
        }

        
        cp_data_match : coverpoint (tx.master_data == tx.slave_data) {
            bins matched    = {1'b1};
            bins mismatched = {1'b0};
        }
    endgroup

    function new(string name = "axi_spi_coverage", uvm_component parent);
        super.new(name, parent);
        spi_cg = new();
    endfunction

  
    function void write(axi_spi_item t);
        tx = t;
        spi_cg.sample();
    endfunction

   
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "======= AXI-SPI Coverage Summary =======", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Total Coverage : %.2f%%", spi_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Mode (CPOL/CPHA) Cross : %.2f%%", spi_cg.cx_mode.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Data Match (Master==Slave) : %.2f%%", spi_cg.cp_data_match.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "========================================\n", UVM_LOW);
    endfunction

endclass

`endif