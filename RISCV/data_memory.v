module data_memory #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH_WORDS = 256 // 256 palabras de 32 bits = 1KB
) (
    input                       clk_i,
    input                       rst_n_i, 
    input  [ADDR_WIDTH-1:0]     addr_i,    // Dirección de byte (desde ALU)
    input  [DATA_WIDTH-1:0]     wdata_i,   // Dato a escribir (desde rs2_data)
    input                       mem_read_en_i,
    input                       mem_write_en_i,
    output [DATA_WIDTH-1:0]     rdata_o
);

    localparam ADDR_BITS_FOR_DEPTH = $clog2(MEM_DEPTH_WORDS);

    reg [DATA_WIDTH-1:0] ram_array [0:MEM_DEPTH_WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH_WORDS; i = i + 1) begin
            ram_array[i] = 32'h00000000;
        end
    end
    
    // La dirección de la ALU es de byte, la memoria se indexa por palabra.
    wire [ADDR_BITS_FOR_DEPTH-1:0] word_addr_idx;
    assign word_addr_idx = addr_i[ADDR_BITS_FOR_DEPTH+1:2]; 

    // Escritura síncrona
    always @(posedge clk_i) begin
        if (!rst_n_i) begin
        end else if (mem_write_en_i) begin
            ram_array[word_addr_idx] <= wdata_i;
        end
    end

    assign rdata_o = mem_read_en_i ? ram_array[word_addr_idx] : 32'hxxxxxxxx;

endmodule