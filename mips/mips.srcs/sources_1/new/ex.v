`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 09:38:01
// Design Name: 
// Module Name: ex
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

//执行模块
/*从ID/EX模块得到运算类型alusel_i、运算子类型aluop_i、源操作数reg1_i、
源操作数reg2_i、要写的目的寄存器地址wd_i，根据这些数据进行运算*/
//请注意 此处为具体功能实现模块 在添加功能后请注意添加相应注释
//目前已经实现 ori 
`include "defines.v"

module ex(
input wire rst,
//ID/EX模块传递的信息
input wire[`AluOpBus] aluop_i,  //运算类型
input wire[`AluSelBus] alusel_i,//运算子类型
input wire[`RegDataBus] reg1_i,//源操作数1
input wire[`RegDataBus] reg2_i,//源操作数2
input wire[`RegAddrBus] wd_i,   //目的寄存器
input wire wreg_i,              //是否有目的寄存器

//执行结果
output reg[`RegAddrBus] wd_o,   //执行阶段的指令要写入的 目的寄存器地址
output reg wreg_o,              //是否有目的寄存器
output reg[`RegDataBus] wdata_o //最终要写入目的寄存器的 值
    );
// 逻辑运算的结果
reg[`RegDataBus] logicout;

/***************1.根据aluop_i的运算字类型进行运算（暂时只有或）********************/    
always @(*) begin
    if(rst == `RstEnable) begin
        logicout <= `Zero;
    end else begin
        case(aluop_i)
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;    //实现 或 操作
            end
            default: begin
                logicout <= `Zero;
            end //default
        endcase
    end//else
end//always

/***************1.根据alusel_i选择一个运算结果为最终结果（暂时只有或）********************/   
always @(*) begin
    wd_o <= wd_i;   //要写的目的寄存器
    wreg_o <= wreg_i;   //是否要写
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;    //存放运算结果
        end
        default: begin
            wdata_o <= `Zero;
        end
    endcase
end //always

endmodule
