`timescale 1ns / 1ps

`include "defines.vh"
// `include "ALU.v"
// `include "Controller.v"
// `include "NPC.v"
// `include "PC.v"
// `include "RF.v"
// `include "SEXT.v"
// `include "IF_ID.v"
// `include "ID_EX.v"
// `include "EX_MEM.v"
// `include "hazard_data.v"
// `include "counter.v"
// `include "hazard_jump.v"

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
    //TODO数据冒险控制:采用停顿
    wire[3:0] pipline_stop_info;
    wire pipline_stop;
    hazard_data u_hazard_data(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst_rs1(inst[19:15]),
        .inst_rs2(inst[24:20]),
        .inst(inst),
        .ifid_rd_o(if_id_inst_o[11:7]),//差一个时钟周期
        .id_rf_we(Con_rf_we),
        .idex_rd_o(idex_wR_o),//2个
        .ex_rf_we(idex_rf_we_o),
        .exmem_rd_o(exmem_wR_o),//3个
        .mem_rf_we(exmem_rf_we_o),
        .pipline_stop(pipline_stop),
        .pipline_stop_info(pipline_stop_info)
    );

    //TODO控制冒险：采用停顿
    wire pipline_stop_jump;
    hazard_jump u_hazard_jump(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst(inst),
        .pipline_stop_jump(pipline_stop_jump)
    );



    // TODO: 完成你自己的单周期CPU设计
    wire[31:0] PC_pc;
    wire[2:0] Con_npc_op;
    wire[31:0] SEXT_ext;
    wire ALU_f;
    wire[31:0] ALU_C;
    //DRAM部分
    assign Bus_addr = exmem_alu_c_o;
    assign Bus_we = exmem_ram_we_o;
    assign Bus_wdata = exmem_rD2_o;
    //NPC部分
    // wire[31:0] NPC_pc4;
    //**尝试把NPC放在ID_EX之后
    wire[31:0] NPC_npc;
    NPC  u_NPC(
        .pc(idex_pc_o),
        .op(idex_npc_op_o),
        .br(ALU_f),
        .offset(idex_imm_o),
        .new_npc_alu(ALU_C),
        .pc4(),
        .npc(NPC_npc)
    );
    //PC
    wire[31:0] PC_pc4;
    PC u_PC(
        .clk_pc(cpu_clk),
        .rst_pc(cpu_rst),
        .pipline_stop(pipline_stop),
        .pipline_stop_jump(pipline_stop_jump),
        .din(NPC_npc),
        .pc(PC_pc),
        .pc4(PC_pc4)
    );
    //连接IROM
    assign inst_addr = PC_pc[15:2];

    //**IF/ID
    wire[31:0] if_id_inst_o;
    wire[31:0] if_id_pc_o;
    wire[31:0] if_id_pc4_o;
    IF_ID u_IF_ID(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst_i(inst),//from irom throught ibus
        .pc_i(PC_pc),
        .pc4_i(PC_pc4),
        .pipline_stop(pipline_stop),
        .pipline_stop_info(pipline_stop_info),
        .inst_o(if_id_inst_o),
        .pc_o(if_id_pc_o),
        .pc4_o(if_id_pc4_o)
    );


    //Controller
    wire[2:0] Con_sext_op;
    wire Con_ram_we;
    wire[3:0] Con_alu_op;
    wire[2:0] Con_alu_bsel;
    wire Con_rf_we;
    wire[2:0] Con_rf_wsel;
    Controller u_Controller(
        .opcode(if_id_inst_o[6:0]),
        .funct3(if_id_inst_o[14:12]),
        .funct7(if_id_inst_o[31:25]),
        .sext_op(Con_sext_op),//不用传到下一阶段
        .npc_op(Con_npc_op),
        .ram_we(Con_ram_we),
        .alu_op(Con_alu_op),
        .alu_bsel(Con_alu_bsel),
        .rf_we(Con_rf_we),
        .rf_wsel(Con_rf_wsel)
    );

    //sext
    SEXT u_SEXT(
        .op(Con_sext_op),
        .din(if_id_inst_o[31:7]),
        .ext(SEXT_ext)
    );

    //RF部分
    wire[31:0] RF_rD1;
    wire[31:0] RF_rD2;
    wire[31:0] debug_wb_value_rf;
    RF u_RF(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .rR1(if_id_inst_o[19:15]),
        .rR2(if_id_inst_o[24:20]),
        .wR(exmem_wR_o),
        .we(exmem_rf_we_o),
        .pc4(exmem_pc4_o),
        .sext(exmem_imm_o),
        .alu_c(exmem_alu_c_o),
        .dram_rdo(Bus_rdata[31:0]),
        .rf_wsel(exmen_rf_wsel_o),
        .rD1(RF_rD1),
        .rD2(RF_rD2),
        .debug_wb_value_rf(debug_wb_value_rf)
    );

    //**ID_EX
    wire[2:0] idex_npc_op_o;
    wire idex_ram_we_o;
    wire[3:0] idex_alu_op_o;
    wire[2:0] idex_alu_bsel_o;
    wire idex_rf_we_o;
    wire[2:0] idex_rf_wsel_o;
    wire[31:0] idex_pc4_o;
    wire[31:0] idex_imm_o;
    wire[31:0] idex_rD1_o;
    wire[31:0] idex_rD2_o;
    wire[4:0]  idex_wR_o;
    wire[31:0] idex_pc_o;
    wire[31:0] inst_idex2exmem;
    ID_EX u_ID_EX(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst_ifid2idex(if_id_inst_o),
        .inst_idex2exmem(inst_idex2exmem),
        .pipline_stop(pipline_stop),
        .pipline_stop_info(pipline_stop_info),
        //控制器信号输入
        .npc_op_i(Con_npc_op),
        .ram_we_i(Con_ram_we),
        .alu_op_i(Con_alu_op),
        .alu_bsel_i(Con_alu_bsel),
        .rf_we_i(Con_rf_we),
        .rf_wsel_i(Con_rf_wsel),
        //控制器信号输出
        .npc_op_o(idex_npc_op_o),
        .ram_we_o(idex_ram_we_o),
        .alu_op_o(idex_alu_op_o),
        .alu_bsel_o(idex_alu_bsel_o),
        .rf_we_o(idex_rf_we_o),
        .rf_wsel_o(idex_rf_wsel_o),
        //PC4
        .pc4_i(if_id_pc4_o),
        .pc4_o(idex_pc4_o),
        //PC
        .pc_i(if_id_pc_o),
        .pc_o(idex_pc_o),
        //imm 与rf两个读出数据
        .imm_i(SEXT_ext),
        .rD1_i(RF_rD1),
        .rD2_i(RF_rD2),
        .imm_o(idex_imm_o),
        .rD1_o(idex_rD1_o),
        .rD2_o(idex_rD2_o),
        //rf会存入的寄存器的编号
        .wR_i(if_id_inst_o[11:7]),
        .wR_o(idex_wR_o)
    );



    //ALU
    ALU u_ALU(
        .A(idex_rD1_o),
        .alu_op(idex_alu_op_o),
        .sel(idex_alu_bsel_o),
        .rd2(idex_rD2_o),
        .sext(idex_imm_o),
        .f(ALU_f),
        .C(ALU_C)
    );

    //**EX_MEM
    wire[4:0] exmem_wR_o;
    wire[31:0] exmem_pc_o;
    wire[31:0] exmem_pc4_o;
    wire[31:0] exmem_alu_c_o;
    wire[31:0] exmem_imm_o;
    wire exmem_ram_we_o;
    wire exmem_rf_we_o;
    wire[2:0] exmen_rf_wsel_o;
    wire[31:0] exmem_rD2_o;
    wire[31:0] inst_exmem;
    EX_MEM u_EX_MEM(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst_idex2exmem(inst_idex2exmem),
        .inst_exmem(inst_exmem),
        //wb to rf
        .wR_i(idex_wR_o),
        .pc4_i(idex_pc4_o),
        .pc4_o(exmem_pc4_o),
        .alu_c_i(ALU_C),
        .imm_i(idex_imm_o),
        .wR_o(exmem_wR_o),
        .alu_c_o(exmem_alu_c_o),
        .imm_o(exmem_imm_o),
        .pc_i(idex_pc_o),
        .pc_o(exmem_pc_o),
        //control signal
        .ram_we_i(idex_ram_we_o),
        .rf_we_i(idex_rf_we_o),
        .rf_wsel_i(idex_rf_wsel_o),
        .ram_we_o(exmem_ram_we_o),
        .rf_we_o(exmem_rf_we_o),
        .rf_wsel_o(exmen_rf_wsel_o),
        //wirte to dram
        .rD2_i(idex_rD2_o),
        .rD2_o(exmem_rD2_o)
    );

    wire debug_have_inst = (inst_exmem[6:0] != 7'b000_0000);
    reg d1;
    reg first;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if(cpu_rst) begin 
            d1 <= 1'b0;
            first <= 1'b0;
        end
        else if(d1==1'b1) begin
            d1 <= 1'b0;
        end
        else if(debug_have_inst && first==1'b0)  begin
            d1 <= 1'b1;
            first <= 1'b1;
        end
        else begin
            d1 <= d1;
            first <= first;
        end
    end

    reg d2;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if(cpu_rst) begin
            d2 <= 1'b0;
        end
        else begin
            if(exmem_pc_o != idex_pc_o)begin
                d2 <= 1'b1;
            end
            else begin
                d2 <= 1'b0;
            end
        end
    end

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = d1 ||  d2;   //debug_wb_have_inst_reg;
    assign debug_wb_pc        = exmem_pc_o;
    assign debug_wb_ena       = exmem_rf_we_o;
    assign debug_wb_reg       = exmem_wR_o;
    assign debug_wb_value     = debug_wb_value_rf;
`endif

endmodule
