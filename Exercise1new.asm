MAIN:
    li   sp, 0x10000            # Initialize stack pointer
    csrrwi zero, 0x300, 0x8     # enable externel interrupt

    lui  s1, 0xFFFFF

    li   a0, 0x12345678         # a0即x10
    ecall                       # Test ecall

TEST:
RAN_BACK_TO_SELECT:
    lw   s0, 0x70(s1)           # Read switches
    sw   s0, 0x60(s1)           # Write LEDs
    andi x10, s0, 0x000000ff    # x10 操作数B
    srli s0, s0, 8
    andi x11, s0, 0x000000ff    # x11 操作数A
    srli s0, s0, 13
    andi x12, s0, 0x00000007    # x12 操作符
    addi x16, x0, 0
    beq x12, x16, OP_NONE
    addi x16, x0, 1
    beq x12, x16, OP_ADD
    addi x16, x0, 2
    beq x12, x16, OP_SUB
    addi x16, x0, 3
    beq x12, x16, OP_MUL
    addi x16, x0, 4
    beq x12, x16, OP_DIV
    addi x16, x0, 5
    beq x12, x16, OP_RAN
    ##增加button外设
    addi x16, x0, 6
    beq  x12, x16, OP_BUTTON
    jal TEST
SHOW:   
	addi s0, x0, 0
	andi x15, x11, 0x0000000f           # x15存入小数部分
	andi x11, x11,0xfffffff0            # 存整数部分
	srli x11, x11, 4
	addi x12, x0, 1000
ZHENGSHU_4_LOOP:
	blt x11, x12, ZHENGSHU_4_LOOP_END   #x11是整数部分
	addi x11, x11, -1000
	addi s0, s0, 0x00000001
	jal ZHENGSHU_4_LOOP
ZHENGSHU_4_LOOP_END:
	slli s0, s0, 4
	addi x12, x0, 100
ZHENGSHU_3_LOOP:
	blt x11, x12, ZHENGSHU_3_LOOP_END   #x11是整数部分
	addi x11, x11, -100
	addi s0, s0, 0x00000001
	jal ZHENGSHU_3_LOOP
ZHENGSHU_3_LOOP_END:
	slli s0, s0, 4
	addi x12, x0, 10
ZHENGSHU_2_LOOP:
	blt x11, x12, ZHENGSHU_2_LOOP_END   #x11是整数部分
	addi x11, x11, -10
	addi s0, s0, 0x00000001
	jal ZHENGSHU_2_LOOP
ZHENGSHU_2_LOOP_END:
	slli s0, s0, 4
	addi x12, x0, 1
ZHENGSHU_1_LOOP:
	blt x11, x12, ZHENGSHU_1_LOOP_END   #x11是整数部分
	addi x11, x11, -1
	addi s0, s0, 00000001
	jal ZHENGSHU_1_LOOP
ZHENGSHU_1_LOOP_END:
	slli s0, s0, 16
	add s0, s0, x15
    sw   s0, 0x00(s1)           # Write 7-seg LEDs
    jal  TEST

OP_NONE:
	add s0, x0, x0
	sw  s0, 0x00(s1)           # Write 7-seg LEDs
    jal TEST
	
OP_ADD:
	andi x12, x11, 0x0000000f  ##A小数部分
	srli x11, x11, 4
	andi x13, x11, 0x0000000f  ##A整数部分
	andi x14, x10, 0x0000000f  ##B小数部分
	srli x10, x10, 4
	andi x15, x10, 0x0000000f  ##B整数部分
	add  x17, x12, x14
	addi x16, x0, 10
	add  x18, x13, x15
	bge x17, x16, OP_ADD_JINWEI
OP_ADD_BACK:
	addi s0, x0, 0
	add s0, s0, x18
	slli s0, s0, 4
	add s0, s0, x17
    add x11, x0, s0
    jal SHOW
	
	
OP_ADD_JINWEI:
	addi x18, x18, 1
	sub x17, x17, x16
	jal OP_ADD_BACK
	

OP_SUB:
	blt x11, x10, OP_SUB_ABBA   # x11是big的数
OP_SUB_ABBA_BACK:
	andi x13, x11, 0x0000000f   # 大的数的低4位
	andi x14, x10, 0x0000000f   # 小的数的低4位
	srli x11, x11, 4
	andi x15, x11, 0x0000000f   # 大的数的高4位
	srli x10, x10, 4
	andi x16, x10, 0x0000000f   # 小的数的高4位
	addi x17, x0, 0             # 结果整数部分
	addi x18, x0, 0		    # 结果小数部分
	blt x13, x14, OP_SUB_JIEWEI
	sub x17, x15, x16
	sub x18, x13, x14
OP_SUB_JIEWEIBACK:                  # 均已计算完成
	addi s0, x0, 0
	add s0, s0, x17
	slli s0, s0, 4
	add s0, s0, x18
	add x11, x0, s0
	jal SHOW
	
		
OP_SUB_ABBA:
	add x16, x0, x11
	add x11, x0, x10
	add x10, x0, x16
	jal OP_SUB_ABBA_BACK

