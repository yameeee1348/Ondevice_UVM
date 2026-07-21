`ifndef CAM_SET_ENV_SV
`define CAM_SET_ENV_SV

class cam_set_env extends uvm_env;
    `uvm_component_utils(cam_set_env)

    cam_set_agent      agent;
    cam_set_scoreboard scb;
    cam_set_coverage   coverage;
    uvm_event          sccb_init_done;

    function new(string name = "cam_set_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sccb_init_done = new("sccb_init_done");
        uvm_config_db#(uvm_event)::set(
            this, "scb", "sccb_init_done", sccb_init_done
        );
        agent    = cam_set_agent::type_id::create("agent", this);
        scb      = cam_set_scoreboard::type_id::create("scb", this);
        coverage = cam_set_coverage::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scb.analysis_imp);
        agent.monitor.ap.connect(coverage.analysis_export);
    endfunction
endclass

`endif
