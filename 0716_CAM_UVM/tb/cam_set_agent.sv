`ifndef CAM_SET_AGENT_SV
`define CAM_SET_AGENT_SV

typedef uvm_sequencer #(cam_set_item) cam_set_sequencer;

class cam_set_agent extends uvm_agent;
    `uvm_component_utils(cam_set_agent)

    cam_set_sequencer sequencer;
    cam_set_driver    driver;
    cam_set_monitor   monitor;

    function new(string name = "cam_set_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = cam_set_sequencer::type_id::create("sequencer", this);
        driver    = cam_set_driver::type_id::create("driver", this);
        monitor   = cam_set_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

`endif
