`ifndef AXI_SPI_TEST_SV
`define AXI_SPI_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_spi_env.sv"
`include "axi_spi_sequence.sv"


class axi_spi_base_test extends uvm_test;
    `uvm_component_utils(axi_spi_base_test)

    axi_spi_env env;

    function new(string name = "axi_spi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_spi_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== UVM 계층 구조 (AXI-SPI) =====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction
endclass



class axi_spi_sanity_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_sanity_test)

    function new(string name = "axi_spi_sanity_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_spi_sanity_seq seq;
        phase.raise_objection(this);

        seq = axi_spi_sanity_seq::type_id::create("seq");
        seq.num_loop = 100;

        `uvm_info(get_type_name(), "=== Test 1: Sanity Test 시작 ===", UVM_LOW)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass



class axi_spi_mode_sweep_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_mode_sweep_test)

    function new(string name = "axi_spi_mode_sweep_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_spi_mode_sweep_seq seq;
        phase.raise_objection(this);

        seq = axi_spi_mode_sweep_seq::type_id::create("seq");
        seq.num_per_mode = 10;  

        `uvm_info(get_type_name(), "=== Test 2: Mode Sweep Test 시작 ===", UVM_LOW)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass



class axi_spi_stress_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_stress_test)

    function new(string name = "axi_spi_stress_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_spi_stress_seq seq;
        phase.raise_objection(this);

        seq = axi_spi_stress_seq::type_id::create("seq");
        seq.num_loop = 200;

        `uvm_info(get_type_name(), "=== Test 3: Stress Test 시작 ===", UVM_LOW)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass



class axi_spi_corner_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_corner_test)

    function new(string name = "axi_spi_corner_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_spi_corner_seq seq;
        phase.raise_objection(this);

        seq = axi_spi_corner_seq::type_id::create("seq");

        `uvm_info(get_type_name(), "=== Test 4: Corner Case Test 시작 ===", UVM_LOW)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass



class axi_spi_regression_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_regression_test)

    function new(string name = "axi_spi_regression_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_spi_sanity_seq     s1;
        axi_spi_mode_sweep_seq s2;
        axi_spi_stress_seq     s3;
        axi_spi_corner_seq     s4;
        phase.raise_objection(this);

        s1 = axi_spi_sanity_seq::type_id::create("s1");
        s2 = axi_spi_mode_sweep_seq::type_id::create("s2");
        s3 = axi_spi_stress_seq::type_id::create("s3");
        s4 = axi_spi_corner_seq::type_id::create("s4");

        s1.num_loop      = 50;
        s2.num_per_mode  = 5;
        s3.num_loop      = 100;

        `uvm_info(get_type_name(), "=== Test 5: Full Regression 시작 ===", UVM_LOW)
        s1.start(env.agt.sqr);
        s2.start(env.agt.sqr);
        s3.start(env.agt.sqr);
        s4.start(env.agt.sqr);
        `uvm_info(get_type_name(), "=== Full Regression 완료 ===", UVM_LOW)

        phase.drop_objection(this);
    endtask
endclass

`endif