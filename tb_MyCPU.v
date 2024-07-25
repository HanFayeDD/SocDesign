`timescale 1ns / 1ps
`include "myCPU.v"
`include "defines.vh"

module tb_MyCPU();
    reg cpu_rst; 
    reg cpu_clk;
    reg[31:0] inst;


myCPU u_myCPU(
    .cpu_clk(cpu_clk),
    .cpu_rst(cpu_rst),
    .inst(inst)
);


initial 
begin
    $dumpfile("tb_MyCPU.vcd");
    $dumpvars;
end 

initial begin
    cpu_clk = 0;
end

always #1 cpu_clk = ~cpu_clk;

// addi x1, x0, 1
// addi x2, x0, 2
// addi x3, x0, 3
// sub  x4, x0, x0
// addi x5, x0, 5

initial
begin
    cpu_rst = 1;inst = 32'h0000_0000;
    #2
    cpu_rst =0;
    #1.1
    inst = 32'h00100093;
    #2
    inst = 32'h00200113;
    #2
    inst = 32'h00300193;
    #2
    inst = 32'h40000233;
    #2
    inst = 32'h00500293;
    #20
    $finish;
end


endmodule