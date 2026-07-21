`ifndef CAM_SET_ITEM_SV
`define CAM_SET_ITEM_SV

typedef enum int unsigned {
    DRV_CAM_LINE,
    DRV_CAM_VSYNC,
    DRV_FB_READ,
    DRV_IDLE,
    OBS_FRAME_SYNC,
    OBS_EXPECT_PIXEL,
    OBS_CAM_WRITE,
    OBS_FB_READ,
    OBS_SCCB_WRITE
} cam_set_kind_e;

class cam_set_item extends uvm_sequence_item;
    rand cam_set_kind_e kind;

    // Driver-side data
    rand bit [15:0] pixels[];
    rand int unsigned cycles;
    rand bit [9:0] x_pixel;
    rand bit [9:0] y_pixel;
    rand bit       de;

    // Monitor-side data
    bit [16:0] cam_addr;
    bit [15:0] pixel;
    bit [11:0] rgb;
    bit [7:0]  sccb_id;
    bit [7:0]  sccb_reg;
    bit [7:0]  sccb_data;
    time       timestamp;

    constraint c_line_size {
        if (kind == DRV_CAM_LINE)
            pixels.size() inside {[1:320]};
    }

    constraint c_cycles {
        cycles inside {[1:1000]};
    }

    constraint c_read_range {
        x_pixel inside {[0:639]};
        y_pixel inside {[0:479]};
    }

    `uvm_object_utils_begin(cam_set_item)
        `uvm_field_enum(cam_set_kind_e, kind, UVM_ALL_ON)
        `uvm_field_array_int(pixels, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
        `uvm_field_int(x_pixel, UVM_ALL_ON)
        `uvm_field_int(y_pixel, UVM_ALL_ON)
        `uvm_field_int(de, UVM_ALL_ON)
        `uvm_field_int(cam_addr, UVM_ALL_ON)
        `uvm_field_int(pixel, UVM_ALL_ON)
        `uvm_field_int(rgb, UVM_ALL_ON)
        `uvm_field_int(sccb_id, UVM_ALL_ON)
        `uvm_field_int(sccb_reg, UVM_ALL_ON)
        `uvm_field_int(sccb_data, UVM_ALL_ON)
        `uvm_field_int(timestamp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "cam_set_item");
        super.new(name);
        kind   = DRV_IDLE;
        cycles = 1;
    endfunction

    function string convert2string();
        return $sformatf(
            "kind=%s addr=%0d pixel=0x%04h read=(%0d,%0d,de=%0b) rgb=0x%03h SCCB=%02h:%02h=%02h",
            kind.name(), cam_addr, pixel, x_pixel, y_pixel, de, rgb,
            sccb_id, sccb_reg, sccb_data
        );
    endfunction
endclass

`endif

