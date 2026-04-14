`include "uvm_macros.svh"
import uvm_pkg::*;

class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)
    
    int loop_count;

    function new(string name = "hello_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        loop_count = 0;
        
        `uvm_info("PHASE", "[1] build_phase- loop_count = 0 reset", UVM_LOW);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("PHASE", "[2] connect_phase- component connect stage", UVM_LOW);
    endfunction

    virtual task  run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("PHASE", "[3]run_phase - 시뮬레이션 실행 시작.", UVM_LOW);

        for(int i = 0; i<5; i++) begin
            loop_count = i+1;
            `uvm_info("LOOP",$sformatf("test rpeat %0d/5 실행중...",loop_count), UVM_LOW)
            #10;
        end

        `uvm_info("PHASE", "[3]run_phase - 시뮬레이션 실행 완료.", UVM_LOW);
        #100;
        phase.drop_objection(this);
    endtask //

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("PHASE", $sformatf("[4] report_phase- loop_count %d 동작", loop_count), UVM_LOW);
    endfunction

endclass //

module test_uvm ();
    
    initial begin
        run_test("hello_test");
    end

endmodule