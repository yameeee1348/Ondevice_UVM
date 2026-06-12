`ifndef SPI_TEST_SV
`define SPI_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


`include "spi_env.sv"
`include "spi_sequence.sv"

// ==========================================
// 1. SPI Base Test
// ==========================================
class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)
    
    spi_env env;

    function new(string name = "spi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        env = spi_env::type_id::create("env", this);
    endfunction // build_phase

   
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "============= UVM 계층 구조 (SPI) ===========", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        
    endtask
endclass // spi_base_test


// ==========================================
// 2. SPI Sanity Test 
// ==========================================
class spi_sanity_test extends spi_base_test;
    `uvm_component_utils(spi_sanity_test)

    function new(string name = "spi_sanity_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_sanity_seq seq;
        phase.raise_objection(this);
        
        seq = spi_sanity_seq::type_id::create("seq");
        seq.num_loop = 100; 
        
        `uvm_info(get_type_name(), "SPI Sanity Test 시작...", UVM_LOW)
        seq.start(env.agt.sqr); 
        
        phase.drop_objection(this);
    endtask
endclass // spi_sanity_test


// ==========================================
// 3. SPI Mode Sweep Test (CPOL/CPHA 조합 테스트)
// ==========================================
class spi_mode_sweep_test extends spi_base_test;
    `uvm_component_utils(spi_mode_sweep_test)

    function new(string name = "spi_mode_sweep_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_mode_sweep_seq seq;
        phase.raise_objection(this);
        
        seq = spi_mode_sweep_seq::type_id::create("seq");
        
        `uvm_info(get_type_name(), "SPI Mode Sweep Test (0,1,2,3) 시작...", UVM_LOW)
        seq.start(env.agt.sqr);
        
        phase.drop_objection(this);
    endtask
endclass // spi_mode_sweep_test


// ==========================================
// 4. SPI Speed Stress Test (고속 타이밍 테스트)
// ==========================================
class spi_stress_test extends spi_base_test;
    `uvm_component_utils(spi_stress_test)

    function new(string name = "spi_stress_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_speed_stress_seq seq;
        phase.raise_objection(this);
        
        seq = spi_speed_stress_seq::type_id::create("seq");
        
        `uvm_info(get_type_name(), "SPI Speed Stress Test 시작...", UVM_LOW)
        seq.start(env.agt.sqr);
        
        phase.drop_objection(this);
    endtask
endclass // spi_stress_test

`endif