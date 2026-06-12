`ifndef SPI_SEQUENCE_SV
`define SPI_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_item.sv"

// ==========================================
// 1. SPI Base Sequence
// ==========================================
class spi_base_seq extends uvm_sequence#(spi_item);
    `uvm_object_utils(spi_base_seq)

    function new(string name = "spi_base_seq");
        super.new(name);
    endfunction

    
    task do_transfer(bit [7:0] m_data, bit [7:0] s_data, bit [7:0] div = 8'd49, bit pol = 0, bit pha = 0);
        spi_item item = spi_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with { 
            master_data == m_data; 
            slave_data  == s_data;
            clk_div_val == div;
            cpol_val    == pol;
            cpha_val    == pha;
        }) `uvm_fatal(get_type_name(), "Randomize FAIL!")
        finish_item(item);
    endtask

    virtual task body();
       
    endtask
endclass


// ==========================================
// 2. Scenario 1: Sanity & Random Data
// 목적: 기본적인 송수신 기능이 랜덤한 데이터에서 깨지지 않는지 확인
// ==========================================
class spi_sanity_seq extends spi_base_seq;
    `uvm_object_utils(spi_sanity_seq)
    int num_loop = 20;

    function new(string name = "spi_sanity_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario: Sanity Random Test Start", UVM_LOW)
        repeat(num_loop) begin
            spi_item item = spi_item::type_id::create("item");
            start_item(item);
            
            if (!item.randomize()) `uvm_fatal(get_type_name(), "Randomize FAIL!")
            finish_item(item);
        end
    endtask
endclass


// ==========================================
// 3. Scenario 2: Full Mode Sweep (CPOL/CPHA)
// 목적: SPI의 4가지 모드 조합에서 데이터 샘플링 타이밍이 정확한지 검증
// ==========================================
class spi_mode_sweep_seq extends spi_base_seq;
    `uvm_object_utils(spi_mode_sweep_seq)

    function new(string name = "spi_mode_sweep_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario: All Mode Sweep Test Start", UVM_LOW)
        for (int p = 0; p < 2; p++) begin     // CPOL 0, 1
            for (int h = 0; h < 2; h++) begin // CPHA 0, 1
                `uvm_info(get_type_name(), $sformatf("Testing Mode CPOL=%0d, CPHA=%0d", p, h), UVM_MEDIUM)
                repeat(5) begin
                    do_transfer($urandom, $urandom, 8'd20, p, h);
                end
            end
        end
    endtask
endclass


// ==========================================
// 4. Scenario 3: Timing Stress 
// 목적: clk_div가 매우 작을 때 FSM이 정상적으로 동작하는지 확인
// ==========================================
class spi_speed_stress_seq extends spi_base_seq;
    `uvm_object_utils(spi_speed_stress_seq)

    function new(string name = "spi_speed_stress_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario: High Speed Stress Test Start", UVM_LOW)
       
        for (int d = 0; d <= 4; d++) begin
            do_transfer($urandom, $urandom, d, 0, 0);
            do_transfer($urandom, $urandom, d, 1, 1);
        end
    endtask
endclass


// ==========================================
// 5. Scenario 4: Back-to-Back 
// 목적: 전송 완료 직후 바로 다음 전송을 할 때 IDLE 상태가 유실되지 않는지 확인
// ==========================================
class spi_back_to_back_seq extends spi_base_seq;
    `uvm_object_utils(spi_back_to_back_seq)

    function new(string name = "spi_back_to_back_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario: Back-to-Back Stress Test Start", UVM_LOW)
        
        repeat(50) begin
            spi_item item = spi_item::type_id::create("item");
            start_item(item);
            
            if (!item.randomize() with { clk_div_val == 8'd10; }) 
                `uvm_fatal(get_type_name(), "Randomize FAIL!")
            finish_item(item);
        end
    endtask
endclass

`endif