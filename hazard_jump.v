`timescale 1ns / 1ps

`include "defines.vh"

module hazard_jump(
    input wire clk,
    input wire rst,
    input wire[31:0] inst,
    output reg pipline_stop_jump
);

    wire[6:0] opcode = inst[6:0];
    wire jump;
    //B、jal、jalr
    assign jump = (opcode==7'b110_0011) || (opcode==7'b110_1111) || (opcode==7'b110_0111);

    always@(*)begin
        pipline_stop_jump = s2_reg;
    end


    //归0后的下一个时钟下降沿已经是新的指令的inst了。
    reg s2_reg;
    reg[1:0] s2_cnt;
    reg s2_flag;
    always@(negedge clk or posedge rst)begin
        if(rst) begin
            s2_reg <= 1'b0;
            s2_cnt <= 2'b0;
            s2_flag <= 1'b0;
        end
        else begin
            if(jump && s2_flag==1'b0) begin
                s2_cnt <= 2'b10-1;
                s2_reg <= 1'b1;
                s2_flag <= 1'b1;
            end
            else if(s2_cnt!=2'b00) begin
                s2_cnt <= s2_cnt - 1;
                s2_reg <= 1'b1;
            end
            else begin
                s2_reg <= 1'b0;
                s2_flag <= 1'b0;
            end
        end
    end



endmodule