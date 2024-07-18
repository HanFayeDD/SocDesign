`timescale 1ns / 1ps

`include "defines.vh"
module Controller(
    input wire[6:0] opcode,
    input wire[2:0] funct3,
    input wire[6:0] funct7,
    output reg[2:0] sext_op,
    output reg[2:0] npc_op,
    output reg ram_we,
    output reg[3:0] alu_op,
    output reg[2:0] alu_bsel,
    output reg rf_we,
    output reg[2:0] rf_wsel
);

    wire r_type = (opcode==7'b011_0011) ? 1'b1 : 1'b0;//8
    wire inst_add = r_type & (funct3==3'b000) & (funct7[5]==1'b0);
    wire inst_sub = r_type & (funct3==3'b000) & (funct7[5]==1'b1);
    wire inst_xor = r_type & (funct3==3'b100);
    wire inst_or  = r_type & (funct3==3'b110);
    wire inst_and = r_type & (funct3==3'b111);
    wire inst_sll = r_type & (funct3==3'b001);
    wire inst_srl = r_type & (funct3==3'b101) & (funct7[5]==1'b0);
    wire inst_sra = r_type & (funct3==3'b101) & (funct7[5]==1'b1);

    wire i_type = (opcode==7'b001_0011) ? 1'b1 : 1'b0;
    wire inst_addi = i_type & (funct3==3'b000);
    wire ints_xori = i_type & (funct3==3'b100);
    wire inst_ori  = i_type & (funct3==3'b110);
    wire inst_andi = i_type & (funct3==3'b111);
    wire inst_slli = i_type & (funct3==3'b001);
    wire inst_srli = i_type & (funct3==3'b101) & (funct7[5]==1'b0);
    wire inst_srai = i_type & (funct3==3'b101) & (funct7[5]==1'b1);

    wire i_type_jalr = (opcode==7'b110_0111);
    wire inst_jalr = i_type_jalr & (funct3==3'b000);

    wire i_type_lw = (opcode==7'b000_0011);
    wire inst_lw = i_type_lw & (funct3==3'b010);

    wire s_type = (opcode==7'b010_0011);//只有sw
    wire inst_sw = s_type & (funct3==3'b010);

    wire b_type = (opcode==7'b110_0011);
    wire inst_beq = b_type & (funct3==3'b000);
    wire inst_bne = b_type & (funct3==3'b001);
    wire inst_blt = b_type & (funct3==3'b100);
    wire inst_bge = b_type & (funct3==3'b101);

    wire u_type = (opcode==7'b011_0111);
    wire inst_lui = u_type;

    wire j_type = (opcode==7'b110_1111);
    wire inst_jal = j_type;

    always @(*) begin
        if(r_type)      sext_op = `EXT_NONE;
        else if(i_type) sext_op = `EXT_I;
        else if(s_type) sext_op = `EXT_S;
        else if(b_type) sext_op = `EXT_B;
        else if(u_type) sext_op = `EXT_U;
        else if(j_type) sext_op = `EXT_J;
        else if(i_type_jalr) sext_op = `EXT_I;//???拓展方式跟i的其他是否一样
        else if(i_type_lw)   sext_op = `EXT_I;//??同上
    end

    always @(*) begin
        if(r_type)      npc_op = `NPC_PC4;
        else if(i_type) npc_op = `NPC_PC4;
        else if(s_type) npc_op = `NPC_PC4;
        else if(b_type) npc_op = `NPC_COM;
        else if(u_type) npc_op = `NPC_PC4;
        else if(j_type) npc_op = `NPC_JMP;
        else if(i_type_jalr) npc_op = `NPC_JMPR;
        else if(i_type_lw) npc_op = `NPC_PC4;
    end

    always @(*) begin
        if(r_type)      ram_we = 1'b0;
        else if(i_type) ram_we = 1'b0;
        else if(s_type) ram_we = 1'b1;
        else if(b_type) ram_we = 1'b0;
        else if(u_type) ram_we = 1'b0;
        else if(j_type) ram_we = 1'b0;
        else if(i_type_jalr) ram_we = 1'b0;
        else if(i_type_lw)   ram_we = 1'b0;
    end

    always @(*) begin
        if(r_type)       alu_bsel = `ALU_RS2;
        else if(i_type)  alu_bsel = `ALU_EXT;
        else if(s_type)  alu_bsel = `ALU_EXT;
        else if(b_type)  alu_bsel = `ALU_RS2;
        else if(u_type)  alu_bsel = `ALU_RS2;//随便一个
        else if(j_type)  alu_bsel = `ALU_RS2;//随便一个
        else if(i_type_jalr) alu_bsel = `ALU_EXT;
        else if(i_type_lw) alu_bsel = `ALU_EXT;
    end
    
    always @(*) begin
        if(inst_add | inst_addi)       alu_op = `ALU_ADD;
        else if(inst_and | inst_andi)  alu_op = `ALU_AND;
        else if(inst_or | inst_ori)    alu_op = `ALU_OR;
        else if(inst_xor | ints_xori)  alu_op = `ALU_XOR;
        else if(inst_sub)              alu_op = `ALU_SUB;//!!!待定
        else if(inst_sll | inst_slli)  alu_op = `ALU_SLL;
        else if(inst_srl | inst_srli)  alu_op = `ALU_SRL;
        else if(inst_sra | inst_srai)  alu_op = `ALU_SRA;
        else if(inst_sw)               alu_op = `ALU_ADD;
        else if(inst_beq)              alu_op = `ALU_BEQ;
        else if(inst_bne)              alu_op = `ALU_BNE;
        else if(inst_blt)              alu_op = `ALU_BLT;
        else if(inst_bge)              alu_op = `ALU_BGE;
        else if(inst_lui)              alu_op = `ALU_ADD;//不需要alu操作
        else if(inst_jal)              alu_op = `ALU_ADD;//不需要alu操作
        else if(inst_jalr)             alu_op = `ALU_ADD;
        else if(inst_lw)               alu_op = `ALU_ADD;
    end

    always @(*) begin
        if(r_type)       rf_we = 1'b1;
        else if(i_type)  rf_we = 1'b1;    
        else if(s_type)  rf_we = 1'b0;
        else if(b_type)  rf_we = 1'b0;
        else if(u_type)  rf_we = 1'b1;
        else if(j_type)  rf_we = 1'b1;
        else if(i_type_jalr) rf_we = 1'b1;
        else if(i_type_lw)   rf_we = 1'b1;
        else begin
            rf_we = 1'b0;
        end
    end

    always @(*) begin
        if(r_type)       rf_wsel = `WB_ALU;
        else if(i_type)  rf_wsel = `WB_ALU;
        else if(s_type)  rf_wsel = `WB_ALU;//不用写入rf
        else if(b_type)  rf_wsel = `WB_ALU;//不用写入rf
        else if(u_type)  rf_wsel = `WB_EXT; 
        else if(j_type)  rf_wsel = `WB_PC4;
        else if(i_type_jalr) rf_wsel = `WB_PC4;
        else if(i_type_lw) rf_wsel = `WB_DRAM;
    end

endmodule