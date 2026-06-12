`timescale 1 ns / 1 ps

module axi_spi_m_v1_0_S00_AXI #
(
    parameter integer C_S_AXI_DATA_WIDTH    = 32,
    parameter integer C_S_AXI_ADDR_WIDTH    = 4
) 
(
    // SPI Physical Pins
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs_n,

    // AXI4-Lite Signals
    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire  S_AXI_AWVALID,
    output wire  S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WVALID,
    output wire  S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire  S_AXI_BVALID,
    input wire  S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire  S_AXI_ARVALID,
    output wire  S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire  S_AXI_RVALID,
    input wire  S_AXI_RREADY
);

    // AXI Internal Registers
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg     axi_awready;
    reg     axi_wready;
    reg [1 : 0]     axi_bresp;
    reg     axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg     axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg     axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 1;

    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg1;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg2;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg3;
    wire     slv_reg_rden;
    wire     slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out;
    integer  byte_index;
    reg  aw_en;

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP  = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA  = axi_rdata;
    assign S_AXI_RRESP  = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;

    // AXI Write Address Ready
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_awready <= 1'b0;
          aw_en <= 1'b1;
        end 
      else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
          axi_awready <= 1'b1;
          aw_en <= 1'b0;
        end
      else if (S_AXI_BREADY && axi_bvalid) begin
          aw_en <= 1'b1;
          axi_awready <= 1'b0;
        end
      else axi_awready <= 1'b0;
    end       

    // AXI Write Address Latch
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) axi_awaddr <= 0;
      else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) axi_awaddr <= S_AXI_AWADDR;
    end       

    // AXI Write Data Ready
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) axi_wready <= 1'b0;
      else if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en ) axi_wready <= 1'b1;
      else axi_wready <= 1'b0;
    end       

    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    // Register Write Logic
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          slv_reg0 <= 0; slv_reg1 <= 0; slv_reg2 <= 0; slv_reg3 <= 0;
        end 
      else if (slv_reg_wren) begin
            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
              2'h0: for ( byte_index = 0; byte_index <= 3; byte_index = byte_index+1 )
                      if ( S_AXI_WSTRB[byte_index] == 1 ) slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
              2'h1: for ( byte_index = 0; byte_index <= 3; byte_index = byte_index+1 )
                      if ( S_AXI_WSTRB[byte_index] == 1 ) slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
            endcase
          end
    end    

    // AXI Write Response
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_bvalid  <= 0; axi_bresp   <= 2'b0;
        end 
      else if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
          axi_bvalid <= 1'b1; axi_bresp  <= 2'b0; 
        end
      else if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0; 
    end   

    // AXI Read Address Ready
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_arready <= 1'b0; axi_araddr  <= 32'b0;
        end 
      else if (~axi_arready && S_AXI_ARVALID) begin
          axi_arready <= 1'b1; axi_araddr  <= S_AXI_ARADDR;
        end
      else axi_arready <= 1'b0;
    end       

    // AXI Read Data Valid
    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_rvalid <= 0; axi_rresp  <= 0;
        end 
      else if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
          axi_rvalid <= 1'b1; axi_rresp  <= 2'b0;
        end   
      else if (axi_rvalid && S_AXI_RREADY) axi_rvalid <= 1'b0;
    end    

    // =============================================================
    // USER LOGIC START
    // =============================================================
    wire [7:0] spi_rx_data;
    wire spi_done;
    wire spi_busy;
    reg start_r, start_rr;
    wire start_pulse;
    reg done_latch;

    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

    // Rising Edge Pulse for Start
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            start_r  <= 1'b0;
            start_rr <= 1'b0;
        end else begin
            start_r  <= slv_reg1[0];
            start_rr <= start_r;
        end
    end
    assign start_pulse = start_r & ~start_rr;

    // Done Signal Latching (UVM Driver Polling용)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) done_latch <= 1'b0;
        else begin
            if (start_pulse) done_latch <= 1'b0;
            else if (spi_done) done_latch <= 1'b1;
        end
    end

    // Address decoding for reading registers
    always @(*) begin
          case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            2'h0    : reg_data_out <= slv_reg0;
            2'h1    : reg_data_out <= slv_reg1;
            2'h2    : reg_data_out <= {30'd0, done_latch, spi_busy}; 
            2'h3    : reg_data_out <= {24'd0, spi_rx_data};
            default : reg_data_out <= 0;
          endcase
    end

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) axi_rdata <= 0;
      else if (slv_reg_rden) axi_rdata <= reg_data_out;
    end   

    // SPI Master Instance
    SPI_master u_spi_master (
        .clk(S_AXI_ACLK),
        .reset(~S_AXI_ARESETN),
        .cpol(slv_reg1[1]),
        .cpha(slv_reg1[2]),
        .clk_div(slv_reg1[15:8]),
        .tx_data(slv_reg0[7:0]),
        .start(start_pulse),
        .miso(miso),
        .rx_data(spi_rx_data),
        .done(spi_done),
        .busy(spi_busy),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n)
    );

endmodule

// =============================================================
// SPI Master Module (인스턴스화를 위해 같은 파일에 정의)
// =============================================================
module SPI_master (
    input  wire       clk,
    input  wire       reset,
    input  wire       cpol,
    input  wire       cpha,
    input  wire [7:0] clk_div,
    input  wire [7:0] tx_data,
    input  wire       start,
    input  wire       miso,
    output reg  [7:0] rx_data,
    output reg        done,
    output reg        busy,
    output wire       sclk,
    output reg        mosi,
    output reg        cs_n
);

    localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
    reg [1:0] state;
    reg [7:0] div_cnt;
    reg       half_tick;
    reg [7:0] tx_shift_reg, rx_shift_reg;
    reg [2:0] bit_cnt;
    reg       step;
    reg       sclk_r;

    assign sclk = sclk_r;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt <= 0; half_tick <= 1'b0;
        end else if (state == DATA) begin
            if (div_cnt == clk_div) begin
                div_cnt <= 0; half_tick <= 1'b1;
            end else begin
                div_cnt <= div_cnt + 1; half_tick <= 1'b0;
            end
        end else begin
            div_cnt <= 0; half_tick <= 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; mosi <= 1'b1; cs_n <= 1'b1;
            busy <= 1'b0; done <= 1'b0; sclk_r <= cpol;
            bit_cnt <= 0; rx_data <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    mosi <= 1'b1; cs_n <= 1'b1; sclk_r <= cpol;
                    if (start) begin
                        tx_shift_reg <= tx_data; bit_cnt <= 0;
                        step <= 1'b0; busy <= 1'b1; cs_n <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    if (!cpha) begin
                        mosi <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                    state <= DATA;
                end
                DATA: begin
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;
                        if (step == 0) begin
                            step <= 1'b1;
                            if (!cpha) rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            else begin
                                mosi <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            end
                        end else begin
                            step <= 1'b0;
                            if (!cpha) begin
                                if (bit_cnt < 7) begin
                                    mosi <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                            end else rx_shift_reg <= {rx_shift_reg[6:0], miso};

                            if (bit_cnt == 7) begin
                                state <= STOP;
                                rx_data <= (!cpha) ? rx_shift_reg : {rx_shift_reg[6:0], miso};
                            end else bit_cnt <= bit_cnt + 1;
                        end
                    end
                end
                STOP: begin
                    sclk_r <= cpol; cs_n <= 1'b1; done <= 1'b1;
                    busy <= 1'b0; mosi <= 1'b1; state <= IDLE;
                end
            endcase
        end
    end
endmodule