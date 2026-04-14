`include "uvm_macros.svh"
import uvm_pkg::*;

interface counter_if(
    input logic clk
    );
    
    
    logic        rst_n;
    logic        enable;
    logic [3:0] count;

endinterface //interfacename

class counter_seq_item extends uvm_sequence_item;
    rand bit rst_n;
    rand bit enable;
    rand bit cycles;
    logic [3:0] count;

    constraint c_cycles {cycles inside {[1:20]};}

    `uvm_object_utils_begin(counter_seq_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(enable, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
        `uvm_field_int(count, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "counter_seq-item");
        super.new(name);
        
    endfunction //new()


    function string convert2string();
        return $sformatf("rst_n = %0b enable = %0b cycles=%0d count=%0h", rst_n, enable, cycles, count);
        
        
    endfunction
endclass //


class counter_reset_seq extends uvm_sequence#(counter_seq_item);
    `uvm_object_utils(counter_reset_seq)
    
    function new(string name = "counter_reset_seq");
            super.new(name);
    endfunction //new()

    virtual task  body();
        counter_seq_item item;
        item = counter_seq_item::type_id::create("item");

        start_item(item);
        item.rst_n = 0;
        item.enable = 0;
        item.cycles = 2;
        finish_item(item);
        `uvm_info(get_type_name(), "Reset Done", UVM_MEDIUM)
    endtask //
endclass //counter_reset_seq 

class counter_count_seq extends uvm_sequence#(counter_seq_item);
    `uvm_object_utils(counter_count_seq)
    int num_transactions;

    function new(string name = "counter_count_seq");
            super.new(name);
            num_transactions = 0;
    endfunction //new()

    virtual task  body();
    counter_seq_item item;
    for (int i = 0; i<num_transactions; i++) begin
        item = counter_seq_item::type_id::create($sformatf("item_%0d",i));

        start_item(item);
        if (!item.randomize() with {
                rst_n == 1;
                enable == 1;
                cycles inside {[1:5]};
            }) 
            `uvm_fatal(get_type_name(), "Randomization FAILED")
        finish_item(item);

        `uvm_info(get_type_name(),$sformatf(
                "[%0d/%0d] %s", i+1, num_transactions, item.convert2string()), UVM_HIGH)
    end
        
    endtask //
endclass //counter_count_seq 


class counter_master_seq extends uvm_sequence#(counter_seq_item);
    `uvm_object_utils(counter_master_seq)
    
    function new(string name = "counter_master_seq");
            super.new(name);
    endfunction //new()

    virtual task  body();
        counter_reset_seq reset_seq;
        counter_count_seq count_seq;

        `uvm_info(get_type_name(), "========= phase 1: RESET ==========", UVM_MEDIUM)
        reset_seq = counter_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer);


        `uvm_info(get_type_name(), "========= phase 2: COUNT ==========", UVM_MEDIUM)
        count_seq = counter_count_seq::type_id::create("count_seq");
        count_seq.num_transactions =5;
        count_seq.start(m_sequencer);


        `uvm_info(get_type_name(), "========= phase 3: Sequence Done ==========", UVM_MEDIUM)

    endtask //
endclass //counter_master_seq 


class counter_driver extends uvm_driver #(counter_seq_item);
    `uvm_component_utils(counter_driver)
    virtual counter_if c_if;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        if(!uvm_config_db#(virtual counter_if)::get(this, "","c_if",c_if))
            `uvm_fatal(get_type_name(), "c_if를 찾을 수 없습니다.")
            `uvm_info(get_type_name(), "build_phase 실행 완료.",UVM_HIGH)
        
    endfunction

    virtual task  reset_dut();
        c_if.rst_n = 0;
        c_if.enable = 0;
        repeat(2) @(posedge c_if.clk);
        c_if.rst_n = 1;
        @(posedge c_if.clk);
        `uvm_info(get_type_name(), "리셋 완료", UVM_HIGH);
    endtask //

    virtual task  drive_item(counter_seq_item item);
        c_if.rst_n <= item.rst_n;
        c_if.enable <= item.enable;
        repeat(item.cycles) @(posedge c_if.clk);
        `uvm_info(get_type_name(), $sformatf("drive_cycles: %0d",item.cycles), UVM_HIGH)
    endtask //

    virtual task run_phase(uvm_phase phase);
        counter_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
        
    endtask

endclass //counter_driver



class counter_monitor extends uvm_monitor;
    `uvm_component_utils(counter_monitor)
    virtual counter_if c_if;
    int expected_counter;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        expected_counter = 0;
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        if(!uvm_config_db#(virtual counter_if)::get(this, "","c_if",c_if))
            `uvm_fatal(get_type_name(), "c_if를 찾을 수 없습니다.")
            `uvm_info(get_type_name(), "build_phase 실행 완료.",UVM_HIGH)
        
    endfunction


    virtual task run_phase(uvm_phase phase);
         `uvm_info(get_type_name(), "run_phase 실행", UVM_DEBUG);

        @(posedge c_if.rst_n);
        
        forever begin
            @(posedge c_if.clk);
            `uvm_info(get_type_name(), "posedge 대기 실행", UVM_DEBUG);
            #1;
            if(!c_if.rst_n) begin
                expected_counter = 0;
            end
            else if (c_if.enable) begin
                expected_counter = (expected_counter + 1) % 16;

                if (c_if.count !== expected_counter) begin
                    `uvm_error(get_type_name(), $sformatf("불일치 예상 = %0d, 실제 =%0d",
                                                         expected_counter, c_if.count))
                end
                else begin
                    `uvm_info(get_type_name(), $sformatf("일치 count=%0d",c_if.count), UVM_LOW)
                end
            end
        end
        
    endtask

    virtual function void report_phase(uvm_phase phase);

        super.report_phase(phase);
        
    endfunction
endclass //counter_monitor

class counter_agent extends uvm_agent;
    `uvm_component_utils(counter_agent)


    uvm_sequencer#(counter_seq_item) sqr;
    counter_driver drv;
    counter_monitor mon;



    function new(string name, uvm_component parent);
        super.new(name, parent);
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        sqr = uvm_sequencer#(counter_seq_item)::type_id::create("sqr", this);
        `uvm_info(get_type_name(), "sqr 생성", UVM_DEBUG);
        drv = counter_driver::type_id::create("drv",this);
        `uvm_info(get_type_name(), "drv 생성", UVM_DEBUG);
        mon = counter_monitor::type_id::create("mon",this);
         `uvm_info(get_type_name(), "mon 생성", UVM_DEBUG);

        
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        
    endfunction

    
endclass //counter_agent


class counter_environment extends uvm_env;
    `uvm_component_utils(counter_environment)

    counter_agent agt;
    


    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new 생성", UVM_DEBUG);
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        agt = counter_agent::type_id::create("agt", this);
        
    endfunction

    
endclass //counter_environment


class counter_test extends uvm_test;
    `uvm_component_utils(counter_test)
    
    counter_environment env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        env = counter_environment::type_id::create("env", this);
        `uvm_info(get_type_name(), "env 생성",UVM_DEBUG);
    endfunction
    
    virtual task  run_phase(uvm_phase phase);

    //    counter_master_seq seq;
        counter_reset_seq reset_seq;
        counter_count_seq count_seq;
      
        phase.raise_objection(this);
        //seq = counter_master_seq::type_id::create("seq");
        //seq.start(env.agt.sqr);
        reset_seq = counter_reset_seq::type_id::create("reset_seq");
        reset_seq.start(env.agt.sqr);

        count_seq = counter_count_seq::type_id::create("count_seq");
        count_seq.num_transactions = 10;
        count_seq.start(env.agt.sqr);
       
        #100;
        phase.drop_objection(this);
        
    endtask //


    

    virtual function void report_phase(uvm_phase phase);

        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "======TEST PASS", UVM_LOW)
            else `uvm_info(get_type_name(), "======TEST FAIL", UVM_LOW)
        
    endfunction
endclass //counter_test



module tb_counter ();
    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;


    end

    counter_if c_if (clk);
  

    counter dut (
        .clk(clk),
        .rst_n(c_if.rst_n),
        .enable(c_if.enable),
        .count(c_if.count)
    );

    initial begin
        uvm_config_db#(virtual counter_if)::set(null,"*", "c_if", c_if);
        run_test("counter_test");
    end


endmodule