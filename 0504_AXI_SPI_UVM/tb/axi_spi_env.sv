`ifndef AXI_SPI_ENV_SV
`define AXI_SPI_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_spi_agent.sv" 
`include "axi_spi_scoreboard.sv"
`include "axi_spi_coverage.sv"

class axi_spi_env extends uvm_env;
    `uvm_component_utils(axi_spi_env)

    axi_spi_agent      agt;
    axi_spi_scoreboard scb;
    axi_spi_coverage   cov;

    function new(string name = "axi_spi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = axi_spi_agent::type_id::create("agt", this);
        scb = axi_spi_scoreboard::type_id::create("scb", this);
        cov = axi_spi_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
        
        `uvm_info(get_type_name(), "AXI-SPI Env: Monitor -> Scoreboard/Coverage 연결 완료", UVM_MEDIUM)
    endfunction
endclass

`endif