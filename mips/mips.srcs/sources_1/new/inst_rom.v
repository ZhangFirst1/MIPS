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
//ָ��洢��ROMģ��
//MIPS���ж�ȡָ��
`include "defines.v"

module inst_rom(
input wire ce,                  //ʹ���ź�
input wire[`InstAddrBus] addr,  //Ҫ��ȡ��ָ���ַ
output reg[`InstDataBus] inst   //������ָ��
    );
//����һ����СΪInstMemNum ���ΪInstDataBus��32bit��������
reg[`InstDataBus] inst_mem[0:`InstMemNum-1];

//ʹ���ļ�inst_rom.data��ʼ��ָ��Ĵ���
initial $readmemh("C:/Users/ZhangFirst1/Desktop/cclab/mips/inst_rom.data", inst_mem);   //���ļ��ж�ȡ���ݳ�ʼ��inst_mem

//��λ�ź���Ч����������ĵ�ַ����ָ��
always @(*) begin
    if (ce == `ChipDisable) begin
        inst <= `Zero;
    end else begin
        //`InstMemNumLog2����ָ��洢����ʵ�ʿ��
        //��MIPS�����ĵ�ַ����4ʹ�� ����:2��ʾ��ַ����2λ
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];    
    end
end 

endmodule
