`ifndef AXI_SPI_MONITOR_SV
`define AXI_SPI_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_spi_item.sv"

class axi_spi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_spi_monitor)

    uvm_analysis_port #(axi_spi_item) ap;
    virtual axi_spi_interface vif;

    function new(string name = "axi_spi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual axi_spi_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Monitor에서 인터페이스를 가져오지 못했습니다.");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "AXI-SPI 버스 모니터링 시작 ...", UVM_MEDIUM)
        forever begin
            collect_transaction();
        end
    endtask

    task collect_transaction();
        axi_spi_item tx;
        tx = axi_spi_item::type_id::create("tx");

      

      
        wait(vif.rx_valid === 1'b0);
        
        wait(vif.mon_cb.cs_n === 1'b0);

        wait(vif.mon_cb.cs_n === 1'b1);

        wait(vif.rx_valid === 1'b1);

    
        tx.master_data   = vif.master_tx_capture;
        tx.slave_data    = vif.mon_cb.s_tx_data;
        tx.slave_rx_val  = vif.mon_cb.s_rx_data;
        tx.master_rx_val = vif.bd_spi_rx_data;   

        `uvm_info(get_type_name(),
            $sformatf("Captured | M_TX=0x%02x S_TX=0x%02x M_RX=0x%02x S_RX=0x%02x",
                      tx.master_data, tx.slave_data,
                      tx.master_rx_val, tx.slave_rx_val),
            UVM_MEDIUM)

        ap.write(tx);
    endtask

endclass

`endif