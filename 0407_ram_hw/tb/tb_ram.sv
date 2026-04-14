`include "uvm_macros.svh"
import uvm_pkg::*;


interface ram_if(
    input logic clk);

    logic         we;
    logic [9:0]   addr;
    logic [15:0]  wdata;
    logic [15:0] rdata;

endinterface //

class ram_seq_item extends uvm_sequence_item;
    rand bit we;
    //rand bit [4:0] cycles;
    rand logic [9:0] addr;
    rand logic [15:0] wdata;
    logic [15:0] rdata;

    //constraint c_cycles {cycles inside {[1:20]};}

    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction //new()

    function string convert2string();
        return $sformatf("we = %0b addr = %0b wdata=%0d ", we, addr, wdata);
        
    endfunction
endclass //ram_seq_item

//class ram_reset_seq extends uvm_sequence#(ram_seq_item);
//    `uvm_object_utils(ram_reset_seq)
//    function new(string name = "ram_reset_seq");
//        super.new(name);
//    endfunction //new()
//
//    virtual task  body();
//        ram_seq_item item;
//        item = ram_seq_item::type_id::create("item");
//
//        start_item(item);
//        item.we = 0;
//        item.addr = 0;
//        item.wdata = 0;
//        item.cycles = 2;
//        finish_item(item);
//        `uvm_info(get_type_name(), "RESET Done", UVM_MEDIUM)
//    endtask //
//endclass //ram_reset_seq

class ram_count_seq extends uvm_sequence#(ram_seq_item);
    `uvm_object_utils(ram_count_seq)
    int num_transactions;

    function new(string name = "ram_count_seq");
        super.new(name);
        num_transactions = 10;
    endfunction //new()

    virtual task  body();
        ram_seq_item item;
        logic [9:0] saved_addr;

        for (int i = 0; i< num_transactions; i++) begin
            item = ram_seq_item::type_id::create($sformatf("item_write %0d",i));
            start_item(item);
            if(!item.randomize()with {we ==1;})
            `uvm_fatal(get_type_name(), "WRITE Randomization FAILED")
            saved_addr = item.addr;
            finish_item(item);

            `uvm_info(get_type_name(), $sformatf(
                "WRITE[%0d]: %s ",i+1,item.convert2string()), UVM_HIGH)
        
            item = ram_seq_item::type_id::create($sformatf("item_read %0d",i));
            start_item(item);
            if(!item.randomize() with {we ==0; addr == saved_addr; })
                `uvm_fatal(get_type_name(), "READ Randomization FAILED")
            finish_item(item);
            `uvm_info(get_type_name(), $sformatf(
                "READ [%0d]: %s ",i+1,item.convert2string()), UVM_HIGH)
        
        end
    endtask //
endclass //ram_count_seq


//class ram_master_seq extends uvm_sequence#(ram_seq_item);
//    `uvm_object_utils(ram_master_seq)
//    function new();
//        
//    endfunction //new()
//endclass //ram_master_seq


class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)
    virtual ram_if r_if;


    function new(string name, uvm_component parent);
        super.new(name, parent);

    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ram_if)::get(this, "", "r_if", r_if))
            `uvm_fatal(get_type_name(), "r_if를 찾을 수 없습니다.")
            `uvm_info(get_type_name(), "build_phase 실행 완료",UVM_HIGH)
        
    endfunction

    virtual task  drive_item(ram_seq_item item);
        r_if.we <=item.we;
        r_if.addr <= item.addr;
        r_if.wdata <= item.wdata;
        //repeat(item.cycles)
         @(posedge r_if.clk);
         //`uvm_info(get_type_name(), $sformatf("drive_cycles: %0d",item.cycles), UVM_HIGH)
        `uvm_info(get_type_name(), "Drive Done", UVM_HIGH)
        
    endtask //

    virtual task  run_phase(uvm_phase phase);
        ram_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask //


endclass //ram_driver

class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)
    virtual ram_if r_if;
    logic [15:0] mem [0:1023];
    logic [9:0] addr_past;
    logic read_done;



    function new(string name, uvm_component parent);
        super.new(name, parent);

        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ram_if)::get(this, "","r_if", r_if))
        `uvm_fatal(get_type_name(), "r_if를 찾을 수 없습니다.")
        `uvm_info(get_type_name(), "build_phase 실행 완료", UVM_HIGH)
        addr_past = 0;
        read_done = 0;
    endfunction

    virtual task  run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "run_phase 실행", UVM_DEBUG);
        forever begin
            
        @(posedge r_if.clk);
        #1;

        if (read_done) begin
           if(mem[addr_past] == r_if.rdata) begin
            
            `uvm_info(get_type_name(), $sformatf("일치 rdata=%0d, wdata = %0d",r_if.rdata,mem[addr_past]), UVM_LOW)
           end else begin
            `uvm_error(get_type_name(), $sformatf("불일치 예상 = %0d, 실제 =%0d",
                                                         mem[addr_past], r_if.rdata))
           end
        end 
        if (!r_if.we) begin
            addr_past = r_if.addr; 
            read_done = 1;
        
        end else begin
            mem[r_if.addr] <= r_if.wdata; 
            read_done = 0;
        end
        end

    endtask //
    
   
endclass //ram_monitor



class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    uvm_sequencer#(ram_seq_item) sqr;
    ram_driver drv;
    ram_monitor mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);

    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(ram_seq_item)::type_id::create("sqr", this);
        drv = ram_driver::type_id::create("drv", this);
        mon = ram_monitor::type_id::create("mon", this);

        
        
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        
    endfunction
endclass //ram_agent



class ram_environment extends uvm_env;
    `uvm_component_utils(ram_environment)
    ram_agent agt;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new 생성", UVM_DEBUG);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        
    endfunction

endclass //

class ram_test extends uvm_test;
    `uvm_component_utils(ram_test)

    ram_environment env;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ram_environment::type_id::create("env", this);
        
    endfunction

    virtual task  run_phase(uvm_phase phase);
    ram_count_seq count_seq;
    phase.raise_objection(this);
        count_seq = ram_count_seq::type_id::create("count_seq");
        count_seq.start(env.agt.sqr);
        #5;
    phase.drop_objection(this);
        
    endtask //

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "=======TEST PASS========",UVM_LOW)
            else `uvm_info(get_type_name(),"========TEST FAIL========",UVM_LOW)
        
    endfunction
endclass //ram_test 



module tb_ram ();

    logic clk;
    

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ram_if r_if (clk);

ram dut(
    .clk(clk),
    .we(r_if.we),
    .addr(r_if.addr),
    .wdata(r_if.wdata),
    .rdata(r_if.rdata)
);

    initial begin
        uvm_config_db#(virtual ram_if)::set(null,"*", "r_if", r_if);
        run_test("ram_test");
    end
endmodule