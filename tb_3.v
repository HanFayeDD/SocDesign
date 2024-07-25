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
    $dumpfile("tb_3.vcd");
    $dumpvars;
end 

initial begin
    cpu_clk = 0;
end

always #1 cpu_clk = ~cpu_clk;


// addi x1,  x0, 2
// sub  x2,  x1, x1


initial
begin
    cpu_rst = 1;inst = 32'h0000_0000;
    #2
    cpu_rst =0;
    #1.1
    inst = 32'h00200093;
    #2
    inst = 32'h40108133;
    #20
    $finish;
end


endmodule