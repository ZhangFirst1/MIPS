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
input wire[`AluOpBus] aluop_i,      //访存阶段指令运算的字类型
input wire[`RegDataBus] mem_addr_i, //访存阶段加载/存储的地址
input wire[`RegDataBus] reg2_i,     //访存阶段要存储的数据
// 来自外部数据存储器RAM的信息
input wire[`RegDataBus] mem_data_i, //从数据存储器读取的数据
// 访存阶段的结果
output reg[`RegAddrBus] wd_o,
output reg wreg_o,
output reg[`RegDataBus] wdata_o,
// 送到外部存储器RAM的信息
output reg[`RegDataBus] mem_addr_o, //要访问的数据存储器的地址
output wire mem_we_o,               //是否为写操作
output reg[3:0] mem_sel_o,          //字节选择信号
output reg[`RegDataBus] mem_data_o, //要写入数据存储器的数据
output reg mem_ce_o                 //数据存储器使能信号
    );

//输入直接作为结果输出
//与mem/wb模块不同 mem模块是组合逻辑电路 而mem/wb是时序逻辑电路
wire [`RegDataBus] zero32;
reg mem_we;

assign mem_we_o = mem_we;   //外部数据存储器的读写信号
assign zero32 = `Zero;

always @ (*) begin
     if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `Zero;
        mem_addr_o <= `Zero;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `Zero;
        mem_ce_o <= `ChipDisable;
     end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        mem_we <= `WriteDisable;
        mem_addr_o <= `Zero;
        mem_sel_o <= 4'b1111;   //表示4个存储块全选
        mem_ce_o <= `ChipDisable;
        case(aluop_i)
            `EXE_LW_OP: begin
                mem_addr_o <= mem_addr_i;   //要访问的地址即为执行阶段算出来的地址
                mem_we <= `WriteDisable;    //是写操作
                wdata_o <= mem_data_i;      
                mem_sel_o <= 4'b1111;       //读取全部字节
                mem_ce_o <= `ChipEnable;    //要访问数据存储器
            end
            `EXE_SW_OP: begin
                mem_addr_o <= mem_addr_i;   //同上
                mem_we <= `WriteEnable;
                mem_data_o <= reg2_i;       
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;    
            end
        endcase
     end 
end

endmodule
