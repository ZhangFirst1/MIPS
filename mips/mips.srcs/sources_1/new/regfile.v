`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 16:30:29
// Design Name: 
// Module Name: regfile
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

//Regfile 模块
//实现32个32位通用寄存器，可以同时进行两个寄存器读操作和一个寄存器写操作
`include "defines.v"

module regfile(
input wire clk,
input wire rst,
//写端口
input wire we,                  //写使能信号
input wire[`RegAddrBus] waddr,  //要写入的寄存器地址
input wire[`RegDataBus] wdata,  //要写入的数据
//读端口1
input wire re1,
input wire[`RegAddrBus] raddr1, //第一个读寄存器端口读取的寄存器地址
output reg[`RegDataBus] rdata1, //第一个读寄存器端口输出寄存器值
//读端口2
input wire re2,
input wire[`RegAddrBus] raddr2, //同上
output reg[`RegDataBus] rdata2
    );
/* 32个32位寄存器 */
(* MARK_DEBUG="true" *)reg[`RegDataBus] regs[0:`RegNum-1]; //二维向量

/* 写操作 */
always @(posedge clk) begin
    if (rst == `RstDisable) begin   //复位信号无效
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin //使能信号有效 且 写操作寄存器不为0(规定$0只能为0)
                regs[waddr] <= wdata;   //将写输入数据保存到目标寄存器
            end
        end
    end

/* 读端口1操作 */
always @(*) begin
    if(rst == `RstEnable) begin //复位信号有效 第一个读寄存器端口输出始终为零
        rdata1 <= `Zero;
    end else if(raddr1 == `RegNumLog2'h0) begin  //复位信号无效 读0端口
        rdata1 <= `Zero;
    end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //读与写是同一个寄存器 直接赋值第一个的写入
        rdata1 <= wdata;
    end else if(re1 == `ReadEnable) begin   //上述都不满足 正常读取
        rdata1 <= regs[raddr1];
    end else begin  //其余情况（端口不能使用） 直接输出0
        rdata1 <= `Zero;
    end   
end

/* 读端口2操作 */
always @(*) begin
    if(rst == `RstEnable) begin //复位信号有效 第一个读寄存器端口输出始终为零
        rdata2 <= `Zero;
    end else if(raddr2 == `RegNumLog2'h0) begin  //复位信号无效 读0端口
        rdata2 <= `Zero;
    end else if((raddr2 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //读与写是同一个寄存器 直接赋值第一个的写入
        rdata2 <= wdata;
    end else if(re1 == `ReadEnable) begin   //上述都不满足 正常读取
        rdata2 <= regs[raddr2];
    end else begin  //其余情况（端口不能使用） 直接输出0
        rdata2 <= `Zero;
    end   
end

endmodule
