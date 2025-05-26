module adder #(
    parameter DATA_WIDTH = 32
) (
    input  [DATA_WIDTH-1:0] operand_a_i,
    input  [DATA_WIDTH-1:0] operand_b_i,
    output [DATA_WIDTH-1:0] sum_o
);

    assign sum_o = operand_a_i + operand_b_i;

endmodule