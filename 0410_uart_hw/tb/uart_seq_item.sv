`ifndef UART_SEQ_ITEM_SV
`define UART_SEQ_ITEM_SV


`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_seq_item extends uvm_sequence_item;
    rand logic [7:0] data;
    

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction //new()

    virtual function string convert2string();
        return $sformatf("UART_DATA = 8'h0h", data);
    endfunction
    
endclass //



`endif 