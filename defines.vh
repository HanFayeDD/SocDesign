// Annotate this macro before synthesis
`define RUN_TRACE


// TODO: 在此处定义你的宏
//alu_op
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLL  4'b0101
`define ALU_SRL  4'b0110
`define ALU_SRA  4'b0111
`define ALU_BNE  4'b1000
`define ALU_BEQ  4'b1001
`define ALU_BLT  4'b1010
`define ALU_BGE  4'b1011


//npc_op
`define NPC_PC4  3'b000
`define NPC_COM  3'b001
`define NPC_JMP  3'b010
`define NPC_JMPR 3'b011

//rf_wsel
`define WB_ALU  3'b000
`define WB_EXT  3'b001
`define WB_DRAM 3'b010
`define WB_PC4  3'b011

//sext_op
`define EXT_NONE 3'b000
`define EXT_I    3'b001
`define EXT_U    3'b010
`define EXT_S    3'b011
`define EXT_B    3'b100
`define EXT_J    3'b101
 
//alu_bsel
`define ALU_RS2 3'b000 
`define ALU_EXT 3'b001


//alu_f
`define COM_YES 1'b1
`define COM_NO  1'b0


// 外设I/O接口电路的端口地�?
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078


//流水线暂停的情况
`define PIP_0STOP      4'b0000
`define PIP_1STOP      4'b1001
`define PIP_2STOP      4'b1010
`define PIP_3STOP      4'b1011


