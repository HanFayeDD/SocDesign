`timescale 1ns / 1ps

`include "defines.vh"

module PC(
    input wire clk_pc,
    input wire rst_pc,
    input wire pipline_stop,
    input wire pipline_stop_jump,
    input wire[31:0] din,
    output reg[31:0] pc,
    output reg[31:0] pc4
);
    // reg first;
    // always @(posedge clk_pc or posedge rst_pc) begin
    //     if (rst_pc)begin
    //         pc <= 32'b0000_0000;
    //         first <= 1'b0;
    //     end
    //     else begin
    //         if(first==1'b0)begin
    //             pc <= 32'b0000_0000;
    //             first <= 1'b1;
    //         end
    //         else begin
    //             pc <= din;
    //         end
    //     end
    // end

    // always@(*)begin
    //     pc4 = pc + 4;
    // end

    reg first_after_jump;
    always @(posedge clk_pc or posedge rst_pc) begin
        if(rst_pc)begin
            first_after_jump <= 1'b0;
        end
        else begin
            if(pipline_stop_jump) begin
                first_after_jump <= 1'b1;
            end
            else if(!pipline_stop_jump) begin
                first_after_jump <= 1'b0;
            end
            else begin
                first_after_jump <= first_after_jump;
            end
        end
    end


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
            else if(pipline_stop_jump)begin
                pc <= pc;
            end
            else if(first_after_jump) begin
                pc <= din;
            end
            else if(pipline_stop) begin
                pc <= pc;
            end
            else begin
                pc <= pc+4;
            end
        end
    end


    always@(*)begin
        pc4 = pc + 4;
    end
endmodule