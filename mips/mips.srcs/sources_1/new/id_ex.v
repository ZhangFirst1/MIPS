`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 09:26:35
// Design Name: 
// Module Name: id_ex
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

//id_ex 模块、
/*将译码阶段取得的运算类型、源操作数、要写的目的寄存器地址等结果，在下
一个时钟传递到流水线执行阶段*/
`include "defines.v"

module id_ex(
input wire clk,
input wire rst,
input wire[5:0] stall,
//译码阶段传来的信息
input wire[`AluOpBus] id_aluop,     //运算类型
input wire[`AluSelBus] id_alusel,   //运算字类型
input wire[`RegDataBus] id_reg1,    //源操作数1
input wire[`RegDataBus] id_reg2,    //源操作数2
input wire[`RegAddrBus] id_wd,      //目的寄存器
input wire id_wreg,                 //是否有目的寄存器
input wire[`RegDataBus] id_link_address,    //处于译码阶段的转移指令保存的返回地址 
input wire id_is_in_delayslot,  //当前译码阶段的指令是福哦处于延迟槽
input wire next_inst_in_delayslot_i,    //下一条指令是否位于延迟槽
input wire[`RegDataBus] id_inst,        //当前处于译码阶段的指令

//传递到执行阶段的信息
output reg[`AluOpBus] ex_aluop,     //同上
output reg[`AluSelBus] ex_alusel,
output reg[`RegDataBus] ex_reg1,
output reg[`RegDataBus] ex_reg2,
output reg[`RegAddrBus] ex_wd,
output reg ex_wreg,
output reg[`RegDataBus] ex_link_address,    //同上
output reg ex_is_in_delayslot,
output reg is_in_delayslot_o,
output reg[`RegDataBus] ex_inst     //处于执行阶段的指令
    );
//功能清晰 不多赘述
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `Zero;
        ex_reg2 <= `Zero;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `Zero;
        ex_is_in_delayslot <= `NotInDelaySlot;
        is_in_delayslot_o <= `NotInDelaySlot;
    end else if(stall[2] == `Stop && stall[3] == `NoStop) begin //译码阶段暂停 执行阶段继续 用空指令填充
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `Zero;
        ex_reg2 <= `Zero;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `Zero;        
    end else if(stall[2] == `NoStop) begin //译码阶段继续 译码后的指令进入执行阶段
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_link_address <= id_link_address;
        ex_is_in_delayslot <= id_is_in_delayslot;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
        ex_inst <= id_inst;
    end
end

endmodule
