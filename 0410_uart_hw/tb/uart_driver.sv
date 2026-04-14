`ifndef DRIVER_SV
`define DRIVER_SV

`timescale  1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_driver)
    virtual uart_if u_if;

    realtime bit_period = 104166.667ns;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "","u_if", u_if)) begin
            `uvm_fatal(get_type_name(), "driver에서 uvm_config_db 에러 발생.")
        end
    endfunction

   

    virtual task run_phase(uvm_phase phase);
        uart_bus_init();
        //wait(u_if.presetn == 0);
        `uvm_info(get_type_name(), "리셋 해제 확인 트렌젝션 대기중...",UVM_MEDIUM)

        forever begin
            uart_seq_item item;
            seq_item_port.get_next_item(item);
            driver_uart(item);
            seq_item_port.item_done();
        end
        
    endtask

    task  uart_bus_init();
        u_if.uart_rx <= 1;
    endtask //

    task  driver_uart(uart_seq_item item);
    //START
    u_if.uart_rx <= 1'b0;
    #(bit_period);


    //DATA
    for (int i = 0; i < 8;  i++) begin
        u_if.uart_rx <= item.data[i];
        #(bit_period);
    end



    ///STOP
    u_if.uart_rx <= 1'b1;
    #(bit_period);
    #(bit_period);

    `uvm_info(get_type_name(), $sformatf("Driver sent Data: 8'h%0h", item.data),UVM_LOW)


    endtask //

 


endclass //











`endif 