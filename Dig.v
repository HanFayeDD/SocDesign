`timescale 1ns / 1ps

`include "defines.vh"


module Dig(
    input wire clk_from_bg,
    input wire rst_from_bg,
    input wire[31:0] addr_from_bg,
    input wire we_from_bg,
    input wire[31:0] wdata_from_bg,
    output reg[7:0] dig_en_2_soc,
    output reg[7:0] dig_DN_2_soc 
);




endmodule