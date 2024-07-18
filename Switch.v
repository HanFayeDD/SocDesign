`timescale 1ns / 1ps

`include "defines.vh"

module Switch(
    input wire[23:0] sw_from_soc,
    input wire rst_from_bg,
    input wire clk_from_bg,
    input wire[31:0] addr_from_bg,
    output reg[31:0] rdata_to_bg
);
    always@(*)begin
        rdata_to_bg = {8'h00, sw_from_soc};
    end
endmodule
