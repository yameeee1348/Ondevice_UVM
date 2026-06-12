`ifndef SPI_MONITOR_SV
`define SPI_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_item.sv"

class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)

    // Scoreboard나 Coverage로 데이터를 보내기 위한 Analysis Port
    uvm_analysis_port #(spi_item) ap;
    virtual spi_if vif;

    function new(string name = "spi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Monitor에서 uvm_config_db 에러 발생.");
        end
    endfunction // build_phase

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SPI 버스 모니터링 시작 ...", UVM_MEDIUM)
        
        forever begin
            collect_transaction();
        end
    endtask // run_phase

//    task collect_transaction();
//        spi_item tx;
//
//        // 클럭 엣지마다 관찰
//        @(vif.mon_cb);
//
//    
//        if (vif.mon_cb.m_done === 1'b1) begin
//            tx = spi_item::type_id::create("mon_tx");
//
//            // 설정값 수집
//            tx.cpol_val     = vif.mon_cb.m_cpol;
//            tx.cpha_val     = vif.mon_cb.m_cpha;
//            tx.clk_div_val  = vif.mon_cb.m_clk_div;
//
//            // 전송 데이터 수집 (송신했던 값들)
//            tx.master_data  = vif.mon_cb.m_tx_data;
//            tx.slave_data   = vif.mon_cb.s_tx_data;
//
//            // 결과 데이터 수집 (수신 완료된 값들)
//            tx.master_rx_val = vif.mon_cb.m_rx_data;
//            tx.slave_rx_val  = vif.mon_cb.s_rx_data;
//
//            `uvm_info(get_type_name(), $sformatf("수집된 SPI 트랜잭션: M_TX:%h, S_TX:%h -> M_RX:%h, S_RX:%h", 
//                      tx.master_data, tx.slave_data, tx.master_rx_val, tx.slave_rx_val), UVM_MEDIUM)
//            
//            // Scoreboard로 전송
//            ap.write(tx);    
//        end
//    endtask // collect_transaction

task collect_transaction();
        axi_spi_item tx;

        // 1. 통신 완료 신호(s_done) 대기
      
        wait(vif.mon_cb.s_done === 1'b1);
        
        // 2.  하드웨어 레지스터 업데이트 대기
        
        wait(tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.done_latch === 1'b1);
        
        
        @(vif.mon_cb); 

        tx = axi_spi_item::type_id::create("mon_tx");

        // 3. 데이터 샘플링 
        tx.slave_data   = vif.mon_cb.s_tx_data;
        tx.slave_rx_val = vif.mon_cb.s_rx_data; 

        tx.master_data   = tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg0[7:0];
        tx.master_rx_val = tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg3[7:0]; 

        // 모드 설정값
        tx.cpol_val    = tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg1[1];
        tx.cpha_val    = tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg1[2];
        tx.clk_div_val = tb_top.dut.axi_spi_m_v1_0_S00_AXI_inst.slv_reg1[15:8];

        `uvm_info(get_type_name(), $sformatf("수집 완료: M_TX:%h, S_TX:%h -> M_RX:%h, S_RX:%h", 
                  tx.master_data, tx.slave_data, tx.master_rx_val, tx.slave_rx_val), UVM_MEDIUM)

        ap.write(tx);    
        
        // 4. 다음 전송을 위해 cs_n이 다시 올라갈 때까지 대기
        wait(vif.mon_cb.cs_n === 1'b1);
    endtask
endclass

`endif