module control_unit (
    input  [6:0] opcode_i,     
    output reg   reg_write_o, 
    output reg   mem_to_reg_o,  
    output reg   mem_read_o,     
    output reg   mem_write_o,   
    output reg   alu_src_o,     
    output reg [1:0] alu_op_o,  
    output reg   branch_o,       
    output reg   jump_o          
);

    // Opcodes (RV32I base)
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111; 
    localparam OPCODE_BRANCH = 7'b1100011; 
    localparam OPCODE_LOAD   = 7'b0000011; 
    localparam OPCODE_STORE  = 7'b0100011; 
    localparam OPCODE_OP_IMM = 7'b0010011; 
    localparam OPCODE_OP     = 7'b0110011; 

    // Definiciones para alu_op_o 
    localparam ALUOP_TYPE_LW_SW  = 2'b00;
    localparam ALUOP_TYPE_BRANCH = 2'b01; 
    localparam ALUOP_TYPE_R      = 2'b10;
    localparam ALUOP_TYPE_I_ARITH= 2'b11; 

    always @(*) begin
        // Valores por defecto
        reg_write_o  = 1'b0;
        mem_to_reg_o = 1'b0; 
        mem_read_o   = 1'b0;
        mem_write_o  = 1'b0;
        alu_src_o    = 1'b0; 
        alu_op_o     = ALUOP_TYPE_R; 
        branch_o     = 1'b0;
        jump_o       = 1'b0; 

        case (opcode_i)
            OPCODE_LUI: begin
                reg_write_o  = 1'b1;
                alu_src_o    = 1'b1;
                alu_op_o     = ALUOP_TYPE_I_ARITH; 
                mem_to_reg_o = 1'b0;
				end
            OPCODE_AUIPC: begin
                reg_write_o  = 1'b1;
                alu_src_o    = 1'b1; 
                alu_op_o     = ALUOP_TYPE_I_ARITH; 
                mem_to_reg_o = 1'b0; 
            end
            OPCODE_JAL: begin
                reg_write_o  = 1'b1; 
                jump_o       = 1'b1;
            end
            OPCODE_BRANCH: begin
                alu_src_o    = 1'b1; 
                alu_op_o     = ALUOP_TYPE_BRANCH; 
                branch_o     = 1'b1;
            end
            OPCODE_LOAD: begin 
                reg_write_o  = 1'b1;
                mem_to_reg_o = 1'b1;
                mem_read_o   = 1'b1;
                alu_src_o    = 1'b1;
                alu_op_o     = ALUOP_TYPE_LW_SW; 
            end
            OPCODE_STORE: begin 
                mem_write_o  = 1'b1;
                alu_src_o    = 1'b1; 
                alu_op_o     = ALUOP_TYPE_LW_SW; 
            end
            OPCODE_OP_IMM: begin 
                reg_write_o  = 1'b1;
                alu_src_o    = 1'b1; 
                alu_op_o     = ALUOP_TYPE_I_ARITH;
                mem_to_reg_o = 1'b0;
            end
            OPCODE_OP: begin 
                reg_write_o  = 1'b1;
                alu_src_o    = 1'b0; 
                alu_op_o     = ALUOP_TYPE_R;
                mem_to_reg_o = 1'b0; 
            end
            default: begin
                reg_write_o  = 1'b0;
                mem_to_reg_o = 1'b0;
                mem_read_o   = 1'b0;
                mem_write_o  = 1'b0;
                alu_src_o    = 1'b0;
                alu_op_o     = ALUOP_TYPE_R;
                branch_o     = 1'b0;
                jump_o       = 1'b0;
            end
        endcase
    end

endmodule