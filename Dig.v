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

    parameter REFRESH_END = 20000-1;//计数�????
    parameter REFESH_WIDTH = 20;   //cnt信号的位�????
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


    reg[3:0] now_show_number;
    reg[31:0] wdata_from_bg_stored;
    always @(posedge clk_from_bg or posedge rst_from_bg) begin
        if(rst_from_bg) begin
            wdata_from_bg_stored <= 32'h0000_0000;
        end
        else if(we_from_bg) begin
            wdata_from_bg_stored <= wdata_from_bg;
        end
        else begin
            wdata_from_bg_stored <= wdata_from_bg_stored;
        end
    end

    // reg[31:0] test;

    //  always @(*) begin
    //      test = 32'h12345678;
    //  end


    //  always@(*) begin
    //      case (dig_en_2_soc)
    //          8'b1111_1110: now_show_number = test[3:0];
    //          8'b1111_1101: now_show_number = test[7:4];
    //          8'b1111_1011: now_show_number = test[11:8];
    //          8'b1111_0111: now_show_number = test[15:12];
    //          8'b1110_1111: now_show_number = test[19:16];
    //          8'b1101_1111: now_show_number = test[23:20];
    //          8'b1011_1111: now_show_number = test[27:24];
    //          8'b0111_1111: now_show_number = test[31:28];
    //          default: now_show_number = 4'hf;
    //      endcase
    //  end

   always@(*) begin
       case (dig_en_2_soc)
           8'b1111_1110: now_show_number = wdata_from_bg_stored[3:0];
           8'b1111_1101: now_show_number = wdata_from_bg_stored[7:4];
           8'b1111_1011: now_show_number = wdata_from_bg_stored[11:8];
           8'b1111_0111: now_show_number = wdata_from_bg_stored[15:12];
           8'b1110_1111: now_show_number = wdata_from_bg_stored[19:16];
           8'b1101_1111: now_show_number = wdata_from_bg_stored[23:20];
           8'b1011_1111: now_show_number = wdata_from_bg_stored[27:24];
           8'b0111_1111: now_show_number = wdata_from_bg_stored[31:28];
           default: now_show_number = 4'hf;
       endcase
   end


    always@(*) begin
        case (now_show_number)
            4'b0000: dig_DN_2_soc = 8'b1000_0001; //�????7位置低电平有�????data            4'b0001: dig_DN_2_soc = 8'b1100_1111;
            4'b0001: dig_DN_2_soc = 8'b1100_1111;
            4'b0010: dig_DN_2_soc = 8'b1001_0010;
            4'b0011: dig_DN_2_soc = 8'b1000_0110;
            4'b0100: dig_DN_2_soc = 8'b1100_1100;
            4'b0101: dig_DN_2_soc = 8'b1010_0100;
            4'b0110: dig_DN_2_soc = 8'b1010_0000;
            4'b0111 :dig_DN_2_soc = 8'b1000_1111;
            4'b1000: dig_DN_2_soc = 8'b1000_0000;
            4'b1001: dig_DN_2_soc = 8'b1000_0100;
            4'b1010: dig_DN_2_soc = 8'b1000_1000;  //a
            4'b1011: dig_DN_2_soc = 8'b1110_0000;  //b
            4'b1100: dig_DN_2_soc = 8'b1011_0001;  //c
            4'b1101: dig_DN_2_soc = 8'b1100_0010;   //d
            4'b1110: dig_DN_2_soc = 8'b1011_0000;   //e
            4'b1111: dig_DN_2_soc = 8'b1011_1000;
            default: dig_DN_2_soc = 8'b1111_1111;
        endcase
    end


endmodule