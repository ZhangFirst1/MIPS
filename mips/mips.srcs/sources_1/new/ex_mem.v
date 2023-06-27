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

//送到访存阶段
output reg[`RegAddrBus] mem_wd, //同上
output reg mem_wreg,
output reg[`RegDataBus] mem_wdata
    );
//传送数据
always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `Zero;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata; 
    end 
end 

endmodule
