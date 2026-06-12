`ifndef AXI_SPI_ITEM_SV
`define AXI_SPI_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_spi_item extends uvm_sequence_item;
    
    rand bit [7:0] master_data;  
    rand bit [7:0] slave_data;   
    rand bit [7:0] clk_div_val;  
    rand bit       cpol_val;     
    rand bit       cpha_val;     

  
    bit [7:0] master_rx_val;     
    bit [7:0] slave_rx_val;      

   
    constraint c_clk_div { clk_div_val inside {[2:100]}; }

   
    
    `uvm_object_utils_begin(axi_spi_item)
        `uvm_field_int(master_data,   UVM_ALL_ON)
        `uvm_field_int(slave_data,    UVM_ALL_ON)
        `uvm_field_int(clk_div_val,   UVM_ALL_ON)
        `uvm_field_int(cpol_val,      UVM_ALL_ON)
        `uvm_field_int(cpha_val,      UVM_ALL_ON)
        `uvm_field_int(master_rx_val, UVM_ALL_ON)
        `uvm_field_int(slave_rx_val,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_spi_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("Mode(P:%b,A:%b) Div:%0d | M_TX:0x%h, S_TX:0x%h | M_RX:0x%h, S_RX:0x%h", 
                         cpol_val, cpha_val, clk_div_val, 
                         master_data, slave_data, 
                         master_rx_val, slave_rx_val);
    endfunction
endclass

`endif