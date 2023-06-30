`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 20:14:05
// Design Name: 
// Module Name: id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//ID模块
//对指令进行译码，得到最终运算的类型、子类型、源操作数1、源操作数2、要写入的目的寄存器地址等信息
`include "defines.v"

module id(
input wire rst,     //复位
input wire[`InstAddrBus] pc_i,    //译码阶段指令对应的地址
input wire[`InstDataBus] inst_i,  //译码阶段的指令(32bit)

//读取的regfile的值
input wire[`RegDataBus] reg1_data_i,//regfile模块输入的 第一个寄存器端口的 输入
input wire[`RegDataBus] reg2_data_i,//regfile模块输入的 第二个寄存器端口的 输入

//输出到regfile的信息
output reg reg1_read_o,         //regfile模块的 第一个读寄存器端口的 使能信号
output reg reg2_read_o,         //regfile模块的 第二个读寄存器端口的 使能信号
output reg[`RegAddrBus] reg1_addr_o,         //regfile模块的 第一个读寄存器端口的 地址信号
output reg[`RegAddrBus] reg2_addr_o,         //regfile模块的 第二个读寄存器端口的 地址信号

/************以下是为了解决数据相关问题的措施（使用数据前推）*************/
//执行阶段指令结果（解决相邻指令数据相关）
input wire ex_wreg_i,               //处于 执行阶段 是否要写入目的寄存器
input wire[`RegDataBus] ex_wdata_i,  //处于 执行阶段 要写入目的寄存器的数据
input wire[`RegAddrBus] ex_wd_i,    //处于 执行阶段 目的寄存器地址
//访存阶段结果（解决相隔一条指令数据相关）
input wire mem_wreg_i,              //同上 但处于访存阶段
input wire[`RegDataBus] mem_wdata_i,
input wire[`RegAddrBus] mem_wd_i,

//送到执行阶段的信息
output reg[`AluOpBus] aluop_o,  //译码阶段的指令要进行的运算的子类型
output reg[`AluSelBus] alusel_o,//译码阶段的指令要进行的运算的类型
output reg[`RegDataBus] reg1_o, //译码阶段源操作数1（32位）
output reg[`RegDataBus] reg2_o, //译码阶段原操作数2
output reg[`RegAddrBus] wd_o,   //译码阶段要写入的目的寄存器地址（5位）
output reg wreg_o,               //译码阶段的指令是否有要写入的目的寄存器
output wire[`RegDataBus] inst_o,     //输出当前处于译码阶段的指令

/************************以下为了实现转移指令***********************************/
input wire is_in_delayslot_i,           //若上一条是转移指令，那么下一条指令进入译码阶段，is_in_delayslot_i为true，表示是延迟槽指令
output reg branch_flag_o,               //是否发生转移
output reg is_in_delayslot_o,           //当前译码阶段的指令是否处于延迟槽
output reg next_inst_in_delayslot_o,    //下一条进入译码阶段的指令是否位于延迟槽
output reg[`RegDataBus] link_addr_o,    //转移指令要保存的返回地址
output reg[`RegDataBus] branch_target_address_o,    //转移到的目标地址

//暂停
output wire stallreq
    );
//取得指令的指令码、功能码
//对于ori 判断26-31位的值即可判断
wire[5:0] op = inst_i[31:26];   //op字段
wire[4:0] op2 = inst_i[10:6];   //shamt字段
wire[5:0] op3 = inst_i[5:0];    //func字段
wire[4:0] op4 = inst_i[20:16];  //rt字段
//暂停
assign stallreq = `NoStop;

//保存指令执行需要的立即数
reg[`RegDataBus] imm;

//指示指令是否有效
reg instValid;

//译码阶段的指令
assign inst_o = inst_i;

