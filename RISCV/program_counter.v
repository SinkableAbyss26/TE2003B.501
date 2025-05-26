module program_counter #(
    parameter ADDR_WIDTH = 32,
    parameter RESET_VECTOR = 32'h00000000
) (
    input                       clk_i,
    input                       rst_n_i,
    input  [ADDR_WIDTH-1:0]     pc_next_i,
    output reg [ADDR_WIDTH-1:0] pc_o
);

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            pc_o <= RESET_VECTOR;
        end else begin
            pc_o <= pc_next_i;
        end
    end

endmodule