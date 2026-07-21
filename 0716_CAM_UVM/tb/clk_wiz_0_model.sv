`timescale 1ns/1ps

module clk_wiz_0 (
    output logic clk_100M,
    output logic clk_25M,
    input  logic reset,
    input  logic clk_in1
);

    logic div_cnt;

    assign clk_100M = clk_in1;

    always_ff @(posedge clk_in1 or posedge reset) begin
        if (reset) begin
            div_cnt <= 1'b0;
            clk_25M <= 1'b0;
        end else begin
            if (div_cnt) begin
                div_cnt <= 1'b0;
                clk_25M <= ~clk_25M;
            end else begin
                div_cnt <= 1'b1;
            end
        end
    end

endmodule