`ifndef CAM_SET_TEST_SV
`define CAM_SET_TEST_SV

class cam_set_base_test extends uvm_test;
    `uvm_component_utils(cam_set_base_test)

    cam_set_env env;

    function new(string name = "cam_set_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cam_set_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
endclass

class cam_set_sanity_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_sanity_test)

    function new(string name = "cam_set_sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_smoke_sequence seq;
        phase.raise_objection(this);
        seq = cam_set_smoke_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #1us;
        phase.drop_objection(this);
    endtask
endclass

class cam_set_full_frame_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_full_frame_test)

    function new(string name = "cam_set_full_frame_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_full_frame_sequence seq;
        phase.raise_objection(this);
        seq = cam_set_full_frame_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #1us;
        phase.drop_objection(this);
    endtask
endclass

class cam_set_random_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_random_test)

    function new(string name = "cam_set_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_random_sequence seq;
        phase.raise_objection(this);
        seq = cam_set_random_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #1us;
        phase.drop_objection(this);
    endtask
endclass

class cam_set_sccb_init_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_sccb_init_test)

    function new(string name = "cam_set_sccb_init_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        uvm_config_db#(bit)::set(this, "env.scb", "require_sccb_complete", 1'b1);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Waiting for complete SCCB initialization", UVM_LOW)
        #90ms;
        phase.drop_objection(this);
    endtask
endclass
class cam_set_integration_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_integration_test)

    function new(string name = "cam_set_integration_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        uvm_config_db#(bit)::set(
            this, "env.scb", "require_sccb_complete", 1'b1
        );
        uvm_config_db#(int unsigned)::set(
            this, "env.scb", "required_camera_writes", 153608
        );
        uvm_config_db#(int unsigned)::set(
            this, "env.scb", "required_fb_reads", 307246
        );
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_smoke_sequence      smoke_sequence;
        cam_set_full_frame_sequence full_sequence;
        cam_set_full_read_sequence  full_read_sequence;
        cam_set_random_sequence     random_sequence;
        bit init_completed;

        phase.raise_objection(this);
        init_completed = 1'b0;

        `uvm_info(get_type_name(),
            "Waiting for complete SCCB initialization before camera input",
            UVM_LOW)

        fork
            begin
                env.sccb_init_done.wait_on();
                init_completed = 1'b1;
            end
            begin
                #100ms;
            end
        join_any
        disable fork;

        if (!init_completed) begin
            `uvm_fatal(get_type_name(),
                "SCCB initialization did not complete within 100 ms")
        end

        // Allow the final STOP to settle before checking the idle bus state.
        #1us;
        if ((env.agent.monitor.vif.scl !== 1'b1) ||
            (env.agent.monitor.vif.sda !== 1'b1)) begin
            `uvm_fatal(get_type_name(), $sformatf(
                "SCCB bus is not idle after initialization: SCL=%b SDA=%b",
                env.agent.monitor.vif.scl,
                env.agent.monitor.vif.sda
            ))
        end

        `uvm_info(get_type_name(),
            "SCCB initialization complete; starting camera and full-read sequences",
            UVM_LOW)

        smoke_sequence = cam_set_smoke_sequence::type_id::create(
            "smoke_sequence"
        );
        full_sequence = cam_set_full_frame_sequence::type_id::create(
            "full_sequence"
        );
        full_read_sequence = cam_set_full_read_sequence::type_id::create(
            "full_read_sequence"
        );
        random_sequence = cam_set_random_sequence::type_id::create(
            "random_sequence"
        );

        smoke_sequence.start(env.agent.sequencer);
        full_sequence.start(env.agent.sequencer);
        full_read_sequence.start(env.agent.sequencer);
        random_sequence.start(env.agent.sequencer);
        #1us;

        phase.drop_objection(this);
    endtask
endclass

class cam_set_regression_test extends cam_set_base_test;
    `uvm_component_utils(cam_set_regression_test)

    function new(string name = "cam_set_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_smoke_sequence     smoke_sequence;
        cam_set_full_frame_sequence full_sequence;
        cam_set_random_sequence    random_sequence;

        phase.raise_objection(this);

        smoke_sequence = cam_set_smoke_sequence::type_id::create("smoke_sequence");
        full_sequence  = cam_set_full_frame_sequence::type_id::create("full_sequence");
        random_sequence = cam_set_random_sequence::type_id::create("random_sequence");

        smoke_sequence.start(env.agent.sequencer);
        full_sequence.start(env.agent.sequencer);
        random_sequence.start(env.agent.sequencer);
        #1us;

        phase.drop_objection(this);
    endtask
endclass

`endif
