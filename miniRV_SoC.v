`timescale 1ns / 1ps

`include "defines.vh"

//记得注释掉这里
`include "ALU.v"
`include "Controller.v"
`include "NPC.v"
`include "PC.v"
`include "RF.v"
`include "SEXT.v"
`include "Switch.v"
`include "myCPU.v"
`include "Bridge.v"
`include "Dig.v"
`include "Led.v"
`include "counter.v"
`include "Button.v"

module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    input  wire [23:0]  sw,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A,
    output wire         DN_B,
    output wire         DN_C,
    output wire         DN_D,
    output wire         DN_E,
    output wire         DN_F,
    output wire         DN_G,
    output wire         DN_DP,
    output wire [23:0]  led

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
`endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // Interface between CPU and IROM
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // Interface between CPU and Bridge
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_we;
    wire [31:0] Bus_wdata;
    
    // Interface between bridge and DRAM
    // wire         rst_bridge2dram;
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         we_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
    
    // Interface between bridge and peripherals
    // TODO: 在此定义总线桥与外设I/O接口电路模块的连接信号
    // Interface between bridge and switch
    wire         clk_bg2sw;
    wire         rst_bg2sw;
    wire [31:0]  addr_bg2sw;
    wire [31:0]  rdata_sw2bg;
    // Interface between bridge and dig
    wire         clk_bg2dig;
    wire         rst_bg2dig;
    wire[31:0]   addr_bg2dig;
    wire         we_bg2dig;
    wire[31:0]   wdata_bg2dig;
    // Interface between bridge and led
    wire         clk_bg2led;
    wire         rst_bg2led;
    wire[31:0]   addr_bg2led;
    wire         we_bg2led;
    wire[31:0]   wdata_bg2led;
    // Interface between bridge and button
    wire rst_bg2but;
    wire clk_bg2but;
    wire[31:0] addr_bg2but;
    wire[31:0] rdata_but2bg;

`ifdef RUN_TRACE
    // Trace调试时，直接使用外部输入时钟
    assign cpu_clk = fpga_clk;
`else
    // 下板时，使用PLL分频后的时钟
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        // .resetn     (!fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        // Interface to IROM
        .inst_addr          (inst_addr),
        .inst               (inst),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_we             (Bus_we),
        .Bus_wdata          (Bus_wdata)

`ifdef RUN_TRACE
        ,// Debug Interface
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    
    Bridge Bridge (       
        // Interface to CPU
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .we_from_cpu        (Bus_we),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // Interface to DRAM
        // .rst_to_dram    (rst_bridge2dram),
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .we_to_dram         (we_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        
        // Interface to 7-seg digital LEDs
        .rst_to_dig         (rst_bg2dig),
        .clk_to_dig         (clk_bg2dig),
        .addr_to_dig        (addr_bg2dig),
        .we_to_dig          (we_bg2dig),
        .wdata_to_dig       (wdata_bg2dig),

        // Interface to LEDs
        .rst_to_led         (rst_bg2led),
        .clk_to_led         (clk_bg2led),
        .addr_to_led        (addr_bg2led),
        .we_to_led          (we_bg2led),
        .wdata_to_led       (wdata_bg2led),

        // Interface to switches
        .rst_to_sw          (rst_bg2sw),
        .clk_to_sw          (clk_bg2sw),
        .addr_to_sw         (addr_bg2sw),
        .rdata_from_sw      (rdata_sw2bg),

        // Interface to buttons
        .rst_to_btn         (rst_bg2but),
        .clk_to_btn         (clk_bg2but),
        .addr_to_btn        (addr_bg2but),
        .rdata_from_btn     (rdata_but2bg)
    );


    //!!!!!!!记得上板子的时候把这里取消注释
    // DRAM Mem_DRAM (
    //     .clk        (clk_bridge2dram),
    //     .a          (addr_bridge2dram[15:2]),
    //     .spo        (rdata_dram2bridge),
    //     .we         (we_bridge2dram),
    //     .d          (wdata_bridge2dram)
    // );
    
    // IROM Mem_IROM (
    //     .a          (inst_addr),
    //     .spo        (inst)
    // );

    // TODO: 在此实例化你的外设I/O接口电路模块
    // 拨码开关
    Switch u_switch(
        .sw_from_soc(sw),
        .rst_from_bg(rst_bg2sw),
        .clk_from_bg(clk_bg2sw),
        .addr_from_bg(addr_bg2sw),
        .rdata_to_bg(rdata_sw2bg)
    );

    Dig u_dig(
        .clk_from_bg(clk_bg2dig),
        .rst_from_bg(rst_bg2dig),
        .addr_from_bg(addr_bg2dig),
        .we_from_bg(we_bg2dig),
        .wdata_from_bg(wdata_bg2dig),
        .dig_en_2_soc(dig_en),//Dig的输出
        .dig_DN_2_soc({DN_DP, DN_A, DN_B, DN_C, //Dig的输出
                        DN_D, DN_E, DN_F, DN_G})
    );

    Led u_led(
        .clk_from_bg(clk_bg2led),
        .rst_from_bg(rst_bg2led),
        .addr_from_bg(addr_bg2led),
        .we_from_bg(we_bg2led),
        .wdata_from_bg(wdata_bg2led),
        .led_2soc(led)
    );

    Button u_button(
        .button_from_soc(button),
        .clk_from_bg(clk_bg2but),
        .rst_from_bg(rst_bg2but),
        .addr_from_bg(addr_bg2but),
        .rdata_2_bg(rdata_but2bg)
    );



endmodule
