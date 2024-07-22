`timescale 1ns / 1ps

`include "defines.vh"

module RF(
    input wire[4:0] rR1,
    input wire[4:0] rR2,
    input wire[4:0] wR,
    input wire clk,
    input wire rst,
    input wire we,
    //以下是wD相关信号，多路�?�择�?
    input wire[31:0] pc4,
    input wire[31:0] sext,
    input wire[31:0] alu_c,
    input wire[31:0] dram_rdo,
    input wire[2:0] rf_wsel,
    //以下是输出信�?
    output reg[31:0] rD1,
    output reg[31:0] rD2,
    output reg[31:0] debug_wb_value_rf
);

    reg[31:0] selected;
    always@(*)begin
        case (rf_wsel)
            `WB_ALU: selected = alu_c;
            `WB_EXT: selected = sext;
            `WB_DRAM:selected = dram_rdo;
            `WB_PC4: selected = pc4;
            default: selected = alu_c;
        endcase
    end

    always @(*) begin
        debug_wb_value_rf = selected;
    end

    //异步�?
    always @(*) begin
        rD1 = register[rR1];
        rD2 = register[rR2];
    end


    //同步�?
    reg[31:0] register[31:0];
    always @(posedge clk or posedge rst)begin
        if(rst)begin
            for(integer i=0; i<32; i = i+1)begin
                register[i] <= 32'b0;
            end
        end
        else if(we) begin
            if(wR!=5'b00000) begin 
                register[wR] <= selected;
            end
        end
    end




endmodule