`timescale 1ns/1ps

interface cam_set_interface #(
    parameter int IMG_W  = 320,
    parameter int IMG_H  = 240,
    parameter int ADDR_W = $clog2(IMG_W * IMG_H)
) (
    input logic clk,
    input logic pclk,
    input logic cam_fb_rclk
);
    logic reset;

    // OV7670 pixel input
    logic       href;
    logic       vsync;
    logic [7:0] pdata;

    // SCCB and generated clocks
    logic xclk;
    logic scl;
    tri1  sda;
    logic clk_100M;
    logic clk_25M;

    // Framebuffer read request and RGB output
    logic [9:0]  x_pixel;
    logic [9:0]  y_pixel;
    logic        de;
    logic [11:0] cam_rgb;

    // Raw camera output stream
    logic              cam_pclk;
    logic              cam_href;
    logic              cam_vsync;
    logic              cam_we;
    logic [ADDR_W-1:0] cam_wAddr;
    logic [15:0]       cam_wData;

    clocking cam_drv_cb @(negedge pclk);
        default input #1step output #0;
        input  reset;
        output href, vsync, pdata;
    endclocking

    clocking cam_mon_cb @(posedge pclk);
        default input #1step output #0;
        input reset;
        input href, vsync, pdata;
        input cam_pclk, cam_href, cam_vsync;
        input cam_we, cam_wAddr, cam_wData;
    endclocking

    clocking read_drv_cb @(negedge cam_fb_rclk);
        default input #1step output #0;
        input  reset;
        output x_pixel, y_pixel, de;
    endclocking

    clocking read_mon_cb @(posedge cam_fb_rclk);
        // framebuffer.rData is updated with a nonblocking assignment on this
        // same edge.  A #0 input skew samples after the NBA update; #1step
        // would pair the previous read data with the current VGA coordinate.
        default input #0 output #0;
        input reset;
        input x_pixel, y_pixel, de, cam_rgb;
    endclocking
endinterface
