`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:01:38
// Design Name: 
// Module Name: defines
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

//******************全局宏定义**********************//
`define RstEnable    1'b1         //复位信号有效
`define RstDisable   1'b0         //复位信号无效
`define Zero         32'h00000000 //32位0
`define MarsZero     32'h00003000 //Mars测试配合
`define WriteEnable  1'b1         //使能端写
`define WriteDisable 1'b0         //禁止写
`define ReadEnable   1'b1         //使能端读
`define ReadDisable  1'b0         //禁止读
`define AluOpBus     7:0          //译码阶段的输出aluop_o的宽度
`define AluSelBus    2:0          //译码阶段的输出alusel_o的宽度
`define InstValid    1'b0         //指令有效
`define InstInValid  1'b1        //指令无效
`define True_v       1'b1        //逻辑"真"
`define False_v      1'b0        //逻辑"假"
`define ChipEnable   1'b1        //芯片使能
`define ChipDisable  1'b0        //芯片禁止

//******************具体指令定义**********************//
`define EXE_ORI      6'b001101   //指令ori的指令码
`define EXE_NOP      6'b000000   

//请注意 此处译码后的指令给出的是MIPS32 Release1指令集 而非报告中MIPS-Lite1指令集
//后续可能修改编码位数 缩小指令长度
//AluOp
`define EXE_OR_OP   8'b00100101   //译码后的指令码
`define EXE_NOP_OP  8'b00000000

//AluSel
`define EXE_RES_LOGIC   3'b001     //译码后的子操作码
`define EXE_RES_NOP     3'b000

//******************存储器ROM相关**********************//
`define InstAddrBus 31:0 //ROM的地址总线宽度
`define InstDataBus 31:0 //ROM的数据总线宽度
`define InstMemNum 1023   //指令存储器数组大小
`define InstMemNumLog2 10   //指令存储器的实际地址宽度

//******************通用寄存器RegFile相关**********************//
`define RegAddrBus  4:0         //地址线宽度
`define RegDataBus  31:0        //数据线宽度
`define RegWidth    32          //通用寄存器宽度
`define DoubleRegWidth 64       //两倍宽度
`define DoubleRegDataBus 63:0   //两倍数据线宽度
`define RegNum          32      //通用寄存器数量
`define RegNumLog2      5       //寻址通用寄存器位数
`define NOPRegAddr      5'b00000