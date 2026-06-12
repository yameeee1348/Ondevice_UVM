`ifndef UART_COVERAGE_SV
`define UART_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

// uvm_subscriber를 상속받으면 내부에 자동으로 analysis_export가 생성됩니다.
class uart_coverage extends uvm_subscriber #(uart_seq_item);
    `uvm_component_utils(uart_coverage)
    
    uart_seq_item item;

    // UART 데이터 커버리지 그룹
    covergroup uart_cg;
        cp_data : coverpoint item.data {
            // 극단적인 값 (모두 0이거나 모두 1)
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            
            // 타이밍 스트레스 테스트 패턴 (01010101, 10101010)
            bins toggle_55 = {8'h55};
            bins toggle_aa = {8'hAA};
            
            // 데이터 대역별 분할
            bins data_low  = {[8'h01 : 8'h3F]};
            bins data_mid  = {[8'h40 : 8'hBF]};
            bins data_high = {[8'hC0 : 8'hFE]};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        uart_cg = new();
    endfunction //new()

    // Monitor에서 포트를 통해 데이터가 넘어오면 자동으로 실행되는 함수
    virtual function void write(uart_seq_item t);
        item = t;
        uart_cg.sample(); 
    endfunction

    // 시뮬레이션 종료 후 결과 출력
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "======= UART Coverage Summary =======", UVM_NONE);
        `uvm_info(get_type_name(), $sformatf(" Overall Data Coverage: %.1f%%", uart_cg.get_coverage()), UVM_NONE);
        `uvm_info(get_type_name(), "=====================================\n", UVM_NONE);
    endfunction

endclass

`endif