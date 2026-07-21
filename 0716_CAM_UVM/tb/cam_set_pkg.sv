`ifndef CAM_SET_PKG_SV
`define CAM_SET_PKG_SV

`timescale 1ns/1ps

package cam_set_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "cam_set_item.sv"
    `include "cam_set_sequence.sv"
    `include "cam_set_driver.sv"
    `include "cam_set_monitor.sv"
    `include "cam_set_agent.sv"
    `include "cam_set_scoreboard.sv"
    `include "cam_set_coverage.sv"
    `include "cam_set_env.sv"
    `include "cam_set_test.sv"
endpackage

`endif

