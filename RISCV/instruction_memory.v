module instruction_memory #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH_WORDS = 256,
    parameter MEM_FILE = "program/test_program.mem"
) (
    input  [ADDR_WIDTH-1:0] addr_i, // Dirección de palabra
    output [DATA_WIDTH-1:0] instr_o
);

    localparam ADDR_BITS_FOR_DEPTH = $clog2(MEM_DEPTH_WORDS);

    // Memoria ROM (array de registros)
    reg [DATA_WIDTH-1:0] rom_array [0:MEM_DEPTH_WORDS-1];

    // Inicializar la memoria desde un archivo .mem (hexadecimal)
    initial begin
        if (MEM_FILE != "") begin
            $display("Instruction Memory: Initializing from %s", MEM_FILE);
            $readmemh(MEM_FILE, rom_array);
        end
    end

    // Lectura combinacional. El PC está alineado a palabras, así que PC[1:0] son 00.
    // Usamos addr_i >> 2 para obtener el índice de palabra.
    // Asegurar que la dirección no exceda los límites de la ROM.
    wire [ADDR_BITS_FOR_DEPTH-1:0] word_addr;
    assign word_addr = addr_i[ADDR_BITS_FOR_DEPTH+1:2]; // Tomamos los bits relevantes para el índice

    assign instr_o = rom_array[word_addr];

endmodule