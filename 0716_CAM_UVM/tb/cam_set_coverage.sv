`ifndef CAM_SET_COVERAGE_SV
`define CAM_SET_COVERAGE_SV

class cam_set_coverage extends uvm_subscriber #(cam_set_item);
    `uvm_component_utils(cam_set_coverage)

    cam_set_kind_e sampled_kind;
    bit [15:0] sampled_pixel;
    bit [16:0] sampled_addr;
    bit [9:0]  sampled_x;
    bit [9:0]  sampled_y;
    bit        sampled_de;
    bit [7:0]  sampled_sccb_id;
    bit [7:0]  sampled_sccb_reg;

    covergroup cam_set_cg;
        option.per_instance = 1;

        cp_kind : coverpoint sampled_kind {
            bins frame_sync    = {OBS_FRAME_SYNC};
            bins input_pixel   = {OBS_EXPECT_PIXEL};
            bins camera_write  = {OBS_CAM_WRITE};
            bins fb_read       = {OBS_FB_READ};
            bins sccb_write    = {OBS_SCCB_WRITE};
        }

        cp_pixel_pattern : coverpoint sampled_pixel
            iff (sampled_kind == OBS_EXPECT_PIXEL) {
            bins black    = {16'h0000};
            bins white    = {16'hFFFF};
            bins red      = {16'hF800};
            bins green    = {16'h07E0};
            bins blue     = {16'h001F};
            bins toggling = {16'hAA55, 16'h55AA};
            bins others   = default;
        }

        cp_write_address : coverpoint sampled_addr
            iff (sampled_kind == OBS_CAM_WRITE) {
            bins first        = {17'd0};
            bins first_line   = {[17'd1:17'd319]};
            bins body         = {[17'd320:17'd76479]};
            bins final_line   = {[17'd76480:17'd76798]};
            bins last         = {17'd76799};
        }

        cp_read_de : coverpoint sampled_de
            iff (sampled_kind == OBS_FB_READ) {
            bins blank  = {1'b0};
            bins active = {1'b1};
        }

        cp_read_x_parity : coverpoint sampled_x[0]
            iff ((sampled_kind == OBS_FB_READ) && sampled_de) {
            bins even = {1'b0};
            bins odd  = {1'b1};
        }

        cp_read_y_parity : coverpoint sampled_y[0]
            iff ((sampled_kind == OBS_FB_READ) && sampled_de) {
            bins even = {1'b0};
            bins odd  = {1'b1};
        }

        cx_upscale_quadrant : cross cp_read_x_parity, cp_read_y_parity;

        cp_sccb_id : coverpoint sampled_sccb_id
            iff (sampled_kind == OBS_SCCB_WRITE) {
            bins ov7670_write = {8'h42};
            illegal_bins unexpected = default;
        }

        cp_sccb_register : coverpoint sampled_sccb_reg
            iff (sampled_kind == OBS_SCCB_WRITE) {
            bins reset_reg  = {8'h12};
            bins format_reg = {8'h40};
            bins scale_regs[] = {8'h70, 8'h71, 8'h72, 8'h73, 8'hA2};
            bins window_regs[] = {8'h17, 8'h18, 8'h19, 8'h1A, 8'h32, 8'h03};
            bins others = default;
        }
    endgroup

    function new(string name = "cam_set_coverage", uvm_component parent = null);
        super.new(name, parent);
        cam_set_cg = new();
    endfunction

    virtual function void write(cam_set_item t);
        sampled_kind     = t.kind;
        sampled_pixel    = t.pixel;
        sampled_addr     = t.cam_addr;
        sampled_x        = t.x_pixel;
        sampled_y        = t.y_pixel;
        sampled_de       = t.de;
        sampled_sccb_id  = t.sccb_id;
        sampled_sccb_reg = t.sccb_reg;
        cam_set_cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf(
            "CAM_Set functional coverage: %.2f%%", cam_set_cg.get_coverage()
        ), UVM_NONE)
    endfunction
endclass

`endif
