module mux #(
    parameter DATA_WIDTH = 32
) (
    input  [DATA_WIDTH-1:0] data0_i,
    input  [DATA_WIDTH-1:0] data1_i,
    input  sel_i,
    output [DATA_WIDTH-1:0] data_o
);

    assign data_o = sel_i ? data1_i : data0_i;

endmodule