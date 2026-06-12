`ifndef AXI_SPI_SCOREBOARD_SV
`define AXI_SPI_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_spi_item.sv"

class axi_spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_spi_scoreboard)

    uvm_analysis_imp#(axi_spi_item, axi_spi_scoreboard) ap_imp;

 
    logic [7:0] expected_rx_q[$];

    int total_trans = 0;
    int pass_ms     = 0;  
    int pass_sm     = 0;  
    int err_count   = 0;

    function new(string name = "axi_spi_scoreboard", uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    virtual function void write(axi_spi_item tx);
        total_trans++;

    
        if (tx.master_data !== tx.slave_rx_val) begin
            `uvm_error(get_type_name(),
                $sformatf("[FAIL M->S] #%0d | Master_TX=0x%02x, Slave_RX=0x%02x",
                          total_trans, tx.master_data, tx.slave_rx_val))
            err_count++;
        end else begin
            `uvm_info(get_type_name(),
                $sformatf("[PASS M->S] #%0d | 0x%02x", total_trans, tx.master_data),
                UVM_HIGH)
            pass_ms++;
        end

     
        expected_rx_q.push_back(tx.slave_data);

       
        if (expected_rx_q.size() > 1) begin
            logic [7:0] expected_rx;
            expected_rx = expected_rx_q.pop_front();

            if (tx.master_rx_val !== expected_rx) begin
                `uvm_error(get_type_name(),
                    $sformatf("[FAIL S->M] #%0d | Expected=0x%02x, Actual=0x%02x",
                              total_trans, expected_rx, tx.master_rx_val))
                err_count++;
            end else begin
                `uvm_info(get_type_name(),
                    $sformatf("[PASS S->M] #%0d | 0x%02x", total_trans, expected_rx),
                    UVM_HIGH)
                pass_sm++;
            end
        end
    endfunction

 
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (expected_rx_q.size() > 0) begin
            `uvm_warning(get_type_name(),
                $sformatf("[S->M] 마지막 %0d개 트랜잭션의 slave_data(0x%02x)는 검증 불가 (후속 트랜잭션 없음)",
                          expected_rx_q.size(), expected_rx_q[0]))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), "          AXI-SPI VERIFICATION SUMMARY            ", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        if (err_count == 0)
            `uvm_info(get_type_name(), " Result      : ** SUCCESS **", UVM_NONE)
        else
            `uvm_info(get_type_name(), " Result      : ** FAILURE **", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" Total Trans : %0d", total_trans),  UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" Pass  M->S  : %0d", pass_ms),      UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" Pass  S->M  : %0d", pass_sm),      UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" Error Count : %0d", err_count),    UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
    endfunction

endclass

`endif