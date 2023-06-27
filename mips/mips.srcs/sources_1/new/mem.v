`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:19:41
// Design Name: 
// Module Name: mem
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
//访存阶段
//如果是加载、存储指令，那么会对数据存储器进行访问。
`include "defines.v"

module mem(
input wire rst,
// 来自执行阶段的信息
input wire[`RegAddrBus] wd_i,
input wire wreg_i,
input wire[`RegDataBus] wdata_i,
// 访存阶段的结果
output reg[`RegAddrBus] wd_o,
output reg wreg_o,
output reg[`RegDataBus] wdata_o
    );

//暂时未实现加载、存储指令
//输入直接作为结果输出
//与mem/wb模块不同 mem模块是组合逻辑电路 而mem/wb是时序逻辑电路
always @ (*) begin
     if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `Zero;
     end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
     end 
end

endmodule
