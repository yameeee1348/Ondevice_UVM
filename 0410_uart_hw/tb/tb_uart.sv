
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_interface.sv"
`include "uart_seq_item.sv"
`include "uart_sequence.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_agent.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_env.sv"
`include "uart_test.sv"


module tb_uart ();
    logic pclk;
    logic presetn;

    initial pclk = 0;
    always #5 pclk = ~pclk;

    uart_if u_if(pclk, presetn);


    top_uart dut(
        .clk(pclk),
        .rst(presetn),
        .uart_rx(u_if.uart_rx),
        .uart_tx(u_if.uart_tx)
    );


    initial begin
        presetn = 1'b1;
        repeat(5) @(posedge pclk);
        presetn = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual uart_if)::set(null, "*", "u_if", u_if);

        run_test();
    end

    initial begin
         $fsdbDumpfile("novas.fsdb");
         $fsdbDumpvars(0, tb_uart, "+all");
    end
endmodule