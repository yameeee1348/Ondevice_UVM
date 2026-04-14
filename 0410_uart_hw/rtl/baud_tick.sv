module baud_tick #(
    parameter BAUDRATE = 9600 * 16,
    parameter F_count  = 100_000_000 / BAUDRATE
)(
    input  logic clk,
    input  logic rst,
    output logic b_tick
);

    logic [$clog2(F_count)-1:0] counter_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            b_tick      <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_count - 1)) begin
                counter_reg <= 0;
                b_tick      <= 1'b1;
            end else begin
                b_tick      <= 1'b0;
            end
        end
    end
endmodule