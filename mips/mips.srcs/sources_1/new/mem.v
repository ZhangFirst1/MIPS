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
input wire[`AluOpBus] aluop_i,      //�ô�׶�ָ�������������
input wire[`RegDataBus] mem_addr_i, //�ô�׶μ���/�洢�ĵ�ַ
input wire[`RegDataBus] reg2_i,     //�ô�׶�Ҫ�洢������
// �����ⲿ���ݴ洢��RAM����Ϣ
input wire[`RegDataBus] mem_data_i, //�����ݴ洢����ȡ������
// �ô�׶εĽ��
output reg[`RegAddrBus] wd_o,
output reg wreg_o,
output reg[`RegDataBus] wdata_o,
// �͵��ⲿ�洢��RAM����Ϣ
output reg[`RegDataBus] mem_addr_o, //Ҫ���ʵ����ݴ洢���ĵ�ַ
output wire mem_we_o,               //�Ƿ�Ϊд����
output reg[3:0] mem_sel_o,          //�ֽ�ѡ���ź�
output reg[`RegDataBus] mem_data_o, //Ҫд�����ݴ洢��������
output reg mem_ce_o                 //���ݴ洢��ʹ���ź�
    );

//����ֱ����Ϊ������
//��mem/wbģ�鲻ͬ memģ��������߼���· ��mem/wb��ʱ���߼���·
wire [`RegDataBus] zero32;
reg mem_we;

assign mem_we_o = mem_we;   //�ⲿ���ݴ洢���Ķ�д�ź�
assign zero32 = `Zero;

always @ (*) begin
     if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `Zero;
        mem_addr_o <= `Zero;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `Zero;
        mem_ce_o <= `ChipDisable;
     end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        mem_we <= `WriteDisable;
        mem_addr_o <= `Zero;
        mem_sel_o <= 4'b1111;   //��ʾ4���洢��ȫѡ
        mem_ce_o <= `ChipDisable;
        case(aluop_i)
            `EXE_LW_OP: begin
                mem_addr_o <= mem_addr_i;   //Ҫ���ʵĵ�ַ��Ϊִ�н׶�������ĵ�ַ
                mem_we <= `WriteDisable;    //��д����
                wdata_o <= mem_data_i;      
                mem_sel_o <= 4'b1111;       //��ȡȫ���ֽ�
                mem_ce_o <= `ChipEnable;    //Ҫ�������ݴ洢��
            end
            `EXE_SW_OP: begin
                mem_addr_o <= mem_addr_i;   //ͬ��
                mem_we <= `WriteEnable;
                mem_data_o <= reg2_i;       
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;    
            end
        endcase
     end 
end

endmodule
