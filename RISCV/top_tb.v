`timescale 1ns / 1ps

module top_tb;

    // Parámetros
    localparam CLK_PERIOD      = 10; // ns, para 100 MHz
    localparam SIM_CYCLES      = 30; // Cuántos ciclos correr después del reset
    localparam IMEM_FILE_TB    = "../program/test_program.mem"; // Ruta al programa
    localparam PC_RESET_VECTOR = 32'h00000000;

    // Señales del Testbench
    reg clk_tb;
    reg rst_n_tb;

    // Instancia del DUT (Device Under Test)
    top #(
        .IMEM_FILE(IMEM_FILE_TB),
        .PC_RESET_VECTOR(PC_RESET_VECTOR)
    ) u_riscv_cpu (
        .clk_i(clk_tb),
        .rst_n_i(rst_n_tb)
    );

    // 1. Generador de Reloj
    initial begin
        clk_tb = 0;
        forever #(CLK_PERIOD / 2) clk_tb = ~clk_tb;
    end

    // 2. Secuencia de Reset y Ejecución
    initial begin
        $display("Testbench Simple: Iniciando simulación...");

        // Aplicar Reset
        rst_n_tb = 0; // Reset activo bajo
        #(CLK_PERIOD * 5); // Mantener reset por 5 ciclos

        // Liberar Reset
        rst_n_tb = 1;
        $display("[%0t ns] Testbench Simple: Reset liberado.", $time);

        // Dejar correr la simulación
        #(CLK_PERIOD * SIM_CYCLES);

        $display("[%0t ns] Testbench Simple: Simulación finalizada después de %0d ciclos.", $time, SIM_CYCLES);
        $stop;
    end

endmodule