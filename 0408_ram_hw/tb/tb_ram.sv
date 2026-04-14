`include "uvm_macros.svh"
import uvm_pkg::*;


interface ram_if(
    input logic clk);

    logic         we;
    logic [7:0]   addr;
    logic [15:0]  wdata;
    logic [15:0] rdata;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output we;
        output addr;
        output  wdata;
    endclocking


    clocking mon_cb @(posedge clk);
        default input #1step;
        input we;
        input addr;
        input  wdata;
        input  rdata;

    endclocking

endinterface //

class ram_seq_item extends uvm_sequence_item;
    rand bit we;
    rand logic [7:0] addr;
    rand logic [15:0] wdata;
    logic [15:0] rdata;


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



class ram_count_seq extends uvm_sequence#(ram_seq_item);
    `uvm_object_utils(ram_count_seq)
    int num_transactions;

    function new(string name = "ram_count_seq");
        super.new(name);
        num_transactions = 500;
    endfunction //new()

    virtual task  body();
        ram_seq_item item;
        logic [7:0] saved_addr;

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
        r_if.drv_cb.we <=item.we;
        r_if.drv_cb.addr <= item.addr;
        r_if.drv_cb.wdata <= item.wdata;
         @(posedge r_if.clk);
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
    uvm_analysis_port #(ram_seq_item) ap;
    logic [15:0] mem [0:255];
    logic [7:0] addr_past;
    logic read_done;



    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
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
        forever begin
            ram_seq_item item = ram_seq_item::type_id::create("item");
            @(r_if.mon_cb);
            item.we = r_if.mon_cb.we;
            item.addr = r_if.mon_cb.addr;
            item.wdata = r_if.mon_cb.wdata;
            item.rdata = r_if.mon_cb.rdata;
            ap.write(item);
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
        end
    endtask //



//    virtual task  run_phase(uvm_phase phase);
//        `uvm_info(get_type_name(), "run_phase 실행", UVM_DEBUG);
//        forever begin
//            
//        @(posedge r_if.clk);
//        #1;
//
//        if (read_done) begin
//           if(mem[addr_past] == r_if.rdata) begin
//            
//            `uvm_info(get_type_name(), $sformatf("일치 rdata=%0d, wdata = %0d",r_if.rdata,mem[addr_past]), UVM_LOW)
//           end else begin
//            `uvm_error(get_type_name(), $sformatf("불일치 예상 = %0d, 실제 =%0d",
//                                                         mem[addr_past], r_if.rdata))
//           end
//        end 
//        if (!r_if.we) begin
//            addr_past = r_if.addr; 
//            read_done = 1;
//        
//        end else begin
//            mem[r_if.addr] <= r_if.wdata; 
//            read_done = 0;
//        end
//        end
//
//    endtask //
    
   
endclass //ram_monitor


