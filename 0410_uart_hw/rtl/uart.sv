module top_uart (
    input  logic       clk,
    input  logic       rst,
    input  logic       uart_rx,
    output logic       uart_tx
    // output logic [7:0] rx_data,
);

    logic w_b_tick, w_rx_done;
    logic [7:0] w_rx_data;

    logic [7:0] w_rx_fifo_pop_data;
    logic [7:0] w_tx_fifo_pop_data;

    logic w_tx_fifo_full, w_rx_fifo_empty, w_tx_fifo_empty;
    logic w_tx_busy;

    // btn_debounce U_BD_TX_START (
    //     .clk  (clk),
    //     .reset(rst),
    //     .i_btn(btn_down),
    //     .o_btn(w_tx_start)
    // );

    fifo U_FIFO_TX(
        .clk(clk),
        .rst(rst),
        .push(~w_rx_fifo_empty),
        .pop(~w_tx_busy),
        .push_data(w_rx_fifo_pop_data),
        .pop_data(w_tx_fifo_pop_data),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );

    fifo U_FIFO_RX(
        .clk(clk),
        .rst(rst),
        .push(w_rx_done),
        .pop(~w_tx_fifo_full),
        .push_data(w_rx_data),
        .pop_data(w_rx_fifo_pop_data),
        .full(),
        .empty(w_rx_fifo_empty)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(uart_rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tx_start(~w_tx_fifo_empty),
        .b_tick(w_b_tick),
        .tx_data(w_tx_fifo_pop_data),
        .tx_busy(w_tx_busy),
        .tx_done(),
        .uart_tx(uart_tx)
    );

    baud_tick U_BAUD_TICK (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );
endmodule