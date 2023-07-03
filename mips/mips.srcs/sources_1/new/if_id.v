`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:47:54
// Design Name: 
// Module Name: if_id
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
//if_id 模块
//实现取指与译码阶段之间的寄存器
`include "defines.v"

module if_id(
input wire clk,
input wire rst,
input wire[5:0] stall,
//来自取指令阶段的信号 地址与数据
input wire[`InstAddrBus] if_pc,
input wire[`InstDataBus] if_inst,
//传出 至 译码阶段
output reg[`InstAddrBus] id_pc,
output reg[`InstDataBus] id_inst
    );

//主要功能实现
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `MarsZero; //复位时pc置MarsZero
        id_inst <= `Zero;   //对应空指令
    end else if(stall[1] == `Stop && stall[2] == `NoStop) begin //取值阶段暂停 译码阶段继续 使用空指令作为下一个周期进入译码阶段的指令
        id_pc <= `MarsZero;
        id_inst <= `Zero;
    end else if(stall[1] == `NoStop) begin      //取址阶段继续 得到的指令进入译码阶段
        id_pc <= if_pc;     //非复位直接向下阶段传递值
        id_inst <= if_inst; 
    end
end

endmodule
