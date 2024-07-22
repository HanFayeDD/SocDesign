`timescale 1ns / 1ps
`include "ALU.v"
`include "defines.vh"

module ALU_testbench();
    
// ALU Inputs
reg [31:0] A         ;
reg [3:0] alu_op     ;
reg [31:0] rd2       ;
reg [31:0] sext      ;
reg [2:0] sel        ;

// ALU Outputs
wire  f;
wire  [31:0] C;


ALU  u_ALU (
    .A(A),
    .alu_op       (alu_op),
    .rd2          (rd2),
    .sext         (sext),
    .sel          (sel),
    .f            (f),
    .C            (C)
);



initial 
begin
    $dumpfile("ALU_testbench.vcd");
    $dumpvars;
end

initial
begin
    //ADD
    A = 32'b00111; rd2 = 32'b00001; sel = `ALU_RS2; alu_op = `ALU_ADD;
    #10
    //SRL
    A = 32'b00111; rd2 = 32'b00001; sel = `ALU_RS2; alu_op = `ALU_SRL;
    #10
    //SLL
    A = 32'b00111; rd2 = 32'b00001; sel = `ALU_RS2; alu_op = `ALU_SLL;
    #10
    //SRA
    A[30:0] = 32'b00111; A[31] = 1'b1; rd2 = 32'b00001; sel = `ALU_RS2; alu_op = `ALU_SRA;
    #10
    $finish;
end


endmodule