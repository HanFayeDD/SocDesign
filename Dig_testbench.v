`timescale 1ns / 1ps
`include "Dig.v"
`include "defines.vh"
`include "counter.v"
module Dig_testbench();

    reg clk;
    reg rst;
    reg [31:0]addr;
    reg we;
    reg [31:0]wdata;
    wire[7:0] en;
    wire[7:0] duan;

    Dig u_dig(
        .clk_from_bg(clk),
        .rst_from_bg(rst),
        .addr_from_bg(addr),
        .we_from_bg(we),
        .wdata_from_bg(wdata),
        .dig_en_2_soc(en),
        .dig_DN_2_soc(duan)
    );

    always #1 clk = ~clk;

    initial 
    begin
        $dumpfile("Dig_testbench.vcd");
        $dumpvars;
    end

    initial
    begin
        clk = 0;
    end

    initial begin
    rst = 1'b1;
    we = 1'b0;
    #2;
    rst = 1'b0;
    #2
    we = 1'b1;
    wdata = 32'h1234_6789;
    #2
    we = 1'b0;
    #200;
    #2
    we = 1'b1;
    wdata = 32'h2222_2222;
    #2
    we = 1'b0;
    #200
    $finish;
    end

endmodule