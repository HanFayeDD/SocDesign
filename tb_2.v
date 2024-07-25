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
    $dumpfile("tb_2.vcd");
    $dumpvars;
end 

initial begin
    cpu_clk = 0;
end

always #1 cpu_clk = ~cpu_clk;

//数据冒险隔一条指令
// addi x1, x0, 9
// sub x10, x5, x6
// addi x2, x1, 3
// 00900093
// 40628533
// 00308113

initial
begin
    cpu_rst = 1;inst = 32'h0000_0000;
    #2
    cpu_rst =0;
    #1.1
    inst = 32'h00900093;
    #2
    inst = 32'h40628533;
    #2 
    inst = 32'h00308113;
    #20
    $finish;
end


endmodule