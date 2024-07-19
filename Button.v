`timescale 1ns / 1ps

`include "defines.vh"

module Button(
    input wire[4:0]  button_from_soc,
    input wire clk_from_bg,
    input wire rst_from_bg,
    input wire[31:0] addr_from_bg,
    output reg[31:0] rdata_2_bg
);

    always@(*) begin
        rdata_2_bg = { 27'b0, button_from_soc[4:0]};
    end
endmodule