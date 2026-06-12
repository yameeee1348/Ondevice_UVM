class axi_spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_spi_scoreboard)

    uvm_analysis_imp#(axi_spi_item, axi_spi_scoreboard) ap_imp;

   
    logic [7:0] expected_rx_q[$];
    
    int total_trans = 0;
    int err_count = 0;

    function new(string name = "axi_spi_scoreboard", uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    virtual function void write(axi_spi_item tx);
        total_trans++;

        // 1. [M->S] 체크
        if (tx.master_data !== tx.slave_rx_val) begin
            `uvm_error(get_type_name(), $sformatf("FAIL [M->S]! Master_TX = 0x%02x, Slave_RX = 0x%02x", tx.master_data, tx.slave_rx_val))
            err_count++;
        end

        // 2. [S->M] 체크
        expected_rx_q.push_back(tx.slave_data);

       
        if (expected_rx_q.size() > 1) begin
           
            logic [7:0] expected_rx = expected_rx_q.pop_front();
            
            
            if (tx.master_rx_val !== expected_rx) begin
                `uvm_error(get_type_name(), $sformatf("FAIL [S->M]! Expected_RX = 0x%02x, Actual_Master_RX = 0x%02x", expected_rx, tx.master_rx_val))
                err_count++;
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "--------------------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "             AXI-SPI VERIFICATION SUMMARY         ", UVM_NONE)
        if (err_count == 0) begin
            `uvm_info(get_type_name(), " Result      : ** SUCCESS **", UVM_NONE)
        end else begin
            `uvm_info(get_type_name(), " Result      : ** FAILURE **", UVM_NONE)
        end
        `uvm_info(get_type_name(), $sformatf(" Total Trans : %0d", total_trans), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" Error Count : %0d", err_count), UVM_NONE)
        `uvm_info(get_type_name(), "--------------------------------------------------", UVM_NONE)
    endfunction
endclass