`timescale 1ns / 1ps

`include "defines.vh"
module IF_ID(
    input wire clk,
    input wire rst,
    input wire[31:0] inst_i,
    input wire[31:0] pc_i,
    input wire[31:0] pc4_i,
    input wire[3:0] pipline_stop_info,
    input wire pipline_stop,
    output reg[31:0] inst_o,
    output reg[31:0] pc_o,
    output reg[31:0] pc4_o
);
  

    


    always @(posedge clk or posedge rst) begin
        if(rst) pc_o <= 32'h0000_0000;
        else if(pipline_stop) pc_o <= pc_o;
        else    pc_o <= pc_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) pc4_o <= 32'h0000_0000;
        else if(pipline_stop) pc4_o <= pc4_o;
        else    pc4_o <= pc4_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) inst_o <= 32'h0000_0000;
        else if(pipline_stop) inst_o <= inst_o;
        else    inst_o <= inst_i;
    end


endmodule