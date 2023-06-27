`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:25:31
// Design Name: 
// Module Name: mem_wb
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
//MEM/WB 模块
//将访存阶段的运算结果，在下一个时钟传递到回写阶段
`include "defines.v"

module mem_wb(
input wire clk,
input wire rst,
// 访存阶段结果
input wire[`RegAddrBus] mem_wd,
input wire mem_wreg,
input wire[`RegDataBus] mem_wdata,

// 送到回写阶段
output reg[`RegAddrBus] wb_wd,
output reg wb_wreg,
output reg[`RegDataBus] wb_wdata
    );
always @ (posedge clk) begin
     if(rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `Zero; 
     end else begin
         wb_wd <= mem_wd;
         wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
     end 
end 
endmodule
