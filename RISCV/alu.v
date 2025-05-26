module alu #(
    parameter DATA_WIDTH = 32
) (
    input  [DATA_WIDTH-1:0] operand_a_i,
    input  [DATA_WIDTH-1:0] operand_b_i, // Puede ser rs2_data o inmediato
    input  [3:0]            alu_ctrl_i,  // Desde ALUControl
    output reg [DATA_WIDTH-1:0] result_o,
    output reg              zero_o       // Para saltos condicionales (si result_o == 0)
);

    // Definiciones de las operaciones de la ALU (deben coincidir con alu_control.v)
    localparam ALU_CTRL_ADD  = 4'b0000;
    localparam ALU_CTRL_SUB  = 4'b0001;
    localparam ALU_CTRL_SLL  = 4'b0010;
    localparam ALU_CTRL_SLT  = 4'b0011;
    localparam ALU_CTRL_SLTU = 4'b0100;
    localparam ALU_CTRL_XOR  = 4'b0101;
    localparam ALU_CTRL_SRL  = 4'b0110; // Shift Right Logical
    localparam ALU_CTRL_SRA  = 4'b0111; // Shift Right Arithmetic
    localparam ALU_CTRL_OR   = 4'b1000;
    localparam ALU_CTRL_AND  = 4'b1001;

    // Para SLL, SRL, SRA, el operando B (shamt) solo usa los 5 bits inferiores
    wire [4:0] shamt = operand_b_i[4:0]; // shamt debe ser wire ya que se asigna con 'assign' implícito

    always @(*) begin
        case (alu_ctrl_i)
            ALU_CTRL_ADD:  result_o = operand_a_i + operand_b_i;
            ALU_CTRL_SUB:  result_o = operand_a_i - operand_b_i;
            ALU_CTRL_SLL:  result_o = operand_a_i << shamt;
            ALU_CTRL_SLT:  result_o = ($signed(operand_a_i) < $signed(operand_b_i)) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} : {DATA_WIDTH{1'b0}};
            ALU_CTRL_SLTU: result_o = (operand_a_i < operand_b_i) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} : {DATA_WIDTH{1'b0}};
            ALU_CTRL_XOR:  result_o = operand_a_i ^ operand_b_i;
            ALU_CTRL_SRL:  result_o = operand_a_i >> shamt;
            ALU_CTRL_SRA:  result_o = $signed(operand_a_i) >>> shamt;
            ALU_CTRL_OR:   result_o = operand_a_i | operand_b_i;
            ALU_CTRL_AND:  result_o = operand_a_i & operand_b_i;
            default:       result_o = {DATA_WIDTH{1'bx}}; // Operación desconocida, usar DATA_WIDTH
        endcase

        // Asignar zero_o basado en el result_o calculado
        // El BranchComparator manejará la lógica de salto específica.
        zero_o = (result_o == {DATA_WIDTH{1'b0}}); // Usar DATA_WIDTH para el literal 0
    end


endmodule