`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

interface uart_if(
    input  logic       pclk,
    input  logic       presetn
);
    
    logic       uart_rx;
    logic       uart_tx;


    clocking drv_cb @(posedge pclk);
        default input #1ns output #1ns;
        
        output uart_tx;


    endclocking

    clocking mon_cb @(posedge pclk);
    default input #1ns output #1ns;
        input uart_rx;
        input uart_tx;
    endclocking

    
endinterface //uart_uf

`endif 