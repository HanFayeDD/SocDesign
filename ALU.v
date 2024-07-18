`timescale 1ns / 1ps

`include "defines.vh"

module ALU(
    input wire[31:0] A,
    input wire[3:0] alu_op,
    //选择
    input wire[31:0] rd2,
    input wire[31:0] sext, 
    input wire[2:0] sel,
    //输出信号
    output reg f,
    output reg[31:0] C
);

    reg[31:0] B;
    always@(*) begin
        case (sel)
            `ALU_RS2: B = rd2;
            `ALU_EXT: B = sext; 
            default: B = rd2;
        endcase
    end

    wire signed [31:0] A_sign;
    wire signed [31:0] B_sign;
    assign A_sign = A;
    assign B_sign = B;

    always @(*) begin
        case (alu_op)
            `ALU_ADD:begin
                C = A + B;
            end 
            `ALU_SUB:begin
                C = A - B;
            end
            `ALU_AND:begin
                C = A & B;
            end
            `ALU_OR:begin
                C = A | B;
            end
            `ALU_XOR:begin
                C = A ^ B;
            end
            `ALU_SLL:begin
                C = A << {27'b0, B[4:0]};//确保B是整数，最一般的二进制表示
            end
            `ALU_SRL:begin
                C = A >> {27'b0, B[4:0]};//立即数选低6位这里再选低5位不矛盾
            end
            `ALU_SRA:begin
                C = A_sign >>> {27'b0, B[4:0]};
            end
            `ALU_BNE:begin
                if(A_sign!=B_sign) f = `COM_YES;
                else f = `COM_NO;
            end
            `ALU_BEQ:begin
                if(A_sign==B_sign) f = `COM_YES;
                else f = `COM_NO;
            end
            `ALU_BLT:begin
                if(A_sign<B_sign) f = `COM_YES;
                else f = `COM_NO;
            end
            `ALU_BGE:begin
                if(A_sign>=B_sign) f = `COM_YES;
                else f = `COM_NO;
            end
            default: ;
        endcase
    end
endmodule