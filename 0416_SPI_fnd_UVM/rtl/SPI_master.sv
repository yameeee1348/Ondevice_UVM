`timescale 1ns / 1ps

module SPI_master (
    input  logic       clk,
    input  logic       reset,
    input  logic       cpol, 
    input  logic       cpha, 
    input  logic [7:0] clk_div,
    input  logic [7:0] tx_data,
    input  logic       start,
    input  logic       miso,
    output logic [7:0] rx_data,
    output logic       done,
    output logic       busy,
    output logic       sclk,
    output logic       mosi,
    output logic       cs_n
);
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } spi_state_e;

    spi_state_e state;

    logic [7:0] div_cnt;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       step;
    logic       sclk_r;

    assign sclk = sclk_r;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            mosi         <= 1'b1;
            cs_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            sclk_r       <= 1'b0;
            div_cnt      <= 8'd0;
            bit_cnt      <= 3'd0;
            step         <= 1'b0;
            tx_shift_reg <= 8'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    busy    <= 1'b0;
                    cs_n    <= 1'b1;
                    mosi    <= 1'b1;
                    sclk_r  <= cpol;
                    div_cnt <= 8'd0;
                    if (start) begin
                        busy         <= 1'b1;
                        cs_n         <= 1'b0;
                        tx_shift_reg <= tx_data;
                        bit_cnt      <= 3'd0;
                        step         <= 1'b0;
                        state        <= START;
                    end
                end

            
                START: begin
                    if (div_cnt >= (clk_div + 8'd3)) begin 
                        div_cnt <= 8'd0;
                        state   <= DATA;
                        if (!cpha) begin
                            mosi         <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        end
                    end else begin
                        div_cnt <= div_cnt + 8'd1;
                    end
                end

                DATA: begin
                    if (div_cnt >= clk_div) begin
                        div_cnt <= 8'd0;
                        sclk_r  <= ~sclk_r; // SCLK 토글

                        if (step == 1'b0) begin // Leading Edge (첫 번째 엣지)
                            step <= 1'b1;
                            if (!cpha) begin // Mode 0, 2: 샘플링
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end else begin   // Mode 1, 3: 드라이빙
                                mosi         <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            end
                        end else begin // Trailing Edge (두 번째 엣지)
                            step <= 1'b0;
                            if (!cpha) begin // Mode 0, 2: 드라이빙
                                if (bit_cnt < 7) begin
                                    mosi         <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                            end else begin   // Mode 1, 3: 샘플링
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end

                            // 8비트 전송 완료 체크
                            if (bit_cnt == 7) begin
                                state <= STOP;
                                //  rx_data  업데이트
                               // if (!cpha) rx_data <= rx_shift_reg; 
                               // else       rx_data <= {rx_shift_reg[6:0], miso};
                            end else begin
                                bit_cnt <= bit_cnt + 3'd1;
                            end
                        end
                    end else begin
                        div_cnt <= div_cnt + 8'd1;
                    end
                end

                STOP: begin
                    //  마지막 반주기 대기 후 IDLE로 복귀하여 안정성 확보
                    if (div_cnt >= (clk_div + 8'd2)) begin
                        div_cnt <= 8'd0;
                        sclk_r  <= cpol;
                        cs_n    <= 1'b1;
                        done    <= 1'b1;
                        busy    <= 1'b0;
                        mosi    <= 1'b1;
                        rx_data <= rx_shift_reg;
                        state   <= IDLE;
                    end else begin
                        div_cnt <= div_cnt + 8'd1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule