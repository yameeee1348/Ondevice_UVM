`ifndef CAM_SET_SEQUENCE_SV
`define CAM_SET_SEQUENCE_SV

class cam_set_base_sequence extends uvm_sequence #(cam_set_item);
    `uvm_object_utils(cam_set_base_sequence)

    function new(string name = "cam_set_base_sequence");
        super.new(name);
    endfunction

    task send_vsync(int unsigned num_cycles = 2);
        cam_set_item req;
        req = cam_set_item::type_id::create("vsync_req");
        start_item(req);
        req.kind   = DRV_CAM_VSYNC;
        req.cycles = num_cycles;
        finish_item(req);
    endtask

    task send_line(input bit [15:0] line_pixels[]);
        cam_set_item req;
        req = cam_set_item::type_id::create("line_req");
        start_item(req);
        req.kind   = DRV_CAM_LINE;
        req.pixels = new[line_pixels.size()];
        foreach (line_pixels[i])
            req.pixels[i] = line_pixels[i];
        finish_item(req);
    endtask

    task send_read(bit [9:0] x, bit [9:0] y, bit enable = 1'b1);
        cam_set_item req;
        req = cam_set_item::type_id::create("read_req");
        start_item(req);
        req.kind    = DRV_FB_READ;
        req.x_pixel = x;
        req.y_pixel = y;
        req.de      = enable;
        finish_item(req);
    endtask

    task send_idle(int unsigned num_cycles = 1);
        cam_set_item req;
        req = cam_set_item::type_id::create("idle_req");
        start_item(req);
        req.kind   = DRV_IDLE;
        req.cycles = num_cycles;
        finish_item(req);
    endtask
endclass

class cam_set_smoke_sequence extends cam_set_base_sequence;
    `uvm_object_utils(cam_set_smoke_sequence)

    function new(string name = "cam_set_smoke_sequence");
        super.new(name);
    endfunction

    virtual task body();
        bit [15:0] line[];

        line = new[8];
        line[0] = 16'h0000;
        line[1] = 16'hFFFF;
        line[2] = 16'hF800;
        line[3] = 16'h07E0;
        line[4] = 16'h001F;
        line[5] = 16'hAA55;
        line[6] = 16'h55AA;
        line[7] = 16'h1234;

        `uvm_info(get_type_name(), "CAM_Set smoke sequence start", UVM_LOW)
        send_vsync(2);
        send_line(line);
        send_idle(2);

        // Each source pixel occupies a 2x2 VGA area.
        send_read(10'd0,  10'd0, 1'b1);
        send_read(10'd1,  10'd1, 1'b1);
        send_read(10'd2,  10'd0, 1'b1);
        send_read(10'd6,  10'd1, 1'b1);
        send_read(10'd14, 10'd0, 1'b1);
        send_read(10'd0,  10'd0, 1'b0);
        `uvm_info(get_type_name(), "CAM_Set smoke sequence done", UVM_LOW)
    endtask
endclass

class cam_set_full_frame_sequence extends cam_set_base_sequence;
    `uvm_object_utils(cam_set_full_frame_sequence)

    function new(string name = "cam_set_full_frame_sequence");
        super.new(name);
    endfunction

    function automatic bit [15:0] make_pixel(int x, int y);
        bit [4:0] red;
        bit [5:0] green;
        bit [4:0] blue;
        red   = x[4:0];
        green = y[5:0];
        blue  = (x + y) & 5'h1F;
        return {red, green, blue};
    endfunction

    virtual task body();
        bit [15:0] line[];

        `uvm_info(get_type_name(), "Full 320x240 camera frame start", UVM_LOW)
        send_vsync(2);

        for (int y = 0; y < 240; y++) begin
            line = new[320];
            for (int x = 0; x < 320; x++)
                line[x] = make_pixel(x, y);
            send_line(line);
        end

        send_idle(2);
        send_read(10'd0,   10'd0,   1'b1);
        send_read(10'd1,   10'd1,   1'b1);
        send_read(10'd320, 10'd240, 1'b1);
        send_read(10'd638, 10'd478, 1'b1);
        send_read(10'd639, 10'd479, 1'b1);
        send_read(10'd0,   10'd0,   1'b0);
        `uvm_info(get_type_name(), "Full 320x240 camera frame done", UVM_LOW)
    endtask
endclass

class cam_set_full_read_sequence extends cam_set_base_sequence;
    `uvm_object_utils(cam_set_full_read_sequence)

    function new(string name = "cam_set_full_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(),
            "Full 640x480 framebuffer read start", UVM_LOW)

        for (int y = 0; y < 480; y++) begin
            for (int x = 0; x < 640; x++) begin
                send_read(x[9:0], y[9:0], 1'b1);
            end
        end

        send_read(10'd0, 10'd0, 1'b0);
        `uvm_info(get_type_name(),
            "Full 640x480 framebuffer read done", UVM_LOW)
    endtask
endclass

class cam_set_random_sequence extends cam_set_base_sequence;
    `uvm_object_utils(cam_set_random_sequence)

    function new(string name = "cam_set_random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        bit [15:0] line[];
        int x;
        int y;

        `uvm_info(get_type_name(), "Random camera sequence start", UVM_LOW)
        send_vsync($urandom_range(1, 4));

        for (int row = 0; row < 240; row++) begin
            line = new[320];
            foreach (line[col])
                line[col] = $urandom;
            send_line(line);
            if ($urandom_range(0, 1))
                send_idle($urandom_range(1, 4));
        end

        repeat (32) begin
            x = $urandom_range(0, 639);
            y = $urandom_range(0, 479);
            send_read(x[9:0], y[9:0], 1'b1);
        end
        send_read(10'd0, 10'd0, 1'b0);
        `uvm_info(get_type_name(), "Random camera sequence done", UVM_LOW)
    endtask
endclass

`endif