//跳转指令所需变量
wire[`RegDataBus] pc_plus_8;
wire[`RegDataBus] pc_plus_4;
wire[`RegDataBus] offset_ltwo_extend;  //分支指令offset左移两位，再扩展至32位

assign pc_plus_8 = pc_i + 8;    //保存当前译码阶段指令后面第2条指令的地址
assign pc_plus_4 = pc_i + 4;    //保存当前译码阶段指令后面第1条指令的地址
assign offset_ltwo_extend = {{14{inst_i[15]}}, inst_i[15:0], 2'b00}; //先左移再符号扩展

/*******************1.对指令译码***********************/
always @(*) begin
    if (rst == `RstEnable) begin    //复位设置
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instValid <= `InstInValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
        link_addr_o <= `MarsZero;   //返回地址
        branch_target_address_o <= `MarsZero;   //目标地址
        branch_flag_o <= `NotBranch;        //木得转移
        next_inst_in_delayslot_o <= `NotInDelaySlot; 
    end else begin                  //非复位
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11];  //rd字段
        wreg_o <= `WriteDisable;
        instValid <= `InstInValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];   //默认通过Regfile读端口1读取的寄存器地址
        reg2_addr_o <= inst_i[20:16];   //默认通过Regfile读端口2读取的寄存器地址
        imm <= `Zero;
        link_addr_o <= `MarsZero;
        branch_target_address_o <= `MarsZero;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
    case (op)
        `EXE_ORI:begin      //根据op的值判断是否为ori指令
            wreg_o <= `WriteEnable; //ori需要结果写入目的寄存器，所以WriteEnable
            aluop_o <= `EXE_OR_OP;  //运算的子类型是 or
            alusel_o <= `EXE_RES_LOGIC;//运算类型是逻辑运算
            reg1_read_o <= 1'b1; //需要通过Regfile的读端口1读取寄存器
            reg2_read_o <= 1'b0; //不需要通过2读
            imm <= {16'h0, inst_i[15:0]};   //指令执行需要的立即数 {}为数据拼接
            wd_o <= inst_i[20:16];  //执行指令要写的目的寄存器地址rt
            instValid <= `InstValid;    //ori指令是有效指令
        end
        `EXE_SPECIAL_INST: begin    //是否为SPECIAL（addu与subu）
            case(op2)
                5'b00000: begin      //位移为0
                    case(op3)
                        `EXE_ADDU: begin    //ADDU指令
                            wreg_o <= `WriteEnable;     //具体注释请参考ori
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instValid <= `InstValid;
                        end
                        `EXE_SUBU: begin    //SUBU指令
                             wreg_o <= `WriteEnable;     //具体注释请参考ori
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instValid <= `InstValid;                       
                        end                      
                    endcase //op3              
                end     //5'b00000
            endcase    //op2
        end //EXE_SPECIAL_INST
        `EXE_JAL: begin     //JAL指令
            wreg_o <= `WriteEnable;     //jal需要保存返回地址，wreg_o为WriteEnable
            aluop_o <= `EXE_JAL_OP;
            alusel_o <= `EXE_RES_JUMP_BRANCH;
            reg1_read_o <= 1'b0;        //无需读取通用寄存器
            reg2_read_o <= 1'b0;
            wd_o <= 5'b11111;           //jal将返回地址写道寄存器$31中
            link_addr_o <= pc_plus_8;   //设置返回地址为第2条指令的地址
            branch_flag_o <= `Branch;   //是绝对转移指令
            next_inst_in_delayslot_o <= `InDelaySlot; //下一条指令在延迟槽中
            instValid = `InstValid;
            //branch_target_address_o <= {pc_plus_4[31:28],2'b00, inst_i[25:2], 2'b00}; //跳转地址
            branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
        end
        `EXE_BEQ: begin     //BEQ指令
            wreg_o <= `WriteDisable;    //不需要保存返回地址F
            aluop_o <= `EXE_BEQ_OP;     //可能有误
            alusel_o <= `EXE_RES_JUMP_BRANCH;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            instValid = `InstValid;
            if (reg1_o == reg2_o) begin //符合beg跳转条件
                branch_target_address_o <= pc_plus_4 + offset_ltwo_extend;  //跳转地址
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;   // 下一条指令再延迟槽中
            end 
        end
        `EXE_LW: begin
            wreg_o <= `WriteEnable;     //需要将加载结果写入目的寄存器
            aluop_o <= `EXE_LW_OP;
            alusel_o <= `EXE_RES_LOAD_STORE;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            wd_o <= inst_i[20:16];      //目的寄存器为指令的20:16位
            instValid <= `InstValid;
        end
        `EXE_SW: begin
            wreg_o <= `WriteDisable;    //无需写入寄存器
            aluop_o <= `EXE_SW_OP;
            alusel_o <= `EXE_RES_LOAD_STORE; 
            reg1_read_o <= 1'b1;        //译码阶段reg1_o正是base寄存器的值
            reg2_read_o <= 1'b1;        //reg2_o是rt寄存器的值
            instValid <= `InstValid;
        end
        default: begin
        end
    endcase //case op
    end //else begin
end //always

/*******************2.确定源操作数1***********************/

always @ (*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `Zero;
    //接下来两条if用于解决数据线相关问题
    //如果Regfile模块读端口1要读取的寄存器就是执行阶段要写的寄存器，直接把执行结果赋给reg1_o
    end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o <= ex_wdata_i;
    //如果Regfile模块读端口1要读取的寄存器是访存阶段要写的寄存器，直接把执行结果给reg1_o
    end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o <= mem_wdata_i;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile读端口1的输出值
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm;          //立即数
    end else begin
        reg1_o <= `Zero;
    end
end

/*******************3.确定源操作数2***********************/
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `Zero;
    //接下来两条if用于解决数据线相关问题
    //如果Regfile模块读端口2要读取的寄存器就是执行阶段要写的寄存器，直接把执行结果赋给reg1_o
    end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o <= ex_wdata_i;
    //如果Regfile模块读端口2要读取的寄存器是访存阶段要写的寄存器，直接把执行结果给reg1_o
    end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o <= mem_wdata_i;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile读端口1的输出值
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm;          //立即数
    end else begin
        reg2_o <= `Zero;
    end
end

/********************判断当前指令是否是延迟槽命令******************************/
always @(*) begin
    if(rst == `RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end

endmodule
