`ifndef AXI_SPI_SEQUENCE_SV
`define AXI_SPI_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_spi_item.sv"


class axi_spi_base_seq extends uvm_sequence#(axi_spi_item);
    `uvm_object_utils(axi_spi_base_seq)

    function new(string name = "axi_spi_base_seq");
        super.new(name);
    endfunction

    
    task do_transfer(
        bit [7:0] m_data,
        bit [7:0] s_data,
        bit [7:0] div  = 8'd49,
        bit       pol  = 0,
        bit       pha  = 0
    );
        axi_spi_item item = axi_spi_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
            master_data == m_data;
            slave_data  == s_data;
            clk_div_val == div;
            cpol_val    == pol;
            cpha_val    == pha;
        }) `uvm_fatal(get_type_name(), "Randomize FAIL!")
        finish_item(item);
    endtask
endclass



class axi_spi_sanity_seq extends axi_spi_base_seq;
    `uvm_object_utils(axi_spi_sanity_seq)

    int num_loop = 20;

    function new(string name = "axi_spi_sanity_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario 1: Sanity Random Test Start", UVM_LOW)
        repeat(num_loop) begin
            axi_spi_item item = axi_spi_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAIL!")
            finish_item(item);
        end
        `uvm_info(get_type_name(),
            $sformatf("Scenario 1 Done: %0d transactions", num_loop), UVM_LOW)
    endtask
endclass



class axi_spi_mode_sweep_seq extends axi_spi_base_seq;
    `uvm_object_utils(axi_spi_mode_sweep_seq)

    
    int num_per_mode = 5;

    function new(string name = "axi_spi_mode_sweep_seq");
        super.new(name);
    endfunction

    virtual task body();
        
        bit [1:0] modes[4] = '{2'b00, 2'b01, 2'b10, 2'b11};

        
        bit [7:0] patterns[4] = '{8'h00, 8'hFF, 8'hAA, 8'h55};

        `uvm_info(get_type_name(), "Scenario 2: Mode Sweep Start", UVM_LOW)

        foreach (modes[i]) begin
            bit cpol = modes[i][1];
            bit cpha = modes[i][0];

            `uvm_info(get_type_name(),
                $sformatf("  Mode %0d: CPOL=%0b CPHA=%0b", i, cpol, cpha), UVM_LOW)

           
            foreach (patterns[j]) begin
                do_transfer(
                    .m_data(patterns[j]),
                    .s_data(patterns[(j+1) % 4]),  
                    .div   (8'd49),
                    .pol   (cpol),
                    .pha   (cpha)
                );
            end

            
            repeat(num_per_mode) begin
                axi_spi_item item = axi_spi_item::type_id::create("item");
                start_item(item);
                if (!item.randomize() with {
                    cpol_val == cpol;
                    cpha_val == cpha;
                }) `uvm_fatal(get_type_name(), "Randomize FAIL!")
                finish_item(item);
            end
        end

        `uvm_info(get_type_name(),
            $sformatf("Scenario 2 Done: %0d modes x (%0d patterns + %0d random)",
                      4, 4, num_per_mode), UVM_LOW)
    endtask
endclass



class axi_spi_stress_seq extends axi_spi_base_seq;
    `uvm_object_utils(axi_spi_stress_seq)

    int num_loop = 50;

    function new(string name = "axi_spi_stress_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Scenario 3: Stress Test Start (min clk_div=2)", UVM_LOW)
        repeat(num_loop) begin
            axi_spi_item item = axi_spi_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                clk_div_val == 8'd2;   
            }) `uvm_fatal(get_type_name(), "Randomize FAIL!")
            finish_item(item);
        end
        `uvm_info(get_type_name(),
            $sformatf("Scenario 3 Done: %0d transactions", num_loop), UVM_LOW)
    endtask
endclass



class axi_spi_corner_seq extends axi_spi_base_seq;
    `uvm_object_utils(axi_spi_corner_seq)

    function new(string name = "axi_spi_corner_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [1:0] modes[4]   = '{2'b00, 2'b01, 2'b10, 2'b11};
        bit [7:0] corners[6] = '{8'h00, 8'hFF, 8'hAA, 8'h55, 8'h01, 8'h80};

        `uvm_info(get_type_name(), "Scenario 4: Corner Case Test Start", UVM_LOW)

        foreach (modes[i]) begin
            foreach (corners[j]) begin
                do_transfer(
                    .m_data(corners[j]),
                    .s_data(corners[(j + 3) % 6]),
                    .div   (8'd49),
                    .pol   (modes[i][1]),
                    .pha   (modes[i][0])
                );
            end
        end

        `uvm_info(get_type_name(),
            $sformatf("Scenario 4 Done: %0d modes x %0d patterns = %0d transactions",
                      4, 6, 4*6), UVM_LOW)
    endtask
endclass

`endif