OP_SUB_JIEWEI:
	addi x15, x15, -1
	sub x17, x15, x16
	addi x13, x13, 10
	sub x18, x13, x14
	jal OP_SUB_JIEWEIBACK

OP_MUL:
	addi x16, x0, 1
OP_MUL_LOOP_BACK:
	blt x10, x16, OP_MUL_LOOP_END ## X10>=1就一直循环
	slli x11, x11, 1
	andi x13, x11, 0x0000001f  ##  x13存储小数部分
	addi x17, x0, 10           # x17存储10
	bge x13, x17, OP_MUL_JINWEI
OP_MUL_JINWEI_BACK:
	addi x10, x10, -1
	jal OP_MUL_LOOP_BACK
OP_MUL_LOOP_END:
	add s0, x0, x11
	jal SHOW
	
OP_MUL_JINWEI:
	andi x11, x11, 0xffffffe0
	addi x11, x11, 0x00000010     ##整数部分进位
	addi x13, x13, -10
	add  x11, x11, x13
	jal OP_MUL_JINWEI_BACK
	
OP_DIV:
	addi x16, x0, 1   
OP_DIV_LOOP_BACK:                            #x11存操作数A
	blt x10, x16, OP_DIV_LOOP_END   #X10>=1就一直循环B
	andi x17, x11, 0x00000010       # x17存整数部分最低位
	addi x18, x0, 0x00000010   
	beq x17, x18, OP_DIV_WEI        #整数部分最低位是1
	srli x11, x11, 1
OP_DIV_WEI_BACK:
	addi x10, x10, -1
	jal OP_DIV_LOOP_BACK
OP_DIV_LOOP_END:
	jal SHOW
	
OP_DIV_WEI:
	andi x19, x11, 0x0000000f
	addi x19, x19, 10
	srli x19, x19, 1
	srli x11, x11, 1
	andi x11, x11, 0xfffffff0
	add  x11, x11, x19
	jal OP_DIV_WEI_BACK
	
	

OP_RAN:
	addi x13, x0, 0
	add  x13, x13, x11
	slli x13, x13, 8
	add  x13, x13, x10
	slli x13, x13, 8
	add  x13, x13, x11
	slli x13, x13, 8
	add  x13, x13, x10  ## 生成随机数种子存在x13中
	sw   x13, 0x00(s1)           # Write 7-seg LEDs
RAN_BACK_LOOP:
	andi x14, x13, 0x00000001          ## a0 a1异或
	andi x15, x13, 0x00000002          
	srli x15, x15, 1
	xor   x16, x14, x15                 ## a0异或a1
	lui  x14, 0x00200
	and  x14, x13, x14      
	srli x14, x14, 21
	lui  x15, 0x80000                  ## a21
	and  x15, x13, x15                 ## a31
	srli x15, x15, 31
	xor  x17, x14, x15
	xor  x16, x16, x17                 ##四个异或的结果
	slli x13, x13, 1
	add  x13, x13, x16
        sw   x13, 0x00(s1)           # Write 7-seg LEDs
        lw   s0, 0x70(s1)           # Read switches
	sw   s0, 0x60(s1)           # Write LEDs
        srli s0, s0, 21
        andi x12, s0, 0x00000007    #重新获取操作符
	addi x17, x0, 5
	bne  x12, x17, RAN_BACK_TO_SELECT
	##1s间隔
	addi x28, x0, 0     ##计数器
	addi x29, x0, 0     ##计数标准
	lui  x29, 0x007f2
	addi x29, x29, 0x7ff
COUNT_LOOP:	           
	bge  x28, x29, COUNT_BREAK
 	addi x28, x28, 1
 	jal  COUNT_LOOP
COUNT_BREAK:
	jal RAN_BACK_LOOP
	
OP_BUTTON:
	lw   s0, 0x78(s1)           # Read BUTTON
        addi x16, x0, 0
        bne  s0, x16, BUTTON_1
        addi x13, x0, 0x00000000
        sw   x13, 0x00(s1)
        jal  BUTTON_END
BUTTON_1:
	addi x16, x0, 0x00000001
	bne  s0, x16, BUTTON_2
	addi x13, x0, 0x00000011
	sw   x13, 0x00(s1)
        jal  BUTTON_END
BUTTON_2:
	addi x16, x0, 0x00000002
	bne  s0, x16, BUTTON_3
	addi x13, x0, 0x00000022
	sw   x13, 0x00(s1) 
        jal  BUTTON_END
BUTTON_3:
	addi x16, x0, 0x00000004
	bne  s0, x16, BUTTON_4
	addi x13, x0, 0x00000033
	sw   x13, 0x00(s1)
        jal  BUTTON_END
BUTTON_4:
	addi x16, x0, 0x00000008
	bne  s0, x16, BUTTON_5
	addi x13, x0, 0x00000044
	sw   x13, 0x00(s1)
        jal  BUTTON_END
BUTTON_5:
	addi x16, x0, 0x00000010
	bne  s0, x16, BUTTON_END
	addi x13, x0, 0x00000055
	sw   x13, 0x00(s1)
BUTTON_END:
	jal TEST