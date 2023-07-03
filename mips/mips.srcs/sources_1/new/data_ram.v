`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/30 17:19:14
// Design Name: 
// Module Name: data_ram
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

`include "defines.v"

module data_ram(
input wire clk,
input wire ce,
input wire we, //写使能信号
input wire [`DataAddrBus] addr, //存取地址
input wire [3:0] sel, // 选择要存取的字节数
input wire[`DataBus] data_i, //要写入的数据
output reg[`DataBus] data_o //要读出的数据
    );
    // 定义四个字节数组，每个数组的一个元素代表了一个字的数据的一位，每个字节数组的元素的位数为ByteWidth，每个一共有DataMemNum个元素
     reg[`ByteWidth] data_mem0[0:`DataMemNum-1]; 
     reg[`ByteWidth] data_mem1[0:`DataMemNum-1]; 
     reg[`ByteWidth] data_mem2[0:`DataMemNum-1]; 
     reg[`ByteWidth] data_mem3[0:`DataMemNum-1];
     // 写操作
      always @ (posedge clk) begin 
      if (ce == `ChipDisable) begin 
      //data_o <= ZeroWord;
      end else if(we == `WriteEnable) begin 
      if (sel[3] == 1'b1) begin data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24]; end //写入数据最高位
      if (sel[2] == 1'b1) begin data_mem2[addr[`DataMemNumLog2+1:2]] <=data_i[23:16]; end 
      if (sel[1] == 1'b1) begin data_mem1[addr[`DataMemNumLog2+1:2]] <=data_i[15:8]; end 
      if (sel[0] == 1'b1) begin data_mem0[addr[`DataMemNumLog2+1:2]] <=data_i[7:0]; end //写入数据最低位
      end // else if
    end //always
    // 读操作
     always @ (*) begin 
     if (ce == `ChipDisable) begin 
     data_o <= `Zero; 
     end else if(we == `WriteDisable) begin 
     data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],  data_mem2[addr[`DataMemNumLog2+1:2]], 
     data_mem1[addr[`DataMemNumLog2+1:2]], data_mem0[addr[`DataMemNumLog2+1:2]]}; //拼接成为要读出的数据 
     end else begin 
     data_o <= `Zero; 
     end //else 
   end //always
endmodule