`ifndef SPI_ENV_SV
`define SPI_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// Agent, Scoreboard, Coverage 파일들을 포함합니다.
// 파일 트리에 agent가 없다면 별도로 작성하거나 
// env에서 driver/monitor를 직접 관리하도록 수정해야 할 수 있습니다.
`include "spi_agent.sv" 
`include "spi_scoreboard.sv"
`include "spi_coverage.sv"

class spi_env extends uvm_env;
    `uvm_component_utils(spi_env)

    // 컴포넌트 선언
    spi_agent      agt;
    spi_scoreboard scb;
    spi_coverage   cov;

    function new(string name = "spi_env", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // 💡 Build Phase: 컴포넌트 생성
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = spi_agent::type_id::create("agt", this);
        scb = spi_scoreboard::type_id::create("scb", this);
        cov = spi_coverage::type_id::create("cov", this);
    endfunction // build_phase

    // Connect Phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
        
        `uvm_info(get_type_name(), "SPI Env: Monitor와 Scoreboard/Coverage 연결 완료", UVM_MEDIUM)
    endfunction // connect_phase

endclass // spi_env

`endif