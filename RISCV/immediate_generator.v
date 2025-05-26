module immediate_generator #(
    parameter DATA_WIDTH = 32
) (
    input  [DATA_WIDTH-1:0] instr_i,     // Instrucción completa
    output reg [DATA_WIDTH-1:0] imm_o        // Inmediato sign-extended
);

    // Campos de la instrucción
    wire [6:0] opcode = instr_i[6:0];

    // Tipos de opcode
    localparam OPCODE_LUI   = 7'b0110111;
    localparam OPCODE_AUIPC = 7'b0010111;
    localparam OPCODE_JAL   = 7'b1101111;
    localparam OPCODE_JALR  = 7'b1100111;
    localparam OPCODE_BRANCH= 7'b1100011; 
    localparam OPCODE_LOAD  = 7'b0000011;
    localparam OPCODE_STORE = 7'b0100011; 
    localparam OPCODE_OP_IMM= 7'b0010011; 

    // Inmediatos para cada tipo
    wire [DATA_WIDTH-1:0] imm_i_type;
    wire [DATA_WIDTH-1:0] imm_s_type;
    wire [DATA_WIDTH-1:0] imm_b_type;
    wire [DATA_WIDTH-1:0] imm_u_type;
    wire [DATA_WIDTH-1:0] imm_j_type;

    // I-type: instr[31:20]
    assign imm_i_type = {{20{instr_i[31]}}, instr_i[31:20]};

    // S-type: instr[31:25], instr[11:7]
    assign imm_s_type = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

    // B-type: instr[31], instr[7], instr[30:25], instr[11:8], 1'b0
    assign imm_b_type = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

    // U-type: instr[31:12], 12'b0
    assign imm_u_type = {instr_i[31:12], 12'b0};

    // J-type: instr[31], instr[19:12], instr[20], instr[30:21], 1'b0
    assign imm_j_type = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};

    always @(*) begin
        case (opcode)
            OPCODE_LOAD,
            OPCODE_OP_IMM,
            OPCODE_JALR:    imm_o = imm_i_type;
            OPCODE_STORE:   imm_o = imm_s_type;
            OPCODE_BRANCH:  imm_o = imm_b_type;
            OPCODE_LUI,
            OPCODE_AUIPC:   imm_o = imm_u_type;
            OPCODE_JAL:     imm_o = imm_j_type;
            default:        imm_o = 32'dx;
        endcase
    end

endmodule