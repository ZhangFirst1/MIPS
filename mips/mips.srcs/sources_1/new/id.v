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
//送到执行阶段的信息
output reg[`AluOpBus] aluop_o,  //译码阶段的指令要进行的运算的子类型
output reg[`AluSelBus] alusel_o,//译码阶段的指令要进行的运算的类型
output reg[`RegDataBus] reg1_o, //译码阶段源操作数1（32位）
output reg[`RegDataBus] reg2_o, //译码阶段原操作数2
output reg[`RegAddrBus] wd_o,   //译码阶段要写入的目的寄存器地址（5位）
output reg wreg_o               //译码阶段的指令是否有要写入的目的寄存器
    );
//取得指令的指令码、功能码
//对于ori 判断26-31位的值即可判断
wire[5:0] op = inst_i[31:26];   //op字段
wire[4:0] op2 = inst_i[10:6];   //shamt字段
wire[5:0] op3 = inst_i[5:0];    //func字段
wire[4:0] op4 = inst_i[20:16];  //rt字段

//保存指令执行需要的立即数
reg[`RegDataBus] imm;

//指示指令是否有效
reg instValid;

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
    case (op)
        `EXE_ORI:begin      //根据op的值判断是否位ori指令
            wreg_o <= `WriteEnable; //ori需要结果写入目的寄存器，所以WriteEnable
            aluop_o <= `EXE_OR_OP;  //运算的子类型是 or
            alusel_o <= `EXE_RES_LOGIC;//运算类型是逻辑运算
            reg1_read_o <= 1'b1; //需要通过Regfile的读端口1读取寄存器
            reg2_read_o <= 1'b0; //不需要通过2读
            imm <= {16'h0, inst_i[15:0]};   //指令执行需要的立即数 {}为数据拼接
            wd_o <= inst_i[20:16];  //执行指令要写的目的寄存器地址rt
            instValid <= `InstValid;    //ori指令是有效指令
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
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile读端口1的输出值
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm;          //立即数
    end else begin
        reg2_o <= `Zero;
    end
end

endmodule
