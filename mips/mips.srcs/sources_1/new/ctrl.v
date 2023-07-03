`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/30 14:40:32
// Design Name: 
// Module Name: ctrl
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

//������ˮ����ͣ��ģ��
/*
stall[0]��ʾȡָ��ַPC�Ƿ񱣳ֲ���
stall[1]��ʾ��ˮ��ȡָ�׶��Ƿ���ͣ
stall[2]��ʾ��ˮ������׶��Ƿ���ͣ
stall[3]��ʾ��ˮ��ִ�н׶��Ƿ���ͣ
stall[4]��ʾ��ˮ�߷ô�׶��Ƿ���ͣ
stall[5]��ʾ��ˮ�߻�д�׶��Ƿ���ͣ
*/
`include "defines.v"

module ctrl( 
input wire rst, 
input wire stallreq_from_id, // ��������׶ε���ͣ����
input wire stallreq_from_ex, // ����ִ�н׶ε���ͣ����
output reg[5:0] stall 
);
always @ (*) begin 
    if(rst == `RstEnable) begin 
        stall <= 6'b000000;     
    end else if(stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;     //ִ�н׶���ͣ ȡָ�����롢ִ�н׶���ͣ�����ô桢��д�׶μ���
    end else if(stallreq_from_id == `Stop) begin
        stall <= 6'b000111;     //����׶���ͣ ȡָ������׶���ͣ����ִ�С��ô桢��д�׶μ���
    end else begin 
        stall <= 6'b000000; 
    end 
end 
 
endmodule 