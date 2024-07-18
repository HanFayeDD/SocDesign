`timescale 1ns / 1ps

`include "defines.vh"
module Led(
    input wire clk_from_bg,
    input wire rst_from_bg,
    input wire[31:0] addr_from_bg,
    input       we_from_bg,
    input wire[31:0] wdata_from_bg,
    output reg[23:0] led_2soc
); 
    //同步写
    always@(posedge clk_from_bg or posedge rst_from_bg)begin
        if(rst_from_bg) begin
            led_2soc <= 24'h00_0000;
        end
        else begin
            if(we_from_bg) begin
                led_2soc <= wdata_from_bg[23:0];
            end 
        end
    end

endmodule