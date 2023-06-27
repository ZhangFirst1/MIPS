`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:30:18
// Design Name: 
// Module Name: pc_reg
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
//���������PC
//����ָ���ַ��PC�е�ֵ����ָ���ַ
`include "defines.v"

module pc_reg(
input wire clk,     //ʱ���ź�
input wire rst,     //ͬ������
output reg[`InstAddrBus] pc,//ָ���ַ��
output reg ce               //ʹ���ź�
    );
    
//��λʱPC���ܽ���
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;     //��λʱpc����
    end else begin
        ce <= `ChipEnable;      //��λ������pc����
    end
end
//���幦��
always @(posedge clk) begin
    if (ce == `ChipDisable) begin
    pc <= `MarsZero;         //����ʱpcΪ0000_3000��Mars���Ӧ
    end else begin
        pc <= pc + 4'h4;        //PCÿ��ʱ�����ڼ�4(һ��ָ���ĸ��ֽ�)
    end
end
    
endmodule
