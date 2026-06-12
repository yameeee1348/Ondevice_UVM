`timescale 1ns / 1ps

module SPI_Core_Top (
    input  logic       clk,
    input  logic       reset,

    // Master Control Interface
    input  logic       m_cpol,
    input  logic       m_cpha,
    input  logic [7:0] m_clk_div,
    input  logic       m_start,
    input  logic [7:0] m_tx_data,
    output logic [7:0] m_rx_data,
    output logic       m_done,
    output logic       m_busy,

    // Slave Control Interface
    input  logic [7:0] s_tx_data,
    output logic [7:0] s_rx_data,
    output logic       s_done
);

    // Internal SPI Bus
    logic sclk, mosi, miso, cs_n;

    // Master Instance
    SPI_master u_master (
        .clk(clk), .reset(reset),
        .cpol(m_cpol), .cpha(m_cpha), .clk_div(m_clk_div),
        .tx_data(m_tx_data), .start(m_start), .miso(miso),
        .rx_data(m_rx_data), .done(m_done), .busy(m_busy),
        .sclk(sclk), .mosi(mosi), .cs_n(cs_n)
    );

    // Slave Instance
    SPI_slave u_slave (
        .clk(clk), .reset(reset),
        .cpol(m_cpol), .cpha(m_cpha), // Master와 동일 모드 가정
        .tx_data(s_tx_data),
        .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .miso(miso),
        .rx_data(s_rx_data), .done(s_done)
    );

endmodule