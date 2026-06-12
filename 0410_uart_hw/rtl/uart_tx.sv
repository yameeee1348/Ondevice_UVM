module uart_tx (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic       b_tick,
    input  logic [7:0] tx_data,
    output logic       uart_tx,
    output logic       tx_busy,
    output logic       tx_done
);

    typedef enum logic [1:0] {IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3} state_t;
    state_t c_state, n_state;

    logic       tx_reg, tx_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic       done_reg, done_next;
    logic       busy_reg, busy_next;
    logic [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    logic [7:0] data_in_buf_reg, data_in_buf_next;

    assign uart_tx = tx_reg;
    assign tx_busy = busy_reg;
    assign tx_done = done_reg;

    // state register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state         <= IDLE;
            tx_reg          <= 1'b1;
            bit_cnt_reg     <= 3'd0;
            b_tick_cnt_reg  <= 4'h0;
            busy_reg        <= 1'b0;
            done_reg        <= 1'b0;
            data_in_buf_reg <= 8'h00;
        end else begin
            c_state         <= n_state;
            tx_reg          <= tx_next;
            bit_cnt_reg     <= bit_cnt_next;
            b_tick_cnt_reg  <= b_tick_cnt_next;
            done_reg        <= done_next;
            busy_reg        <= busy_next;
            data_in_buf_reg <= data_in_buf_next;
        end
    end

    // next, output logic
    always_comb begin
        n_state          = c_state; 
        tx_next          = tx_reg;
        bit_cnt_next     = bit_cnt_reg;
        b_tick_cnt_next  = b_tick_cnt_reg;
        busy_next        = busy_reg;
        done_next        = done_reg;
        data_in_buf_next = data_in_buf_reg;

        case (c_state)
            IDLE: begin
                tx_next         = 1'b1;
                bit_cnt_next    = 3'd0;
                b_tick_cnt_next = 4'h0;
                busy_next       = 1'b0;
                done_next       = 1'b0;
                if (tx_start) begin
                    n_state          = START;
                    busy_next        = 1'b1;
                    data_in_buf_next = tx_data;
                end
            end

            START: begin
                tx_next = 1'b0; // start bit
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state         = DATA;
                        b_tick_cnt_next = 4'h0;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = data_in_buf_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 4'h0;
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_cnt_next     = bit_cnt_reg + 1;
                            n_state          = DATA;
                            data_in_buf_next = {1'b0, data_in_buf_reg[7:1]};
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; // stop bit
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        done_next = 1'b1;
                        busy_next = 1'b0;
                        n_state   = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule