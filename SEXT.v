`timescale 1ns / 1ps

`include "defines.vh"

module SEXT(
    input wire[2:0] op,
    input wire[24:0] din,
    output reg[31:0] ext 
);

    wire shamt_judge = (din[7:5]==3'b001 | din[7:5]==3'b101);
    
    always @(*) begin
        case (op)
            `EXT_NONE:begin
                ext = 32'hFFFF_FFFF;
            end
            `EXT_I:begin //jalr和lw也是i型指令
                if (shamt_judge==1'b0) ext = {{21{din[24]}}, din[23:13]};// 21+11
                else                   ext = {26'b0, din[18:13]}; //26+6
            end
            `EXT_S:begin
                ext = {{21{din[24]}}, din[23:18], din[4:0]};//21 + 6 + 5
            end
            `EXT_B:begin//PC相对寻址：将立即数字段作为相对PC的补码偏移量
                ext = {{20{din[24]}},  din[0], din[23:18], din[4:1], 1'b0};//20+1+6+4+1
            end
            `EXT_U:begin
                ext = {din[24:5], {12{1'b0}}};//20+12
            end
            `EXT_J:begin
                ext = {{12{din[24]}}, din[12:5], din[13], din[23:14], 1'b0};//12+8+1+10+1
            end
            default: ext = 32'hFFFF_FFFF;
        endcase
    end


endmodule
