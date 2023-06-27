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
//�ô�׶�
//����Ǽ��ء��洢ָ���ô������ݴ洢�����з��ʡ�
`include "defines.v"

module mem(
input wire rst,
// ����ִ�н׶ε���Ϣ
input wire[`RegAddrBus] wd_i,
input wire wreg_i,
input wire[`RegDataBus] wdata_i,
// �ô�׶εĽ��
output reg[`RegAddrBus] wd_o,
output reg wreg_o,
output reg[`RegDataBus] wdata_o
    );

//��ʱδʵ�ּ��ء��洢ָ��
//����ֱ����Ϊ������
//��mem/wbģ�鲻ͬ memģ��������߼���· ��mem/wb��ʱ���߼���·
always @ (*) begin
     if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `Zero;
     end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
     end 
end

endmodule
