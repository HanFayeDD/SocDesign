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

    parameter REFRESH_END = 2000-1;//计数值
    parameter REFESH_WIDTH = 20;   //cnt信号的位宽
    wire cnt_end_led;
    counter #(REFRESH_END, REFESH_WIDTH) u_dig_counter(.clk(clk_from_bg),
                                                       .rst(rst_from_bg),
                                                       .cnt_inc(1'b1),
                                                       .cnt_end(cnt_end_led),
                                                       .cnt());
    

    //8个dig选择信号
    always@(posedge clk_from_bg or posedge rst_from_bg)begin
        if(rst_from_bg) dig_en_2_soc <= 8'hff;
        else if(dig_en_2_soc==8'hff) dig_en_2_soc <= 8'b1111_1110;
        else if(cnt_end_led) dig_en_2_soc <= {dig_en_2_soc[6:0], dig_en_2_soc[7]};
        else dig_en_2_soc <= dig_en_2_soc;
    end
endmodule