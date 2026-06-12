`ifndef AXI_SPI_DRIVER_SV
`define AXI_SPI_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_spi_item.sv"

class axi_spi_driver extends uvm_driver #(axi_spi_item);
    `uvm_component_utils(axi_spi_driver)
    virtual axi_spi_interface vif;

    function new(string name = "axi_spi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_spi_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "VIF get failed!")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.awvalid <= 0; vif.wvalid  <= 0; vif.arvalid <= 0;
        vif.bready  <= 0; vif.rready  <= 0;

        `uvm_info(get_type_name(), "Waiting for reset release...", UVM_LOW)
        wait(vif.reset == 0);
        `uvm_info(get_type_name(), "Reset released. Starting Driver Loop.", UVM_LOW)

        forever begin
            axi_spi_item tr;
            seq_item_port.get_next_item(tr);
            vif.s_tx_data = tr.slave_data;

            `uvm_info(get_type_name(), "Calling drive_axi()...", UVM_MEDIUM)
            drive_axi(tr);
            `uvm_info(get_type_name(), "drive_axi() finished.", UVM_MEDIUM)

            seq_item_port.item_done();
        end
    endtask

    task drive_axi(axi_spi_item tx);
        logic [31:0] rdata;

      

        vif.rx_valid = 1'b0;
        vif.master_tx_capture = tx.master_data;

      
        vif.axi_write(4'h4, (tx.clk_div_val << 8) | (tx.cpha_val << 2) | (tx.cpol_val << 1) | 1'b0);
        repeat(10) @(posedge vif.clk);

       
        vif.axi_write(4'h0, {24'd0, tx.master_data});

        vif.axi_write(4'h4, (tx.clk_div_val << 8) | (tx.cpha_val << 2) | (tx.cpol_val << 1) | 1'b1);
        vif.axi_write(4'h4, (tx.clk_div_val << 8) | (tx.cpha_val << 2) | (tx.cpol_val << 1) | 1'b0);

      
        do begin
            vif.axi_read(4'h8, rdata);
        end while (rdata[0] == 1'b1);  

        repeat(5) @(posedge vif.clk);

       
        vif.axi_read(4'hC, rdata);
        `uvm_info(get_type_name(), $sformatf("RX reg read = 0x%02x", rdata[7:0]), UVM_HIGH)

        
        vif.rx_valid = 1'b1;
        repeat(10) @(posedge vif.clk);
    endtask
endclass
`endif