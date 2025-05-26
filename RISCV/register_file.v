module register_file #(
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 32,
    parameter ADDR_WIDTH_RF = $clog2(NUM_REGS) // Debería ser 5 para 32 registros
) (
    input                          clk_i,
    input                          rst_n_i,

    // Puerto de lectura 1
    input  [ADDR_WIDTH_RF-1:0]     rs1_addr_i,
    output [DATA_WIDTH-1:0]       rs1_data_o,

    // Puerto de lectura 2
    input  [ADDR_WIDTH_RF-1:0]     rs2_addr_i,
    output [DATA_WIDTH-1:0]       rs2_data_o,

    // Puerto de escritura
    input  [ADDR_WIDTH_RF-1:0]     rd_addr_i,
    input  [DATA_WIDTH-1:0]        rd_data_i,
    input                          reg_write_en_i
);

    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];
    integer i;

    // Escritura síncrona
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            // Inicializar todos los registros a 0 en reset (opcional, pero bueno para simulación)
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else begin
            if (reg_write_en_i && (rd_addr_i != 5'b0)) begin // x0 (zero) no se puede escribir
                registers[rd_addr_i] <= rd_data_i;
            end
        end
    end

    // Lectura combinacional
    // x0 siempre es cero, independientemente de lo que se le escriba
    assign rs1_data_o = (rs1_addr_i == 5'b0) ? 32'b0 : registers[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 5'b0) ? 32'b0 : registers[rs2_addr_i];

endmodule