`ifndef AGENT_SV
`define AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_seq_item.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"

typedef uvm_sequencer #(uart_seq_item) uart_sequencer;


class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    uart_driver  drv;
    uart_sequencer sqr;
    uart_monitor mon;

    uvm_analysis_port #(uart_seq_item) agt_ap_rx;
    uvm_analysis_port #(uart_seq_item) agt_ap_tx;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        agt_ap_rx = new("agt_ap_rx", this);
        agt_ap_tx = new("agt_ap_tx", this);

    endfunction //new()


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = uart_monitor::type_id::create("mon", this);

        if (get_is_active() == UVM_ACTIVE) begin
            `uvm_info(get_type_name(), "Aent is ACTIVE: Building Sequencer and Driver ", UVM_LOW);
            sqr = uart_sequencer::type_id::create("sqr", this);
            drv    = uart_driver::type_id::create("drv", this);
        end else begin
            `uvm_info(get_type_name(), "Agent is Passive: building mon only",UVM_LOW)
        end
        
    endfunction



    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        mon.mon_ap_rx.connect(this.agt_ap_rx);
        mon.mon_ap_tx.connect(this.agt_ap_tx);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end

    endfunction

 


endclass //











`endif 