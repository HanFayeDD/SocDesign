`timescale 1ns / 1ps

`include "defines.vh"
// `include "ALU.v"
// `include "Controller.v"
// `include "NPC.v"
// `include "PC.v"
// `include "RF.v"
// `include "SEXT.v"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO: 完成你自己的单周期CPU设计
    //DRAM部分
    assign Bus_addr = ALU_C;
    assign Bus_we = Con_ram_we;
    assign Bus_wdata = RF_rD2;
    //NPC部分
    wire[31:0] NPC_pc4;
    wire[31:0] NPC_npc;
    NPC  u_NPC(
        .pc(PC_pc),
        .op(Con_npc_op),
        .br(ALU_f),
        .offset(SEXT_ext),
        .new_npc_alu(ALU_C),
        .pc4(NPC_pc4),
        .npc(NPC_npc)
    );
    //PC
    wire[31:0] PC_pc;
    PC u_PC(
        .clk_pc(cpu_clk),
        .rst_pc(cpu_rst),
        .din(NPC_npc),
        .pc(PC_pc)
    );
    //连接IROM
    assign inst_addr = PC_pc[15:2];


    //Controller
    wire[2:0] Con_sext_op;
    wire[2:0] Con_npc_op;
    wire Con_ram_we;
    wire[3:0] Con_alu_op;
    wire[2:0] Con_alu_bsel;
    wire Con_rf_we;
    wire[2:0] Con_rf_wsel;
    Controller u_Controller(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7(inst[31:25]),
        .sext_op(Con_sext_op),
        .npc_op(Con_npc_op),
        .ram_we(Con_ram_we),
        .alu_op(Con_alu_op),
        .alu_bsel(Con_alu_bsel),
        .rf_we(Con_rf_we),
        .rf_wsel(Con_rf_wsel)
    );

    //sext
    wire[31:0] SEXT_ext;
    SEXT u_SEXT(
        .op(Con_sext_op),
        .din(inst[31:7]),
        .ext(SEXT_ext)
    );

    //RF部分
    wire[31:0] RF_rD1;
    wire[31:0] RF_rD2;
    wire[31:0] debug_wb_value_rf;
    RF u_RF(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .wR(inst[11:7]),
        .we(Con_rf_we),
        .pc4(NPC_pc4),
        .sext(SEXT_ext),
        .alu_c(ALU_C),
        .dram_rdo(Bus_rdata[31:0]),
        .rf_wsel(Con_rf_wsel),
        .rD1(RF_rD1),
        .rD2(RF_rD2),
        .debug_wb_value_rf(debug_wb_value_rf)
    );

    //ALU
    wire ALU_f;
    wire[31:0] ALU_C;
    ALU u_ALU(
        .A(RF_rD1),
        .alu_op(Con_alu_op),
        .sel(Con_alu_bsel),
        .rd2(RF_rD2),
        .sext(SEXT_ext),
        .f(ALU_f),
        .C(ALU_C)
    );


    reg debug_wb_have_inst_reg;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if(cpu_rst)begin
            debug_wb_have_inst_reg <= 1'b1;
        end
        else begin
            debug_wb_have_inst_reg <= 1'b1;
        end
    end
`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = debug_wb_have_inst_reg;
    assign debug_wb_pc        = PC_pc;
    assign debug_wb_ena       = Con_rf_we;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = debug_wb_value_rf;
`endif

endmodule
