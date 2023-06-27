`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 15:36:59
// Design Name: 
// Module Name: inst_rom
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
//指令存储器ROM模块
//MIPS从中读取指令
`include "defines.v"

module inst_rom(
input wire ce,                  //使能信号
input wire[`InstAddrBus] addr,  //要读取的指令地址
output reg[`InstDataBus] inst   //读出的指令
    );
//定义一个大小为InstMemNum 宽度为InstDataBus（32bit）的数组
reg[`InstDataBus] inst_mem[0:`InstMemNum-1];

//使用文件inst_rom.data初始化指令寄存器
initial $readmemh("C:/Users/ZhangFirst1/Desktop/cclab/mips/inst_rom.data", inst_mem);   //从文件中读取数据初始化inst_mem

//复位信号无效，根据输入的地址给出指令
always @(*) begin
    if (ce == `ChipDisable) begin
        inst <= `Zero;
    end else begin
        //`InstMemNumLog2给出指令存储器的实际宽度
        //将MIPS给出的地址除以4使用 所以:2表示地址右移2位
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];    
    end
end 

endmodule
