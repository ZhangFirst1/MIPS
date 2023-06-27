`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 16:30:29
// Design Name: 
// Module Name: regfile
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

//Regfile ģ��
//ʵ��32��32λͨ�üĴ���������ͬʱ���������Ĵ�����������һ���Ĵ���д����
`include "defines.v"

module regfile(
input wire clk,
input wire rst,
//д�˿�
input wire we,                  //дʹ���ź�
input wire[`RegAddrBus] waddr,  //Ҫд��ļĴ�����ַ
input wire[`RegDataBus] wdata,  //Ҫд�������
//���˿�1
input wire re1,
input wire[`RegAddrBus] raddr1, //��һ�����Ĵ����˿ڶ�ȡ�ļĴ�����ַ
output reg[`RegDataBus] rdata1, //��һ�����Ĵ����˿�����Ĵ���ֵ
//���˿�2
input wire re2,
input wire[`RegAddrBus] raddr2, //ͬ��
output reg[`RegDataBus] rdata2
    );
/* 32��32λ�Ĵ��� */
(* MARK_DEBUG="true" *)reg[`RegDataBus] regs[0:`RegNum-1]; //��ά����

/* д���� */
always @(posedge clk) begin
    if (rst == `RstDisable) begin   //��λ�ź���Ч
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin //ʹ���ź���Ч �� д�����Ĵ�����Ϊ0(�涨$0ֻ��Ϊ0)
                regs[waddr] <= wdata;   //��д�������ݱ��浽Ŀ��Ĵ���
            end
        end
    end

/* ���˿�1���� */
always @(*) begin
    if(rst == `RstEnable) begin //��λ�ź���Ч ��һ�����Ĵ����˿����ʼ��Ϊ��
        rdata1 <= `Zero;
    end else if(raddr1 == `RegNumLog2'h0) begin  //��λ�ź���Ч ��0�˿�
        rdata1 <= `Zero;
    end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //����д��ͬһ���Ĵ��� ֱ�Ӹ�ֵ��һ����д��
        rdata1 <= wdata;
    end else if(re1 == `ReadEnable) begin   //������������ ������ȡ
        rdata1 <= regs[raddr1];
    end else begin  //����������˿ڲ���ʹ�ã� ֱ�����0
        rdata1 <= `Zero;
    end   
end

/* ���˿�2���� */
always @(*) begin
    if(rst == `RstEnable) begin //��λ�ź���Ч ��һ�����Ĵ����˿����ʼ��Ϊ��
        rdata2 <= `Zero;
    end else if(raddr2 == `RegNumLog2'h0) begin  //��λ�ź���Ч ��0�˿�
        rdata2 <= `Zero;
    end else if((raddr2 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //����д��ͬһ���Ĵ��� ֱ�Ӹ�ֵ��һ����д��
        rdata2 <= wdata;
    end else if(re1 == `ReadEnable) begin   //������������ ������ȡ
        rdata2 <= regs[raddr2];
    end else begin  //����������˿ڲ���ʹ�ã� ֱ�����0
        rdata2 <= `Zero;
    end   
end

endmodule
