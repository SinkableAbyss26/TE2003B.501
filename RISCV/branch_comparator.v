module branch_comparator #(
    parameter DATA_WIDTH = 32
) (
    input [DATA_WIDTH-1:0] rs1_data_i,
    input [DATA_WIDTH-1:0] rs2_data_i,
    input [2:0]            funct3_i,     // Para determinar tipo de branch (BEQ, BNE, etc.)
    output reg             branch_taken_o
);

    // funct3 para Branch
    localparam FUNCT3_BEQ = 3'b000;
    localparam FUNCT3_BNE = 3'b001;

    always @(*) begin
        branch_taken_o = 1'b0; // Por defecto no se toma el salto
        case (funct3_i)
            FUNCT3_BEQ: if (rs1_data_i == rs2_data_i) branch_taken_o = 1'b1;
            FUNCT3_BNE: if (rs1_data_i != rs2_data_i) branch_taken_o = 1'b1;
            default: branch_taken_o = 1'b0; // No tomar salto si es un tipo no soportado
        endcase
    end

endmodule