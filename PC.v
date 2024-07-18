`timescale 1ns / 1ps

`include "defines.vh"

module PC(
    input wire clk_pc,
    input wire rst_pc,
    input wire[31:0] din,
    output reg[31:0] pc
);
    reg first;
    always @(posedge clk_pc or posedge rst_pc) begin
        if (rst_pc)begin
            pc <= 32'b0000_0000;
            first <= 1'b0;
        end
        else begin
            if(first==1'b0)begin
                pc <= 32'b0000_0000;
                first <= 1'b1;
            end
            else begin
                pc <= din;
            end
        end
    end
endmodule