`timescale 1ns / 1ps

`include "defines.vh"

module EX_MEM(
    input wire clk,
    input wire rst,
    input wire[31:0] inst_idex2exmem,
    output reg[31:0] inst_exmem,
    //with rf writeback
    input wire[4:0] wR_i,
    input wire[31:0] pc4_i,
    input wire[31:0] alu_c_i,
    input wire[31:0] imm_i,
    input wire[31:0] pc_i,
    output reg[4:0] wR_o,
    output reg[31:0] pc4_o,
    output reg[31:0] alu_c_o,
    output reg[31:0] imm_o,
    output reg[31:0] pc_o,
    //control signal
    input wire ram_we_i,
    input wire rf_we_i,
    input wire[2:0] rf_wsel_i,
    output reg ram_we_o,
    output reg rf_we_o,
    output reg[2:0] rf_wsel_o,
    //write to dram
    input wire[31:0] rD2_i,
    output reg[31:0] rD2_o
);
    always@(posedge clk or posedge rst)begin
        if(rst)   inst_exmem <= 32'h0000_0000;
        else      inst_exmem <= inst_idex2exmem;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   wR_o <= 5'b00000;
        else      wR_o <= wR_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   pc_o <= 32'h0000_0000;
        else      pc_o <= pc_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   pc4_o <= 32'h0000_0000;
        else      pc4_o <= pc4_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   alu_c_o <= 32'h0000_0000;
        else      alu_c_o <= alu_c_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   imm_o <= 32'h0000_0000;
        else      imm_o <= imm_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   ram_we_o <= 1'b0;
        else      ram_we_o <= ram_we_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rf_we_o <= 1'b0;
        else      rf_we_o <= rf_we_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rf_wsel_o <= 3'b000;
        else      rf_wsel_o <= rf_wsel_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rD2_o <= 32'h0000_0000;
        else      rD2_o <= 32'h0000_0000;
    end
endmodule