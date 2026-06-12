`timescale 1ns / 1ps

module SPI_slave(
    input  logic       clk,     
    input  logic       reset,   
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] tx_data, 
    input  logic       sclk,
    input  logic       mosi,
    input  logic       cs_n,
    output logic       miso,
    output logic [7:0] rx_data, 
    output logic       done     
);

    logic [2:0] bit_cnt;
    logic [7:0] shift_reg;

    // SPI 모드에 따른 샘플링 엣지 결정
    // CPOL=0, CPHA=0 -> posedge sclk  (sample_clk=1)
    // CPOL=0, CPHA=1 -> negedge sclk  (sample_clk=0)
    // CPOL=1, CPHA=0 -> negedge sclk  (sample_clk=0)
    // CPOL=1, CPHA=1 -> posedge sclk  (sample_clk=1)
    wire sample_clk = ~(cpol ^ cpha); 


   
    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt   <= 0;
            shift_reg <= 0;
            done      <= 0;
          
        end else if (sample_clk) begin
            shift_reg <= {shift_reg[6:0], mosi};
            if (bit_cnt == 7) begin
                bit_cnt <= 0;
                rx_data <= {shift_reg[6:0], mosi};
                done    <= 1'b1;
            end else begin
                bit_cnt <= bit_cnt + 1;
                done    <= 1'b0;
            end
        end
    end

   
    
    always @(negedge sclk) begin
        if (!cs_n && !sample_clk) begin
            shift_reg <= {shift_reg[6:0], mosi};
            if (bit_cnt == 7) begin
                bit_cnt <= 0;
                rx_data <= {shift_reg[6:0], mosi};
                done    <= 1'b1;
            end else begin
                bit_cnt <= bit_cnt + 1;
                done    <= 1'b0;
            end
        end
    end

   
   
    logic [7:0] tx_load_reg;

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            tx_load_reg <= tx_data;
            miso        <= tx_data[7];
        end else if (sample_clk) begin  
            tx_load_reg <= {tx_load_reg[6:0], 1'b0};
            miso        <= tx_load_reg[6];
        end
    end

    always @(posedge sclk) begin
        if (!cs_n && !sample_clk) begin  
            tx_load_reg <= {tx_load_reg[6:0], 1'b0};
            miso        <= tx_load_reg[6];
        end
    end

endmodule