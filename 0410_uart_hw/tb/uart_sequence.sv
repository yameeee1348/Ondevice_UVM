`ifndef SEQUENCE_SV
`define SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_base_seq extends uvm_sequence#(uart_seq_item);
    `uvm_object_utils(uart_base_seq)

    int num_loop = 10;

    function new(string name = "uart_base_seq");
        super.new(name);
    endfunction //new()

    task  send_data(bit [7:0] d);
        uart_seq_item item = uart_seq_item::type_id::create("item");

        start_item(item);
        if (!item.randomize() with {data == d;}) begin
            `uvm_fatal(get_type_name(), "send_data() Randomize fail!")

        end
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("send_data() 전송 완료: data = 8'h%0h ", d), UVM_HIGH)

    endtask //

    virtual task  body();
        
    endtask //


endclass //

class uart_rand_seq extends uart_base_seq;
    `uvm_object_utils(uart_rand_seq)

    function new(string name= "uart_rand_seq");
        super.new(name);

    endfunction //new()

    virtual task  body();
        `uvm_info(get_type_name(), $sformatf("Starting Random Sequence (%0d times)...",num_loop), UVM_LOW)

        repeat(num_loop) begin
            uart_seq_item item = uart_seq_item::type_id::create("item");

            start_item(item);
            if (!item.randomize()) begin
                `uvm_fatal(get_type_name(), "Randomize() FAIL!!")

            end
            finish_item(item);
        end
    endtask //
endclass //uart_rand_seq 



// ---------------------------------------------------------
// 3. Pattern Sequence (Coverage 100% 달성을 위한 코너케이스)
// ---------------------------------------------------------
class uart_pattern_seq extends uart_base_seq;
    `uvm_object_utils(uart_pattern_seq)

    function new(string name="uart_pattern_seq");
        super.new(name);
    endfunction //new()

    virtual task body();
        `uvm_info(get_type_name(), "Starting Pattern Sequence (Coverage Targeted)...", UVM_LOW)
        
        // Coverage에서 정의했던 극단적/스트레스 패턴들을 확실하게 한 번씩 쏴줍니다.
        send_data(8'h00); // All Zeros
        send_data(8'hFF); // All Ones
        send_data(8'h55); // Toggle Pattern 1 (01010101)
        send_data(8'hAA); // Toggle Pattern 2 (10101010)
        
    endtask

endclass









`endif 