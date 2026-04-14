`ifndef TEST_SV
`define TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_env.sv"
`include "uart_sequence.sv"



class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)
    uart_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env",this);

    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "=============== UVM 구조 ==============", UVM_NONE)            
        uvm_top.print_topology();
    endfunction


endclass //

class uart_rand_test extends uart_base_test;
    `uvm_component_utils(uart_rand_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);

    endfunction //new()

    virtual task  run_phase(uvm_phase phase);
        uart_rand_seq seq;

        phase.raise_objection(this);
        seq = uart_rand_seq::type_id::create("seq");
        seq.num_loop = 300;
        seq.start(env.agt.sqr);
        #(2ms);
        phase.drop_objection(this);
        
    endtask //

endclass //uart_rand_test


// 3. Pattern Test 

class uart_pattern_test extends uart_base_test;
    `uvm_component_utils(uart_pattern_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual task run_phase(uvm_phase phase);
        uart_pattern_seq seq;
        
        phase.raise_objection(this);
        
        seq = uart_pattern_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        
        #(2ms);

        phase.drop_objection(this);
    endtask

endclass // uart_pattern_test









`endif 