`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:30:18
// Design Name: 
// Module Name: pc_reg
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
//程序计数器PC
//给出指令地址，PC中的值就是指令地址
`include "defines.v"

module pc_reg(
input wire clk,     //时钟信号
input wire rst,     //同步置零
output reg[`InstAddrBus] pc,//指令地址线
output reg ce               //使能信号
    );
    
//复位时PC功能禁用
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;     //复位时pc禁用
    end else begin
        ce <= `ChipEnable;      //复位结束，pc可用
    end
end
//具体功能
always @(posedge clk) begin
    if (ce == `ChipDisable) begin
    pc <= `MarsZero;         //禁用时pc为0000_3000与Mars相对应
    end else begin
        pc <= pc + 4'h4;        //PC每个时钟周期加4(一条指令四个字节)
    end
end
    
endmodule
