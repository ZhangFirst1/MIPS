`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:14:36
// Design Name: 
// Module Name: ex_mem
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

//EX/MEM模块
//将执行阶段取得的运算结果，在下一个时钟传递到流水线访存阶段
`include "defines.v"

module ex_mem(
input wire clk,
input wire rst,

//来自执行阶段
input wire[`RegAddrBus] ex_wd,  //指令执行后要写入的目的寄存器
input wire ex_wreg,             //是否要写入
input wire[`RegDataBus] ex_wdata,   //值
input wire[`AluOpBus] ex_aluop,     //执行阶段指令字类型
input wire[`RegDataBus] ex_mem_addr,//执行阶段加载、存储指令的存储器地址
input wire[`RegDataBus] ex_reg2,    //执行阶段指令要存储的数据
//送到访存阶段
output reg[`RegAddrBus] mem_wd, //同上
output reg mem_wreg,
output reg[`RegDataBus] mem_wdata,
output reg[`AluOpBus] mem_aluop,      //同上 但访存
output reg[`RegDataBus] mem_mem_addr,
output reg[`RegDataBus] mem_reg2
    );
//传送数据
always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `Zero;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `Zero;
        mem_reg2 <= `Zero;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata; 
        mem_aluop <= ex_aluop;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2 <= ex_reg2;
    end 
end 

endmodule
