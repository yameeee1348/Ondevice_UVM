`ifndef CAM_SET_SCOREBOARD_SV
`define CAM_SET_SCOREBOARD_SV

class cam_set_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(cam_set_scoreboard)

    localparam int IMG_W      = 320;
    localparam int IMG_H      = 240;
    localparam int IMG_PIXELS = IMG_W * IMG_H;

    uvm_analysis_imp #(cam_set_item, cam_set_scoreboard) analysis_imp;

    bit [15:0] expected_pixel_q[$];
    bit [15:0] reference_memory[];
    bit        reference_valid[];
    int unsigned expected_write_addr;

    bit [15:0] expected_sccb[$];
    int unsigned sccb_index;
    time last_sccb_timestamp;
    bit require_sccb_complete;
    uvm_event sccb_init_done;

    int unsigned required_camera_writes;
    int unsigned required_fb_reads;

    int unsigned camera_write_count;
    int unsigned framebuffer_read_count;
    int unsigned error_count;

    function new(string name = "cam_set_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);

        reference_memory = new[IMG_PIXELS];
        reference_valid  = new[IMG_PIXELS];
        foreach (reference_valid[i]) begin
            reference_memory[i] = 16'h0000;
            reference_valid[i]  = 1'b0;
        end

        expected_write_addr = 0;
        sccb_index = 0;
        last_sccb_timestamp = 0;
        require_sccb_complete = 1'b0;
        sccb_init_done = null;
        required_camera_writes = 0;
        required_fb_reads = 0;
        camera_write_count = 0;
        framebuffer_read_count = 0;
        error_count = 0;

        build_expected_sccb_table();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db#(bit)::get(
            this, "", "require_sccb_complete", require_sccb_complete
        ));
        if (!uvm_config_db#(uvm_event)::get(
            this, "", "sccb_init_done", sccb_init_done
        ))
            `uvm_fatal(get_type_name(), "sccb_init_done event was not configured")
        void'(uvm_config_db#(int unsigned)::get(
            this, "", "required_camera_writes", required_camera_writes
        ));
        void'(uvm_config_db#(int unsigned)::get(
            this, "", "required_fb_reads", required_fb_reads
        ));
    endfunction

    protected function void build_expected_sccb_table();
        // OV7670_Controller init_rom entries excluding the 0xFF delay commands.
        expected_sccb.push_back(16'h1280);
        expected_sccb.push_back(16'h3A04);
        expected_sccb.push_back(16'h1200);
        expected_sccb.push_back(16'h13E7);
        expected_sccb.push_back(16'h6F9F);
        expected_sccb.push_back(16'hB084);
        expected_sccb.push_back(16'h703A);
        expected_sccb.push_back(16'h7135);
        expected_sccb.push_back(16'h7211);
        expected_sccb.push_back(16'h73F0);
        expected_sccb.push_back(16'h7A20);
        expected_sccb.push_back(16'h7B10);
        expected_sccb.push_back(16'h7C1E);
        expected_sccb.push_back(16'h7D35);
        expected_sccb.push_back(16'h7E5A);
        expected_sccb.push_back(16'h7F69);
        expected_sccb.push_back(16'h8076);
        expected_sccb.push_back(16'h8180);
        expected_sccb.push_back(16'h8288);
        expected_sccb.push_back(16'h838F);
        expected_sccb.push_back(16'h8496);
        expected_sccb.push_back(16'h85A3);
        expected_sccb.push_back(16'h86AF);
        expected_sccb.push_back(16'h87C4);
        expected_sccb.push_back(16'h88D7);
        expected_sccb.push_back(16'h89E8);
        expected_sccb.push_back(16'h0000);
        expected_sccb.push_back(16'h1000);
        expected_sccb.push_back(16'h0D40);
        expected_sccb.push_back(16'h1418);
        expected_sccb.push_back(16'hA505);
        expected_sccb.push_back(16'hAB07);
        expected_sccb.push_back(16'h2495);
        expected_sccb.push_back(16'h2533);
        expected_sccb.push_back(16'h26E3);
        expected_sccb.push_back(16'h9F78);
        expected_sccb.push_back(16'hA068);
        expected_sccb.push_back(16'hA103);
        expected_sccb.push_back(16'hA6D8);
        expected_sccb.push_back(16'hA7D8);
        expected_sccb.push_back(16'hA8F0);
        expected_sccb.push_back(16'hA990);
        expected_sccb.push_back(16'hAA94);
        expected_sccb.push_back(16'h1211);
        expected_sccb.push_back(16'h0C04);
        expected_sccb.push_back(16'h3E19);
        expected_sccb.push_back(16'h703A);
        expected_sccb.push_back(16'h7135);
        expected_sccb.push_back(16'h7211);
        expected_sccb.push_back(16'h73F1);
        expected_sccb.push_back(16'hA202);
        expected_sccb.push_back(16'h1715);
        expected_sccb.push_back(16'h1803);
        expected_sccb.push_back(16'h3200);
        expected_sccb.push_back(16'h1903);
        expected_sccb.push_back(16'h1A7B);
        expected_sccb.push_back(16'h0300);
        expected_sccb.push_back(16'h1214);
        expected_sccb.push_back(16'h4010);
        expected_sccb.push_back(16'h13E7);
        expected_sccb.push_back(16'h5587);
        expected_sccb.push_back(16'h13E7);
    endfunction

    protected function bit [11:0] rgb565_to_rgb444(bit [15:0] pixel);
        return {pixel[15:12], pixel[10:7], pixel[4:1]};
    endfunction

    protected function void report_mismatch(string message);
        error_count++;
        `uvm_error(get_type_name(), message)
    endfunction

    virtual function void write(cam_set_item item);
        case (item.kind)
            OBS_FRAME_SYNC: begin
                expected_write_addr = 0;
                expected_pixel_q.delete();
                `uvm_info(get_type_name(), "Observed camera frame sync", UVM_HIGH)
            end

            OBS_EXPECT_PIXEL: begin
                expected_pixel_q.push_back(item.pixel);
            end

            OBS_CAM_WRITE: begin
                check_camera_write(item);
            end

            OBS_FB_READ: begin
                check_framebuffer_read(item);
            end

            OBS_SCCB_WRITE: begin
                check_sccb_write(item);
            end

            default: begin
                // Driver commands are not sent through the monitor analysis port.
            end
        endcase
    endfunction

    protected function void check_camera_write(cam_set_item item);
        bit [15:0] expected_pixel;
        int unsigned current_expected_addr;

        camera_write_count++;
        current_expected_addr = expected_write_addr;

        if (expected_pixel_q.size() == 0) begin
            report_mismatch($sformatf(
                "Unexpected cam_we at address %0d with data 0x%04h",
                item.cam_addr, item.pixel
            ));
            expected_pixel = item.pixel;
        end else begin
            expected_pixel = expected_pixel_q.pop_front();
            if (item.pixel !== expected_pixel)
                report_mismatch($sformatf(
                    "Pixel mismatch at address %0d: expected 0x%04h, got 0x%04h",
                    current_expected_addr, expected_pixel, item.pixel
                ));
        end

        if (item.cam_addr !== current_expected_addr[16:0])
            report_mismatch($sformatf(
                "Camera address mismatch: expected %0d, got %0d",
                current_expected_addr, item.cam_addr
            ));

        if (current_expected_addr < IMG_PIXELS) begin
            reference_memory[current_expected_addr] = expected_pixel;
            reference_valid[current_expected_addr]  = 1'b1;
        end

        if (expected_write_addr == IMG_PIXELS - 1)
            expected_write_addr = 0;
        else
            expected_write_addr++;
    endfunction

    protected function void check_framebuffer_read(cam_set_item item);
        int unsigned address;
        bit [11:0] expected_rgb;

        framebuffer_read_count++;

        if (!item.de) begin
            if (item.rgb !== 12'h000)
                report_mismatch($sformatf(
                    "cam_rgb must be zero while de=0, got 0x%03h", item.rgb
                ));
            return;
        end

        if ((item.x_pixel >= 640) || (item.y_pixel >= 480)) begin
            report_mismatch($sformatf(
                "Active read coordinate is out of range: (%0d,%0d)",
                item.x_pixel, item.y_pixel
            ));
            return;
        end

        address = IMG_W * (item.y_pixel >> 1) + (item.x_pixel >> 1);
        if (!reference_valid[address]) begin
            `uvm_warning(get_type_name(), $sformatf(
                "Skipping unreadable reference address %0d for VGA coordinate (%0d,%0d)",
                address, item.x_pixel, item.y_pixel
            ))
            return;
        end

        expected_rgb = rgb565_to_rgb444(reference_memory[address]);
        if (item.rgb !== expected_rgb)
            report_mismatch($sformatf(
                "Framebuffer read mismatch at VGA (%0d,%0d), address %0d: expected 0x%03h, got 0x%03h",
                item.x_pixel, item.y_pixel, address, expected_rgb, item.rgb
            ));
    endfunction

    protected function time expected_minimum_sccb_gap(int unsigned index);
        case (index)
            1:  return 30ms;
            43: return 10ms;
            44, 45, 46, 47, 48, 49, 50, 51: return 1ms;
            57: return 10ms;
            default: return 0ns;
        endcase
    endfunction

    protected function void check_sccb_write(cam_set_item item);
        bit [15:0] actual_command;
        time minimum_gap;
        time actual_gap;

        actual_command = {item.sccb_reg, item.sccb_data};

        if (item.sccb_id !== 8'h42)
            report_mismatch($sformatf(
                "SCCB device ID mismatch at transfer %0d: expected 0x42, got 0x%02h",
                sccb_index, item.sccb_id
            ));

        if (sccb_index >= expected_sccb.size()) begin
            report_mismatch($sformatf(
                "Unexpected extra SCCB command 0x%04h", actual_command
            ));
            return;
        end

        if (actual_command !== expected_sccb[sccb_index])
            report_mismatch($sformatf(
                "SCCB command %0d mismatch: expected 0x%04h, got 0x%04h",
                sccb_index, expected_sccb[sccb_index], actual_command
            ));

        if (sccb_index > 0) begin
            minimum_gap = expected_minimum_sccb_gap(sccb_index);
            actual_gap  = item.timestamp - last_sccb_timestamp;
            if ((minimum_gap != 0ns) && (actual_gap < minimum_gap))
                report_mismatch($sformatf(
                    "SCCB delay before command %0d is too short: expected at least %0t, got %0t",
                    sccb_index, minimum_gap, actual_gap
                ));
        end

        last_sccb_timestamp = item.timestamp;
        sccb_index++;

        if (sccb_index == expected_sccb.size()) begin
            `uvm_info(get_type_name(),
                "Observed all 62 SCCB initialization writes", UVM_LOW)
            sccb_init_done.trigger();
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if (expected_pixel_q.size() != 0)
            report_mismatch($sformatf(
                "%0d expected camera pixels were not written", expected_pixel_q.size()
            ));

        if (require_sccb_complete && (sccb_index != expected_sccb.size()))
            report_mismatch($sformatf(
                "SCCB initialization incomplete: expected %0d writes, observed %0d",
                expected_sccb.size(), sccb_index
            ));

        if ((required_camera_writes != 0) &&
            (camera_write_count != required_camera_writes))
            report_mismatch($sformatf(
                "Camera write count mismatch: expected %0d, observed %0d",
                required_camera_writes, camera_write_count
            ));

        if ((required_fb_reads != 0) &&
            (framebuffer_read_count != required_fb_reads))
            report_mismatch($sformatf(
                "Framebuffer read count mismatch: expected %0d, observed %0d",
                required_fb_reads, framebuffer_read_count
            ));
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "==============================================", UVM_NONE)
        `uvm_info(get_type_name(), "          CAM_SET VERIFICATION SUMMARY        ", UVM_NONE)
        `uvm_info(get_type_name(), "==============================================", UVM_NONE)
        if (required_camera_writes != 0)
            `uvm_info(get_type_name(), $sformatf(
                "Camera writes : %0d / %0d",
                camera_write_count, required_camera_writes
            ), UVM_NONE)
        else
            `uvm_info(get_type_name(), $sformatf(
                "Camera writes : %0d", camera_write_count
            ), UVM_NONE)

        if (required_fb_reads != 0)
            `uvm_info(get_type_name(), $sformatf(
                "FB reads      : %0d / %0d",
                framebuffer_read_count, required_fb_reads
            ), UVM_NONE)
        else
            `uvm_info(get_type_name(), $sformatf(
                "FB reads      : %0d", framebuffer_read_count
            ), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("SCCB writes   : %0d / %0d", sccb_index, expected_sccb.size()), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Errors        : %0d", error_count), UVM_NONE)
        if (error_count == 0)
            `uvm_info(get_type_name(), "Result        : SUCCESS", UVM_NONE)
        else
            `uvm_info(get_type_name(), "Result        : FAILURE", UVM_NONE)
        `uvm_info(get_type_name(), "==============================================", UVM_NONE)
    endfunction
endclass

`endif
