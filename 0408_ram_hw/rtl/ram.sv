module ram (
    input logic clk,
    input logic we,
    input logic [7:0] addr,
    input logic [15:0] wdata,
    output logic [15:0] rdata
);
    
    logic [15:0] ram [0:255];

    always_ff @( posedge clk ) begin 
        if (we) begin
            ram[addr] <= wdata;
        end
        else begin
            rdata <= ram[addr];

        end
    end
endmodule