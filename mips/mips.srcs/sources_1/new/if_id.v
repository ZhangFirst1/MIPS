`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:47:54
// Design Name: 
// Module Name: if_id
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
//if_id ģ��
//ʵ��ȡָ������׶�֮��ļĴ���
`include "defines.v"

module if_id(
input wire clk,
input wire rst,
//����ȡָ��׶ε��ź� ��ַ������
input wire[`InstAddrBus] if_pc,
input wire[`InstDataBus] if_inst,
//���� �� ����׶�
output reg[`InstAddrBus] id_pc,
output reg[`InstDataBus] id_inst
    );

//��Ҫ����ʵ��
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `MarsZero; //��λʱpc��MarsZero
        id_inst <= `Zero;   //��Ӧ��ָ��
    end else begin
        id_pc <= if_pc;     //�Ǹ�λֱ�����½׶δ���ֵ
        id_inst <= if_inst; 
    end
end

endmodule
