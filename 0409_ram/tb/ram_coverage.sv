`ifndef RAM_COVERAGE_SV
`define RAM_COVERAGE_SV

//`timescale  1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "ram_seq_item.sv"




class ram_coverage extends uvm_subscriber #(ram_seq_item);
    `uvm_component_utils(ram_coverage)
    ram_seq_item item;


    covergroup ram_cg;
     
        cp_wr: coverpoint item.wr {
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
        `uvm_info(get_type_name(), "\n\n======= Coverage Summary===========", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Overall: %.1f%%", ram_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" wr: %.1f%%", ram_cg.cp_wr.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" addr: %.1f%%", ram_cg.cp_addr.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" wdata: %.1f%%", ram_cg.cp_wdata.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" rdata: %.1f%%", ram_cg.cp_rdata.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "======= Coverage Summary===========\n\n", UVM_LOW);
    endfunction



endclass //ram_coverage

`endif 