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

//id_ex ģ�顢
/*������׶�ȡ�õ��������͡�Դ��������Ҫд��Ŀ�ļĴ�����ַ�Ƚ��������
һ��ʱ�Ӵ��ݵ���ˮ��ִ�н׶�*/
`include "defines.v"

module id_ex(
input wire clk,
input wire rst,
input wire[5:0] stall,
//����׶δ�������Ϣ
input wire[`AluOpBus] id_aluop,     //��������
input wire[`AluSelBus] id_alusel,   //����������
input wire[`RegDataBus] id_reg1,    //Դ������1
input wire[`RegDataBus] id_reg2,    //Դ������2
input wire[`RegAddrBus] id_wd,      //Ŀ�ļĴ���
input wire id_wreg,                 //�Ƿ���Ŀ�ļĴ���
input wire[`RegDataBus] id_link_address,    //��������׶ε�ת��ָ���ķ��ص�ַ 
input wire id_is_in_delayslot,  //��ǰ����׶ε�ָ���Ǹ�Ŷ�����ӳٲ�
input wire next_inst_in_delayslot_i,    //��һ��ָ���Ƿ�λ���ӳٲ�
input wire[`RegDataBus] id_inst,        //��ǰ��������׶ε�ָ��

//���ݵ�ִ�н׶ε���Ϣ
output reg[`AluOpBus] ex_aluop,     //ͬ��
output reg[`AluSelBus] ex_alusel,
output reg[`RegDataBus] ex_reg1,
output reg[`RegDataBus] ex_reg2,
output reg[`RegAddrBus] ex_wd,
output reg ex_wreg,
output reg[`RegDataBus] ex_link_address,    //ͬ��
output reg ex_is_in_delayslot,
output reg is_in_delayslot_o,
output reg[`RegDataBus] ex_inst     //����ִ�н׶ε�ָ��
    );
//�������� ����׸��
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
    end else if(stall[2] == `Stop && stall[3] == `NoStop) begin //����׶���ͣ ִ�н׶μ��� �ÿ�ָ�����
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `Zero;
        ex_reg2 <= `Zero;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `Zero;        
    end else if(stall[2] == `NoStop) begin //����׶μ��� ������ָ�����ִ�н׶�
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