class ram_coverage extends uvm_subscriber #(ram_seq_item);
    `uvm_component_utils(ram_coverage)
    ram_seq_item item;

//    covergroup ram_cg;
//        cp_we: coverpoint item.we {bins on = {0}; bins off = {1};}
//        cp_addr: coverpoint item.addr{bins bottom = {[1:2]}; bins mid ={[3:5]}; bins top ={[6:7]};}
//        cp_wdata: coverpoint item.wdata{bins w_zero = {0}; bins w_low = {[1:7]}; bins w_high = {[8:14]}; bins w_max = {15};}
//        cp_rdata: coverpoint item.rdata{bins r_zero = {0}; bins r_low = {[1:7]}; bins r_high = {[8:14]}; bins r_max = {15};}
//
//        endgroup

    covergroup ram_cg;
     
        cp_we: coverpoint item.we {
            bins read  = {0}; 
            bins write = {1};
        }
        
        
        cp_addr: coverpoint item.addr {
            bins bottom = {[0:85]}; 
            bins mid    = {[86:170]}; 
            bins top    = {[171:255]};
        }
        
//        
//        cp_wdata: coverpoint item.wdata {
//            bins w_zero   = {0}; 
//            bins w_others = {[1:65534]}; 
//            bins w_max    = {16'hFFFF}; // 65535
//        }
//        
//        cp_rdata: coverpoint item.rdata {
//            bins r_zero   = {0}; 
//            bins r_others = {[1:65534]}; 
//            bins r_max    = {16'hFFFF}; 
//        }
        cp_wdata: coverpoint item.wdata{
            bins w_low  = {[0:20000]}; 
            bins w_mid  = {[20001:40000]}; 
            bins w_high = {[40001:65535]};
        }
        
        cp_rdata: coverpoint item.rdata{
            bins r_low  = {[0:20000]}; 
            bins r_mid  = {[20001:40000]}; 
            bins r_high = {[40001:65535]};
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        ram_cg = new();
        
    endfunction //new()

    virtual function void write(ram_seq_item t);
        item = t;
        ram_cg.sample();
        `uvm_info(get_type_name(), $sformatf("ram_cg sampled: %s", item.convert2string()), UVM_MEDIUM)
        
    endfunction
     virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "/n/n======= Coverage Summary===========", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Overall: %.1f%%", ram_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" we: %.1f%%", ram_cg.cp_we.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" addr: %.1f%%", ram_cg.cp_addr.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" wdata: %.1f%%", ram_cg.cp_wdata.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" rdata: %.1f%%", ram_cg.cp_rdata.get_coverage()), UVM_LOW);
       // `uvm_info(get_type_name(), $sformatf(" cross(rst, en): %.1f%%", ram_cg.cx_rst_en.get_coverage()), UVM_LOW);
       // `uvm_info(get_type_name(), $sformatf(" cross(en, count): %.1f%%", ram_cg.cx_en_count.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "======= Coverage Summary===========/n/n", UVM_LOW);
    endfunction



endclass //ram_coverage

class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)
    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) ap_imp;
        int error_count;
        int match_count;
        logic [15:0] expected [0:255];
        logic [7:0] addr_past;
        int read_done;
        

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
        error_count = 0;
        match_count = 0;
        
        
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
    endfunction

    virtual function void write(ram_seq_item item);
        `uvm_info(get_type_name(),$sformatf("Received: %s", item.convert2string()), UVM_MEDIUM);
        `uvm_info(get_type_name(), "scoreboard Write실행", UVM_DEBUG);
        
            if (read_done) begin
            if(expected[addr_past] === item.rdata) begin
                `uvm_info(get_type_name(), $sformatf("MATCH addr= 0x%0h, rdata = %0d",addr_past ,item.rdata), UVM_LOW)
                match_count++;
            end else begin
                `uvm_error(get_type_name(), $sformatf("MISMATCH:addr = 0x%0d,expected=%0d ACTUAL(rdata) =%0d",addr_past,expected[addr_past], item.rdata))
                error_count++;
                end
            end
            if (!item.we) begin
                addr_past = item.addr; 
                read_done = 1;

            end else begin
                expected[item.addr] <= item.wdata; 
                read_done = 0;
            end
            
        
        //검증로직
        
    endfunction

    virtual function void report_phase (uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "==============Scoreboard Summary ===============", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" Total transaction = %0d", match_count + error_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" Matches = %0d", match_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" ERROR = %0d", error_count), UVM_LOW)
        if (error_count > 0) begin
            `uvm_error(get_type_name(), $sformatf(" TEST FAILED: %0d mismatches detected", error_count));
        end else begin
            `uvm_info(get_type_name(), $sformatf(" TEST PASSED: %0d ", match_count),UVM_LOW);
        end
        
    endfunction
endclass //counter_scoreboard


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
    `uvm_component_utils(ram_environment);
    ram_agent agt;
    ram_scoreboard scb;
    ram_coverage cov;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        scb = ram_scoreboard::type_id::create("scb", this);
        cov = ram_coverage::type_id::create("cov", this);
        
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
        
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