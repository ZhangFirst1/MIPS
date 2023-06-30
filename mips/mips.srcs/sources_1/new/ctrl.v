`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/30 14:40:32
// Design Name: 
// Module Name: ctrl
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

//控制流水线暂停的模块
/*
stall[0]表示取指地址PC是否保持不变
stall[1]表示流水线取指阶段是否暂停
stall[2]表示流水线译码阶段是否暂停
stall[3]表示流水线执行阶段是否暂停
stall[4]表示流水线访存阶段是否暂停
stall[5]表示流水线回写阶段是否暂停
*/
`include "defines.v"

module ctrl( 
input wire rst, 
input wire stallreq_from_id, // 来自译码阶段的暂停请求
input wire stallreq_from_ex, // 来自执行阶段的暂停请求
output reg[5:0] stall 
);
always @ (*) begin 
    if(rst == `RstEnable) begin 
        stall <= 6'b000000;     
    end else if(stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;     //执行阶段暂停 取指、译码、执行阶段暂停，而访存、回写阶段继续
    end else if(stallreq_from_id == `Stop) begin
        stall <= 6'b000111;     //译码阶段暂停 取指、译码阶段暂停，而执行、访存、回写阶段继续
    end else begin 
        stall <= 6'b000000; 
    end 
end 
 
endmodule 