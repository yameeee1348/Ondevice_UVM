`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_item.sv"

// Sequencer를 별도로 클래스로 선언하지 않고 typedef로 간단하게 정의하셨네요! 
// 똑같은 스타일로 적용합니다.
typedef uvm_sequencer#(spi_item) spi_sequencer;

class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent)

    // 에이전트의 3대 구성 요소
    spi_driver    drv;
    spi_monitor   mon;
    spi_sequencer sqr;

    function new(string name = "spi_agent", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    //  Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        
        drv = spi_driver::type_id::create("drv", this);
        mon = spi_monitor::type_id::create("mon", this);
        sqr = spi_sequencer::type_id::create("sqr", this);
    endfunction // build_phase

    // Connect Phase:
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction // connect_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
    endfunction

endclass // spi_agent

`endif