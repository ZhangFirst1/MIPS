`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:14:36
// Design Name: 
// Module Name: ex_mem
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

//EX/MEMģ��
//��ִ�н׶�ȡ�õ�������������һ��ʱ�Ӵ��ݵ���ˮ�߷ô�׶�
`include "defines.v"

module ex_mem(
input wire clk,
input wire rst,

//����ִ�н׶�
input wire[`RegAddrBus] ex_wd,  //ָ��ִ�к�Ҫд���Ŀ�ļĴ���
input wire ex_wreg,             //�Ƿ�Ҫд��
input wire[`RegDataBus] ex_wdata,   //ֵ
input wire[`AluOpBus] ex_aluop,     //ִ�н׶�ָ��������
input wire[`RegDataBus] ex_mem_addr,//ִ�н׶μ��ء��洢ָ��Ĵ洢����ַ
input wire[`RegDataBus] ex_reg2,    //ִ�н׶�ָ��Ҫ�洢������
//�͵��ô�׶�
output reg[`RegAddrBus] mem_wd, //ͬ��
output reg mem_wreg,
output reg[`RegDataBus] mem_wdata,
output reg[`AluOpBus] mem_aluop,      //ͬ�� ���ô�
output reg[`RegDataBus] mem_mem_addr,
output reg[`RegDataBus] mem_reg2
    );
//��������
always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `Zero;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `Zero;
        mem_reg2 <= `Zero;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata; 
        mem_aluop <= ex_aluop;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2 <= ex_reg2;
    end 
end 

endmodule
