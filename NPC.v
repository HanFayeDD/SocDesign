`timescale 1ns / 1ps

`include "defines.vh"

module NPC(
    input wire[31:0] pc,
    input wire[2:0] op,
    input wire br,
    input wire[31:0] offset,
    input wire[31:0] new_npc_alu,
    output reg[31:0] pc4,
    output reg[31:0] npc
);

    always@(*)begin
        pc4 = pc + 4;
    end

    always@(*)begin
        case (op)
            `NPC_PC4: begin
                npc = pc+4;
            end
            `NPC_COM: begin
                if(br==`COM_YES) npc = pc + offset;
                else npc = pc + 4;
            end
            `NPC_JMP:begin
                npc = pc + offset;
            end
            `NPC_JMPR:begin
                npc = {new_npc_alu[31:1], 1'b0};
            end
            default: npc = pc+4; 
        endcase
    end
endmodule