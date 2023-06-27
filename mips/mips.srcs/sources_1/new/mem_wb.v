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
//MEM/WB ģ��
//���ô�׶ε�������������һ��ʱ�Ӵ��ݵ���д�׶�
`include "defines.v"

module mem_wb(
input wire clk,
input wire rst,
// �ô�׶ν��
input wire[`RegAddrBus] mem_wd,
input wire mem_wreg,
input wire[`RegDataBus] mem_wdata,

// �͵���д�׶�
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
