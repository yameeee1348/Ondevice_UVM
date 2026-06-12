`ifndef SPI_COVERAGE_SV
`define SPI_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_item.sv"

class spi_coverage extends uvm_subscriber #(spi_item);
    `uvm_component_utils(spi_coverage)
    
    spi_item tx;

    
    //  SPI Covergroup 
    
    covergroup spi_cg;
        // 1. CPOL
        cp_cpol : coverpoint tx.cpol_val {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // 2. CPHA
        cp_cpha : coverpoint tx.cpha_val {
            bins first_edge  = {1'b0};
            bins second_edge = {1'b1};
        }

        // 3. SPI Mode Cross Coverage 
        cx_mode : cross cp_cpol, cp_cpha;

        //// 4. Clock Divider 커버리지 
        //cp_div : coverpoint tx.clk_div_val {
        //    bins fast   = {[0 : 5]};
        //    bins mid    = {[6 : 50]};
        //    bins slow   = {[51 : 255]};
        //}

        // 5. Master 송신 데이터 패턴
        cp_master_data : coverpoint tx.master_data {
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            bins toggling  = {8'hAA, 8'h55};
            bins others    = default;
        }

        // 6. Slave 송신 데이터 패턴
        cp_slave_data : coverpoint tx.slave_data {
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            bins others    = default;
        }

        // 7. Master와 Slave 데이터 일치 
        cp_data_match : coverpoint (tx.master_data == tx.slave_data) {
            bins matched    = {1'b1};
            bins mismatched = {1'b0};
        }
    endgroup

    function new(string name = "spi_coverage", uvm_component parent);
        super.new(name, parent);
        spi_cg = new();
    endfunction // new()

    // Monitor에서 호출되는 write 함수
    function void write(spi_item t);
        tx = t;
        spi_cg.sample();
    endfunction // write

    // 최종 리포트 단계에서 커버리지 요약 출력
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "======= SPI Coverage Summary ===========", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Total Coverage : %.2f%%", spi_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Mode (CPOL/CPHA) Cross : %.2f%%", spi_cg.cx_mode.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(" Data Match (Master==Slave) : %.2f%%", spi_cg.cp_data_match.get_coverage()), UVM_LOW);
       /// `uvm_info(get_type_name(), $sformatf(" Clock Divider : %.2f%%", spi_cg.cp_div.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "========================================\n", UVM_LOW);
    endfunction

endclass // spi_coverage

`endif