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
    $dumpfile("jump_beq.vcd");
    $dumpvars;
end 

initial begin
    cpu_clk = 0;
end

always #1 cpu_clk = ~cpu_clk;

//beq
// 	beq x0, x0, JUMP
// 	addi x4, x0, 4
// JUMP:
// 	addi x1, x0, 1
// 	addi x2, x0, 2
// 	addi x3, x0, 3
// 00000463
// 00400213
// 00100093
// 00200113
// 00300193


initial
begin
    cpu_rst = 1;inst = 32'h0000_0000;
    #2
    cpu_rst =0;
    #1.1
    inst = 32'h00000463;
    #6
    inst = 32'h00100093;
    #2 
    inst = 32'h00200113;
    #2
    inst = 32'h00300193;
    #20
    $finish;
end


endmodule