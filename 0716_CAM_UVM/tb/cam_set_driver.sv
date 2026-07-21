`ifndef CAM_SET_DRIVER_SV
`define CAM_SET_DRIVER_SV

class cam_set_driver extends uvm_driver #(cam_set_item);
    `uvm_component_utils(cam_set_driver)

    virtual cam_set_interface vif;

    function new(string name = "cam_set_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual cam_set_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "cam_set_interface was not configured")
    endfunction

    virtual task run_phase(uvm_phase phase);
        cam_set_item req;

        vif.href    <= 1'b0;
        vif.vsync   <= 1'b0;
        vif.pdata   <= 8'h00;
        vif.x_pixel <= 10'd0;
        vif.y_pixel <= 10'd0;
        vif.de      <= 1'b0;

        wait (vif.reset === 1'b0);
        `uvm_info(get_type_name(), "CAM_Set driver started", UVM_LOW)

        forever begin
            seq_item_port.get_next_item(req);

            case (req.kind)
                DRV_CAM_LINE:  drive_camera_line(req);
                DRV_CAM_VSYNC: drive_vsync(req.cycles);
                DRV_FB_READ:   drive_fb_read(req);
                DRV_IDLE:      drive_idle(req.cycles);
                default:
                    `uvm_error(get_type_name(),
                        $sformatf("Unsupported driver item kind: %s", req.kind.name()))
            endcase

            seq_item_port.item_done();
        end
    endtask

    protected task drive_camera_line(cam_set_item req);
        foreach (req.pixels[i]) begin
            @(vif.cam_drv_cb);
            vif.cam_drv_cb.vsync <= 1'b0;
            vif.cam_drv_cb.href  <= 1'b1;
            vif.cam_drv_cb.pdata <= req.pixels[i][15:8];

            @(vif.cam_drv_cb);
            vif.cam_drv_cb.href  <= 1'b1;
            vif.cam_drv_cb.pdata <= req.pixels[i][7:0];
        end

        @(vif.cam_drv_cb);
        vif.cam_drv_cb.href  <= 1'b0;
        vif.cam_drv_cb.pdata <= 8'h00;
    endtask

    protected task drive_vsync(int unsigned cycles);
        int unsigned count;
        count = (cycles == 0) ? 1 : cycles;

        for (int unsigned i = 0; i < count; i++) begin
            @(vif.cam_drv_cb);
            vif.cam_drv_cb.href  <= 1'b0;
            vif.cam_drv_cb.pdata <= 8'h00;
            vif.cam_drv_cb.vsync <= 1'b1;
        end

        @(vif.cam_drv_cb);
        vif.cam_drv_cb.vsync <= 1'b0;
    endtask

    protected task drive_fb_read(cam_set_item req);
        @(vif.read_drv_cb);
        vif.read_drv_cb.x_pixel <= req.x_pixel;
        vif.read_drv_cb.y_pixel <= req.y_pixel;
        vif.read_drv_cb.de      <= req.de;
    endtask

    protected task drive_idle(int unsigned cycles);
        int unsigned count;
        count = (cycles == 0) ? 1 : cycles;

        vif.de <= 1'b0;
        repeat (count) begin
            @(vif.cam_drv_cb);
            vif.cam_drv_cb.href  <= 1'b0;
            vif.cam_drv_cb.vsync <= 1'b0;
            vif.cam_drv_cb.pdata <= 8'h00;
        end
    endtask
endclass

`endif

