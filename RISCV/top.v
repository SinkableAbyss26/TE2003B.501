// Definiciones de Opcodes
`define OPCODE_LUI   7'b0110111
`define OPCODE_AUIPC 7'b0010111

module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter RF_NUM_REGS = 32,
    parameter IMEM_DEPTH_WORDS = 256,
    parameter DMEM_DEPTH_WORDS = 256,
    parameter IMEM_FILE = "test_program.mem",
    parameter PC_RESET_VECTOR = 32'h00000000
) (
    input clk_i,
    input rst_n_i
);

    // Señales internas (wires)
    // PC y lógica de siguiente PC
    wire [ADDR_WIDTH-1:0] pc_current_w;
    wire [ADDR_WIDTH-1:0] pc_plus_4_w;
    wire [ADDR_WIDTH-1:0] pc_next_w;
    wire [ADDR_WIDTH-1:0] pc_branch_target_w;
    wire [ADDR_WIDTH-1:0] pc_jump_target_w;

    // Instruction Memory
    wire [DATA_WIDTH-1:0] instr_w;

    // Decodificación de instrucción 
    wire [6:0] opcode_w;
    wire [4:0] rs1_addr_w;
    wire [4:0] rs2_addr_w;
    wire [4:0] rd_addr_w;
    wire [2:0] funct3_w;
    wire [6:0] funct7_w;
    wire       funct7_bit5_w;

    // Control Unit signals
    wire       ctrl_reg_write_w;
    wire       ctrl_mem_to_reg_w;
    wire       ctrl_mem_read_w;
    wire       ctrl_mem_write_w;
    wire       ctrl_alu_src_w;
    wire [1:0] ctrl_alu_op_w;
    wire       ctrl_branch_w;
    wire       ctrl_jump_w;

    // Register File
    wire [DATA_WIDTH-1:0] rf_rs1_data_w;
    wire [DATA_WIDTH-1:0] rf_rs2_data_w;
    wire [DATA_WIDTH-1:0] rf_rd_data_final_w;

    // Immediate Generator
    wire [DATA_WIDTH-1:0] imm_extended_w;

    // ALU
    wire [DATA_WIDTH-1:0] alu_operand_a_w; 
    wire [DATA_WIDTH-1:0] alu_operand_b_w;
    wire [DATA_WIDTH-1:0] alu_result_w;
    wire                  alu_zero_w;
    wire [3:0]            alu_ctrl_signal_w;

    // Data Memory
    wire [DATA_WIDTH-1:0] mem_rdata_w;

    // Branch Comparator
    wire                  branch_taken_cond_w;
    wire                  pc_sel_branch_w;

    // --- Decodificación de campos de la instrucción ---
    assign opcode_w   = instr_w[6:0];
    assign rd_addr_w  = instr_w[11:7];
    assign funct3_w   = instr_w[14:12];
    assign rs1_addr_w = instr_w[19:15];
    assign rs2_addr_w = instr_w[24:20];
    assign funct7_w   = instr_w[31:25];
    assign funct7_bit5_w = instr_w[30];

    // --- Program Counter ---
    program_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .RESET_VECTOR(PC_RESET_VECTOR)
    ) u_pc (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .pc_next_i(pc_next_w),
        .pc_o(pc_current_w)
    );

    // --- Adder para PC + 4 ---
    adder #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) u_adder_pc_plus_4 (
        .operand_a_i(pc_current_w),
        .operand_b_i(32'd4),
        .sum_o(pc_plus_4_w)
    );

    // --- Instruction Memory ---
    instruction_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH_WORDS(IMEM_DEPTH_WORDS),
        .MEM_FILE(IMEM_FILE)
    ) u_instr_mem (
        .addr_i(pc_current_w),
        .instr_o(instr_w)
    );

    // --- Control Unit ---
    control_unit u_control_unit (
        .opcode_i(opcode_w),
        .reg_write_o(ctrl_reg_write_w),
        .mem_to_reg_o(ctrl_mem_to_reg_w),
        .mem_read_o(ctrl_mem_read_w),
        .mem_write_o(ctrl_mem_write_w),
        .alu_src_o(ctrl_alu_src_w),
        .alu_op_o(ctrl_alu_op_w),
        .branch_o(ctrl_branch_w),
        .jump_o(ctrl_jump_w)
    );

    // --- Register File ---
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(RF_NUM_REGS)
    ) u_reg_file (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .rs1_addr_i(rs1_addr_w),
        .rs1_data_o(rf_rs1_data_w),
        .rs2_addr_i(rs2_addr_w),
        .rs2_data_o(rf_rs2_data_w),
        .rd_addr_i(rd_addr_w),
        .rd_data_i(rf_rd_data_final_w),
        .reg_write_en_i(ctrl_reg_write_w)
    );

    // --- Immediate Generator ---
    immediate_generator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_imm_gen (
        .instr_i(instr_w),
        .imm_o(imm_extended_w)
    );

    // --- ALU Control ---
    alu_control u_alu_ctrl (
        .alu_op_i(ctrl_alu_op_w),
        .funct3_i(funct3_w),
        .funct7_bit5_i(funct7_bit5_w),
        .alu_ctrl_o(alu_ctrl_signal_w)
    );

    // --- MUX para el segundo operando de la ALU ---
    mux #( 
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mux_alu_operand_b (
        .data0_i(rf_rs2_data_w),    // sel=0
        .data1_i(imm_extended_w), // sel=1
        .sel_i(ctrl_alu_src_w),
        .data_o(alu_operand_b_w)
    );

    // --- MUX para el primer operando de la ALU (alu_operand_a_w) ---
    // Usando la lógica ternaria que estaba comentada.
    assign alu_operand_a_w = (opcode_w == `OPCODE_LUI)   ? 32'b0 :
                             (opcode_w == `OPCODE_AUIPC) ? pc_current_w :
                                                          rf_rs1_data_w;
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (
        .operand_a_i(alu_operand_a_w),
        .operand_b_i(alu_operand_b_w),
        .alu_ctrl_i(alu_ctrl_signal_w),
        .result_o(alu_result_w),
        .zero_o(alu_zero_w)
    );

    // --- Data Memory ---
    data_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH_WORDS(DMEM_DEPTH_WORDS)
    ) u_data_mem (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .addr_i(alu_result_w),
        .wdata_i(rf_rs2_data_w),
        .mem_read_en_i(ctrl_mem_read_w),
        .mem_write_en_i(ctrl_mem_write_w),
        .rdata_o(mem_rdata_w)
    );

    // --- MUX para el dato a escribir en el Register File ---
    wire [1:0] rf_write_data_sel_w;
    assign rf_write_data_sel_w = (ctrl_jump_w)         ? 2'b10 : // JAL escribe PC+4
                                 (ctrl_mem_to_reg_w)   ? 2'b01 : // LW escribe MemData
                                                         2'b00 ; // Otros escriben ALUResult

    assign rf_rd_data_final_w = (rf_write_data_sel_w == 2'b00) ? alu_result_w :
                                (rf_write_data_sel_w == 2'b01) ? mem_rdata_w :
                                (rf_write_data_sel_w == 2'b10) ? pc_plus_4_w :
                                                                 32'hxxxxxxxx;

    // --- Branch Logic ---
    adder #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) u_adder_branch_target (
        .operand_a_i(pc_current_w),
        .operand_b_i(imm_extended_w),
        .sum_o(pc_branch_target_w)
    );

    branch_comparator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_branch_comp (
        .rs1_data_i(rf_rs1_data_w),
        .rs2_data_i(rf_rs2_data_w),
        .funct3_i(funct3_w),
        .branch_taken_o(branch_taken_cond_w)
    );

    assign pc_sel_branch_w = ctrl_branch_w && branch_taken_cond_w;

    // --- JAL target ---
    adder #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) u_adder_jal_target (
        .operand_a_i(pc_current_w),
        .operand_b_i(imm_extended_w),
        .sum_o(pc_jump_target_w)
    );

    // --- MUX para seleccionar el siguiente PC ---
    assign pc_next_w = ctrl_jump_w       ? pc_jump_target_w :
                       pc_sel_branch_w   ? pc_branch_target_w :
                                           pc_plus_4_w;
endmodule