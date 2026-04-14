`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_tx)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_rx #(uart_seq_item, uart_scoreboard) rx_imp;

    uvm_analysis_imp_tx #(uart_seq_item, uart_scoreboard) tx_imp;

    uart_seq_item expected_q[$];

    int match_cnt = 0;
    int error_cnt = 0;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        rx_imp = new("rx_imp", this);
        tx_imp = new("tx_imp", this);
    
    endfunction //new()
// 1. RX 데이터 수신 (Driver가 쏜 데이터 -> Expected)
    virtual function void write_rx(uart_seq_item item);
        uart_seq_item cloned_item;
        $cast(cloned_item, item.clone());

        expected_q.push_back(cloned_item);
        `uvm_info(get_type_name(), $sformatf("[SB_store] stored expected data: 8'h%0h", cloned_item.data), UVM_HIGH)
        
    endfunction
// 2. TX 데이터 수신 및 비교 (DUT가 뱉은 데이터 -> Actual)
    virtual function void write_tx(uart_seq_item item);
        uart_seq_item exp_item;
        
        if (expected_q.size() == 0) begin
            `uvm_error(get_type_name(), $sformatf("DUT sent unexpected data!! (8'h%0h) but Expected Q is empty",item.data))
            error_cnt++;
        end else begin
            exp_item = expected_q.pop_front();    
        

            if (item.data === exp_item.data)begin

                `uvm_info(get_type_name(), $sformatf("[SB_PASS] MATCH!!!  Expected: 8'h%0h, Actual: 8'h%0h", exp_item.data, item.data), UVM_LOW)
                match_cnt++;
            end else begin
                `uvm_error(get_type_name(), $sformatf("[SB_FAIL] MISMATCH!!!  Expected: 8'h%0h, Actual: 8'h%0h", exp_item.data, item.data))
                error_cnt++;
            end
    end
        
    endfunction

    // 3. 시뮬레이션 종료 시 잔여 데이터 확인 (Check Phase)
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if (expected_q.size() > 0) begin
            `uvm_error(get_type_name(), $sformatf("Simulation ended but %0d expected items were never received from DUT!!", expected_q.size()))
            error_cnt++;
        end
        
    endfunction
    

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "----------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("SCOREBOARD RESULTS: MATCH = %0d, ERROR = %0d",match_cnt, error_cnt), UVM_NONE)
        `uvm_info(get_type_name(), "----------------------------------------", UVM_NONE)
    endfunction


endclass //











`endif 