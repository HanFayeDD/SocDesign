`timescale 1ns / 1ps

`include "defines.vh"
// `include "counter.v"

module ID_EX(
    input wire clk,
    input wire rst,
    input wire[31:0] inst_ifid2idex,
    output reg[31:0] inst_idex2exmem,
    input wire[3:0] pipline_stop_info,
    input wire pipline_stop,
    //控制器信号
    input wire[2:0] npc_op_i,
    input wire ram_we_i,
    input wire[3:0] alu_op_i,
    input wire[2:0] alu_bsel_i,
    input wire rf_we_i,
    input wire[2:0] rf_wsel_i,

    output reg[2:0] npc_op_o,
    output reg ram_we_o,
    output reg[3:0] alu_op_o,
    output reg[2:0] alu_bsel_o,
    output reg rf_we_o,
    output reg[2:0] rf_wsel_o,
    //PC4信号
    input wire[31:0] pc4_i,
    output reg[31:0] pc4_o,
    //pc信号
    input wire[31:0] pc_i,
    output reg[31:0] pc_o,
    //imm立即数字与  RF读出来的两个数字
    input wire[31:0] imm_i,
    input wire[31:0] rD1_i,
    input wire[31:0] rD2_i,
    output reg[31:0] imm_o,
    output reg[31:0] rD1_o,
    output reg[31:0] rD2_o,
    //rf会存入的寄存器编号
    input wire[4:0] wR_i,
    output reg[4:0] wR_o
);
    always@(posedge clk or posedge rst)begin
        if(rst)   inst_idex2exmem <= 32'h0000_0000;
        // else if(pipline_stop)  npc_op_o <= npc_op_o;
        else      inst_idex2exmem <= inst_ifid2idex;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   npc_op_o <= 3'b000;
        // else if(pipline_stop)  npc_op_o <= npc_op_o;
        else      npc_op_o <= npc_op_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   ram_we_o <= 1'b0;
        // else if(pipline_stop)  ram_we_o <= ram_we_o;
        else      ram_we_o <= ram_we_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   alu_op_o <= 4'b0000;
        // else if(pipline_stop)  alu_op_o <= alu_op_o;
        else      alu_op_o <= alu_op_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   alu_bsel_o <= 3'b000;
        // else if(pipline_stop)  alu_bsel_o <= alu_bsel_o;
        else      alu_bsel_o <= alu_bsel_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rf_we_o <= 1'b0;
        // else if(pipline_stop)   rf_we_o <= rf_we_o;
        else      rf_we_o <= rf_we_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rf_wsel_o <= 3'b000;
        // else if(pipline_stop)   rf_wsel_o <= rf_we_o;
        else      rf_wsel_o <= rf_wsel_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   pc4_o <= 32'h0000_0000;
        // else if(pipline_stop)   pc4_o <= pc4_o;
        else      pc4_o <= pc4_i;
    end
    always@(posedge clk or posedge rst)begin
        if(rst)   pc_o <= 32'h0000_0000;
        // else if(pipline_stop)   pc_o <= pc_o;
        else      pc_o <= pc_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   imm_o <= 32'h0000_0000;
        // else if(pipline_stop)  imm_o <= imm_o;
        else      imm_o <= imm_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rD1_o <= 32'h0000_0000;
        // else if(pipline_stop)  rD1_o <= rD1_o;
        else      rD1_o <= rD1_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   rD2_o <= 32'h0000_0000;
        // else if(pipline_stop)  rD2_o <= rD2_o;
        else      rD2_o <= rD2_i;
    end

    always@(posedge clk or posedge rst)begin
        if(rst)   wR_o <= 5'b00000;
        // else if(pipline_stop)  wR_o <= wR_o;
        else      wR_o <= wR_i;
    end

endmodule