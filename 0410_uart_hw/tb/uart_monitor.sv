`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    virtual uart_if u_if;

    uvm_analysis_port #(uart_seq_item) mon_ap_rx;
    uvm_analysis_port #(uart_seq_item) mon_ap_tx;

    realtime bit_period = 104166.667ns;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap_rx = new("mon_ap_rx", this);
        mon_ap_tx = new("mon_ap_tx", this);
    endfunction 


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "u_if", u_if)) begin
            `uvm_fatal(get_type_name(), "monitor에서 uvm_config_db 에러 발생.")
        end
    endfunction



    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "moniotr 동작 시작...", UVM_MEDIUM)
        
        fork
            monitor_rx_pin();
            monitor_tx_pin();
        join
    endtask

    task  monitor_rx_pin();
        uart_seq_item item;
        forever begin
            @(negedge u_if.uart_rx);

            #(bit_period / 2);
            if (u_if.uart_rx === 1'b0) begin
                item = uart_seq_item::type_id::create("item_rx");

                for (int i = 0; i< 8; i++) begin
                    #(bit_period);
                    item.data[i] = u_if.uart_rx;
                end

                #(bit_period);

                mon_ap_rx.write(item);
                `uvm_info(get_type_name(), $sformatf("[MON_RX] Captured input data : 8'h%0h", item.data), UVM_HIGH)
            end
        end
        
    endtask //


    task  monitor_tx_pin();
        uart_seq_item item;
        forever begin
            @(negedge u_if.uart_tx);

            #(bit_period / 2);
            if (u_if.uart_tx === 1'b0) begin
                item = uart_seq_item::type_id::create("item_tx");

                for (int i = 0; i < 8; i++) begin
                    #(bit_period);
                    item.data[i] = u_if.uart_tx;
                end

                #(bit_period);

                mon_ap_tx.write(item);
                `uvm_info(get_type_name(), $sformatf("[MON_TX] Captured ourtput data : 8'h%0h", item.data), UVM_LOW)
            end
        end
    endtask //

    virtual function void report_phase(uvm_phase phase);
        
        
    endfunction


endclass //











`endif 