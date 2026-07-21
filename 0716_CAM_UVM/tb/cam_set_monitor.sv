`ifndef CAM_SET_MONITOR_SV
`define CAM_SET_MONITOR_SV

class cam_set_monitor extends uvm_monitor;
    `uvm_component_utils(cam_set_monitor)

    virtual cam_set_interface vif;
    uvm_analysis_port #(cam_set_item) ap;

    function new(string name = "cam_set_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual cam_set_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "cam_set_interface was not configured")
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            monitor_camera_path();
            monitor_framebuffer_read();
            monitor_sccb_write();
        join
    endtask

    protected task monitor_camera_path();
        bit       byte_phase;
        bit [7:0] first_byte;
        bit       previous_vsync;

        byte_phase    = 1'b0;
        first_byte    = 8'h00;
        previous_vsync = 1'b0;

        forever begin
            @(vif.cam_mon_cb);

            if (vif.cam_mon_cb.reset) begin
                byte_phase     = 1'b0;
                first_byte     = 8'h00;
                previous_vsync = 1'b0;
            end else begin
                if (vif.cam_mon_cb.cam_href !== vif.cam_mon_cb.href)
                    `uvm_error(get_type_name(), "cam_href does not match href")
                if (vif.cam_mon_cb.cam_vsync !== vif.cam_mon_cb.vsync)
                    `uvm_error(get_type_name(), "cam_vsync does not match vsync")

                if (vif.cam_mon_cb.vsync && !previous_vsync) begin
                    cam_set_item sync_item;
                    sync_item = cam_set_item::type_id::create("sync_item");
                    sync_item.kind      = OBS_FRAME_SYNC;
                    sync_item.timestamp = $time;
                    ap.write(sync_item);
                end

                if (vif.cam_mon_cb.vsync || !vif.cam_mon_cb.href) begin
                    byte_phase = 1'b0;
                end else if (!byte_phase) begin
                    first_byte = vif.cam_mon_cb.pdata;
                    byte_phase = 1'b1;
                end else begin
                    cam_set_item expected_item;
                    expected_item = cam_set_item::type_id::create("expected_pixel_item");
                    expected_item.kind      = OBS_EXPECT_PIXEL;
                    expected_item.pixel     = {first_byte, vif.cam_mon_cb.pdata};
                    expected_item.timestamp = $time;
                    ap.write(expected_item);
                    byte_phase = 1'b0;
                end

                if (vif.cam_mon_cb.cam_we) begin
                    cam_set_item write_item;
                    write_item = cam_set_item::type_id::create("camera_write_item");
                    write_item.kind      = OBS_CAM_WRITE;
                    write_item.cam_addr  = vif.cam_mon_cb.cam_wAddr;
                    write_item.pixel     = vif.cam_mon_cb.cam_wData;
                    write_item.timestamp = $time;
                    ap.write(write_item);
                end

                previous_vsync = vif.cam_mon_cb.vsync;
            end
        end
    endtask

    protected task monitor_framebuffer_read();
        bit previous_de;
        previous_de = 1'b0;

        forever begin
            @(vif.read_mon_cb);

            if (vif.read_mon_cb.reset) begin
                previous_de = 1'b0;
            end else begin
                // Publish every active read and one item for the transition to blanking.
                if (vif.read_mon_cb.de || previous_de) begin
                    cam_set_item read_item;
                    read_item = cam_set_item::type_id::create("framebuffer_read_item");
                    read_item.kind      = OBS_FB_READ;
                    read_item.x_pixel   = vif.read_mon_cb.x_pixel;
                    read_item.y_pixel   = vif.read_mon_cb.y_pixel;
                    read_item.de        = vif.read_mon_cb.de;
                    read_item.rgb       = vif.read_mon_cb.cam_rgb;
                    read_item.timestamp = $time;
                    ap.write(read_item);
                end
                previous_de = vif.read_mon_cb.de;
            end
        end
    endtask

    protected task sample_sccb_byte(output bit [7:0] value);
        for (int i = 7; i >= 0; i--) begin
            @(posedge vif.scl);
            value[i] = vif.sda;
        end

        // SCCB's ninth bit is Don't Care, not an I2C ACK.
        @(posedge vif.scl);
    endtask

    protected task monitor_sccb_write();
        bit [7:0] id_byte;
        bit [7:0] reg_byte;
        bit [7:0] data_byte;

        forever begin
            // SCCB start: SDA falls while SCL is high.
            @(negedge vif.sda);
            if (!vif.reset && (vif.scl === 1'b1)) begin
                sample_sccb_byte(id_byte);
                sample_sccb_byte(reg_byte);
                sample_sccb_byte(data_byte);

                // Wait for SCCB stop: SDA rises after being pulled low while SCL is high.
                @(posedge vif.sda);

                begin
                    cam_set_item sccb_item;
                    sccb_item = cam_set_item::type_id::create("sccb_write_item");
                    sccb_item.kind      = OBS_SCCB_WRITE;
                    sccb_item.sccb_id   = id_byte;
                    sccb_item.sccb_reg  = reg_byte;
                    sccb_item.sccb_data = data_byte;
                    sccb_item.timestamp = $time;
                    ap.write(sccb_item);
                end
            end
        end
    endtask
endclass

`endif

