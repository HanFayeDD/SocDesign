`timescale 1ns / 1ps

`include "defines.vh"

module hazard_data(
    input clk,
    input rst,
    input wire[4:0] inst_rs1,//源寄存器1  
    input wire[4:0] inst_rs2,//源寄存器2
    input wire[31:0] inst,
    //!!!可能不仅仅要判断源寄存器，万一立即数也这是源寄存器呢
    input wire[4:0] ifid_rd_o, //差一个时钟周期 
    input wire id_rf_we,      
    input wire[4:0] idex_rd_o, //差两个时钟周期
    input wire ex_rf_we,
    input wire[4:0] exmem_rd_o, //差三个时钟周期
    input wire mem_rf_we,
    output reg[3:0] pipline_stop_info,//几种不同的暂停情况
    output reg pipline_stop
);  
    //????jal的默认寄存器x0不会发生数据冒险，可以优化，但似乎没影响
    wire inst_rs1_read; //是否要从rs1中读数据
    wire inst_rs2_read; //是否要从rs2中读数据
    wire[6:0] opcode = inst[6:0];
    //TODO  完善其他指令
    assign inst_rs1_read = (opcode==7'b011_0011) || (opcode==7'b001_0011) || (opcode==7'b110_0011) || (opcode==7'b000_0011) || (opcode==7'b110_0111) || (opcode==7'b010_0011);
    assign inst_rs2_read = (opcode==7'b011_0011) || (opcode==7'b110_0011) || (opcode==7'b010_0011);

    // always@(*)begin
    //     case (inst[6:0])
    //         7'b011_0011: begin//R指令两个都读
    //             inst_rs1_read = 1'b1;
    //             inst_rs2_read = 1'b1;
    //         end 
    //         7'b001_0011: begin//I型指令读一个 (lw和jalr之外)
    //             inst_rs1_read = 1'b1; 
    //             inst_rs2_read = 1'b0;
    //         end
    //         7'b000_0011: begin //lw指令
    //             inst_rs1_read = 1'b1;
    //             inst_rs2_read = 1'b0;
    //         end
    //         7'b010_0011: begin
    //             inst_rs1_read = 1'b1;
    //             inst_rs1_read = 1'b1;
    //         end
    //         7'b110_0111: begin //jalr指令
    //             inst_rs1_read = 1'b1;
    //             inst_rs2_read = 1'b0;
    //         end
    //         7'b110_0011: begin //B型指令
    //             inst_rs1_read = 1'b1;
    //             inst_rs2_read = 1'b1;
    //         end
    //         7'b011_0111: begin //lui指令
    //             inst_rs1_read = 1'b0;
    //             inst_rs2_read = 1'b0;
    //         end
    //         7'b110_1111: begin //jal指令
    //             inst_rs1_read = 1'b0;
    //             inst_rs2_read = 1'b0;
    //         end
    //         default: begin
    //             inst_rs1_read = 1'b0;
    //             inst_rs2_read = 1'b0;
    //         end 
    //     endcase
    // end

    wire rawa = (((ifid_rd_o == inst_rs1) && inst_rs1_read && inst_rs1!=5'b00000) || ((ifid_rd_o == inst_rs2) && inst_rs2_read && inst_rs2!=5'b00000))  && id_rf_we;  //read信号不能乱加
    wire rawb = (((idex_rd_o == inst_rs1) && inst_rs1_read && inst_rs1!=5'b00000) || ((idex_rd_o == inst_rs2) && inst_rs2_read && inst_rs2!=5'b00000))  && ex_rf_we;
    wire rawc = (((exmem_rd_o == inst_rs1) && inst_rs1_read  && inst_rs1!=5'b00000) || ((exmem_rd_o == inst_rs2) && inst_rs2_read && inst_rs2!=5'b00000)) && mem_rf_we;
    //RAW_A  前面的指令占据的流水线寄存继续（靠后阶段的寄存器继续跑），
    //后面的指令占据的流水线寄存器暂停（前面阶段的寄存器暂停），
    //!!不能用时序逻辑，得在时钟上升沿读之前就判断
    always @(*) begin
        if(rawa)      pipline_stop_info = `PIP_3STOP;
        else if(rawb) pipline_stop_info = `PIP_2STOP;
        else if(rawc) pipline_stop_info = `PIP_1STOP;
        else          pipline_stop_info = `PIP_0STOP;
    end

    wire[2:0] raw_abc_wire = {rawa, rawb, rawc};
    reg[2:0] raw_abc_reg;
    reg saved;
    always@(negedge clk or posedge rst) begin
        if(rst) begin
            raw_abc_reg <= 3'b000;
        end
        else if(raw_abc_wire != 3'b000 && saved==1'b0)begin //save为0表示可以开始处理新的冒险
            raw_abc_reg <= raw_abc_wire;
        end
        else if(raw_abc_wire == 3'b000)begin
            raw_abc_reg <= raw_abc_wire;
        end
        else begin
            raw_abc_reg <= raw_abc_reg;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            saved <= 1'b0;
        end
        else if(pipline_stop) begin
            saved <= 1'b1;
        end
        else if(!pipline_stop) begin
            saved <= 1'b0;
        end
        else begin
            saved <= saved;
        end
    end


    always @(*) begin
        case (raw_abc_reg)
            3'b100: pipline_stop = s3_reg;
            3'b110: pipline_stop = s3_reg;
            3'b101: pipline_stop = s3_reg;
            3'b111: pipline_stop = s3_reg;
            3'b010: pipline_stop = s2_reg;
            3'b011: pipline_stop = s2_reg;
            3'b001: pipline_stop = s1_reg; 
            default: pipline_stop = 1'b0; 
        endcase
    end

    reg s3_reg;
    reg[1:0] s3_cnt;
    reg s3_flag;
    always@(negedge clk or posedge rst)begin
        if(rst) begin
            s3_reg <= 1'b0;
            s3_cnt <= 2'b0;
            s3_flag <= 1'b0;
        end
        else begin
            if(rawa==1'b1 && s3_flag==1'b0) begin //a, b, c, d考虑011
                s3_cnt <= 2'b11-1;
                s3_reg <= 1'b1;
                s3_flag <= 1'b1;
            end
            else if(raw_abc_wire == 3'b000) begin
                s3_cnt <= 2'b0;
                s3_flag <= 1'b0;
                s3_reg <= 1'b0;
            end
            else if(s3_cnt!=2'b00) begin
                s3_cnt <= s3_cnt - 1;
                s3_reg <= 1'b1;
            end
            else begin
                s3_reg <= 1'b0;
                s3_flag <= 1'b0;
            end
        end
    end

    reg s2_reg;
    reg[1:0] s2_cnt;
    reg s2_flag;
    always@(negedge clk or posedge rst)begin
        if(rst) begin
            s2_reg <= 1'b0;
            s2_cnt <= 2'b0;
            s2_flag <= 1'b0;
        end
        else begin
            if(rawa==1'b0 && rawb==1'b1 && rawb && s2_flag==1'b0) begin
                s2_cnt <= 2'b10-1;
                s2_reg <= 1'b1;
                s2_flag <= 1'b1;
            end
            else if(raw_abc_wire == 3'b000) begin
                s2_cnt <= 2'b0;
                s2_flag <= 1'b0;
                s2_reg <= 1'b0;
            end
            else if(s2_cnt!=2'b00) begin
                s2_cnt <= s2_cnt - 1;
                s2_reg <= 1'b1;
            end
            else begin
                s2_reg <= 1'b0;
                s2_flag <= 1'b0;
            end
        end
    end

    reg s1_reg;
    reg[1:0] s1_cnt;
    reg s1_flag;
    always@(negedge clk or posedge rst)begin
        if(rst) begin
            s1_reg <= 1'b0;
            s1_cnt <= 2'b0;
            s1_flag <= 1'b0;
        end
        else begin
            if(rawa == 1'b0 &&  rawb==1'b0 && rawc==1'b1 && s1_flag==1'b0) begin
                s1_cnt <= 2'b00;
                s1_reg <= 1'b1;
                s1_flag <= 1'b1;
            end
            else if(raw_abc_wire == 3'b000) begin
                s1_cnt <= 2'b0;
                s1_flag <= 1'b0;
                s1_reg <= 1'b0;
            end
            else if(s1_cnt!=2'b00) begin
                s1_cnt <= s1_cnt - 1;
                s1_reg <= 1'b1;
            end
            else begin
                s1_reg <= 1'b0;
                s1_flag <= 1'b0;
            end
        end
    end


endmodule