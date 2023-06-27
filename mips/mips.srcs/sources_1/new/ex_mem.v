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

//�͵��ô�׶�
output reg[`RegAddrBus] mem_wd, //ͬ��
output reg mem_wreg,
output reg[`RegDataBus] mem_wdata
    );
//��������
always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `Zero;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata; 
    end 
end 

endmodule
