`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import cam_set_pkg::*;

module tb_top;
    localparam int IMG_W  = 320;
    localparam int IMG_H  = 240;
    localparam int ADDR_W = $clog2(IMG_W * IMG_H);

    logic clk;
    logic pclk;
    logic cam_fb_rclk;

    initial begin
        clk = 1'b0;
        forever #5ns clk = ~clk;
    end

    initial begin
        pclk = 1'b0;
        forever #20ns pclk = ~pclk;
    end

    initial begin
        cam_fb_rclk = 1'b0;
        #7ns;
        forever #20ns cam_fb_rclk = ~cam_fb_rclk;
    end

    cam_set_interface #(
        .IMG_W (IMG_W),
        .IMG_H (IMG_H),
        .ADDR_W(ADDR_W)
    ) vif (
        .clk         (clk),
        .pclk        (pclk),
        .cam_fb_rclk (cam_fb_rclk)
    );

    CAM_Set #(
        .IMG_W (IMG_W),
        .IMG_H (IMG_H),
        .ADDR_W(ADDR_W)
    ) dut (
        .clk  (clk),
        .reset(vif.reset),

        .pclk (pclk),
        .href (vif.href),
        .vsync(vif.vsync),
        .pdata(vif.pdata),
        .xclk (vif.xclk),

        .scl(vif.scl),
        .sda(vif.sda),

        .clk_100M(vif.clk_100M),
        .clk_25M (vif.clk_25M),

        .cam_fb_rclk(cam_fb_rclk),
        .x_pixel    (vif.x_pixel),
        .y_pixel    (vif.y_pixel),
        .de         (vif.de),
        .cam_rgb    (vif.cam_rgb),

        .cam_pclk (vif.cam_pclk),
        .cam_href (vif.cam_href),
        .cam_vsync(vif.cam_vsync),
        .cam_we   (vif.cam_we),
        .cam_wAddr(vif.cam_wAddr),
        .cam_wData(vif.cam_wData)
    );

    initial begin
        vif.reset   = 1'b1;
        vif.href    = 1'b0;
        vif.vsync   = 1'b0;
        vif.pdata   = 8'h00;
        vif.x_pixel = 10'd0;
        vif.y_pixel = 10'd0;
        vif.de      = 1'b0;

        repeat (20) @(posedge clk);
        @(negedge clk);
        vif.reset = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual cam_set_interface)::set(
            null, "uvm_test_top.env.agent.*", "vif", vif
        );
        run_test();
    end

`ifdef FSDB
    initial begin
        $fsdbDumpfile("cam_set_test.fsdb");
        $fsdbDumpvars(0, tb_top);
        $fsdbDumpMDA();
    end
`endif
endmodule

