module alu_control (
    input  [1:0] alu_op_i,     // Desde ControlUnit
    input  [2:0] funct3_i,     // Desde la instrucción
    input        funct7_bit5_i,  // instr[30] para distinguir ADD/SUB, SRL/SRA
    output reg [3:0] alu_ctrl_o   // Señal de control para la ALU
);

    // Definiciones de las operaciones de la ALU
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

    // Definiciones para alu_op_i desde ControlUnit
    localparam ALUOP_LW_SW  = 2'b00;
    localparam ALUOP_BRANCH = 2'b01;
    localparam ALUOP_R_TYPE = 2'b10; // Operación R-Type, decodificar funct3/funct7
    localparam ALUOP_I_TYPE = 2'b11; // Operación I-Type (ALU immediate), decodificar funct3

    always @(*) begin
        case (alu_op_i)
            ALUOP_LW_SW: begin // Para LW/SW, la ALU siempre suma (addr + offset)
                alu_ctrl_o = ALU_CTRL_ADD;
            end
            ALUOP_BRANCH: begin // Para BEQ/BNE, la ALU suma PC + Imm para el target
                                // La comparación se hace en BranchComparator
                alu_ctrl_o = ALU_CTRL_ADD; // O si la ALU compara: ALU_CTRL_SUB
            end
            ALUOP_R_TYPE: begin // Instrucciones R-Type
                case (funct3_i)
                    3'b000: alu_ctrl_o = funct7_bit5_i ? ALU_CTRL_SUB : ALU_CTRL_ADD; // ADD/SUB
                    3'b001: alu_ctrl_o = ALU_CTRL_SLL;  // SLL
                    3'b010: alu_ctrl_o = ALU_CTRL_SLT;  // SLT
                    3'b011: alu_ctrl_o = ALU_CTRL_SLTU; // SLTU
                    3'b100: alu_ctrl_o = ALU_CTRL_XOR;  // XOR
                    3'b101: alu_ctrl_o = funct7_bit5_i ? ALU_CTRL_SRA : ALU_CTRL_SRL; // SRL/SRA
                    3'b110: alu_ctrl_o = ALU_CTRL_OR;   // OR
                    3'b111: alu_ctrl_o = ALU_CTRL_AND;  // AND
                    default: alu_ctrl_o = 4'dx; // Operación desconocida
                endcase
            end
            ALUOP_I_TYPE: begin // Instrucciones I-Type (ADDI, SLTI, etc.)
                 case (funct3_i)
                    3'b000: alu_ctrl_o = ALU_CTRL_ADD;  // ADDI
                    3'b001: alu_ctrl_o = ALU_CTRL_SLL;  // SLLI
                    3'b010: alu_ctrl_o = ALU_CTRL_SLT;  // SLTI
                    3'b011: alu_ctrl_o = ALU_CTRL_SLTU; // SLTIU
                    3'b100: alu_ctrl_o = ALU_CTRL_XOR;  // XORI
                    3'b101: alu_ctrl_o = funct7_bit5_i ? ALU_CTRL_SRA : ALU_CTRL_SRL; // SRLI/SRAI
                    3'b110: alu_ctrl_o = ALU_CTRL_OR;   // ORI
                    3'b111: alu_ctrl_o = ALU_CTRL_AND;  // ANDI
                    default: alu_ctrl_o = 4'dx; // Operación desconocida
                endcase
            end
            default: alu_ctrl_o = 4'dx; // Undefined alu_op_i
        endcase
    end

endmodule