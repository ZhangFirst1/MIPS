`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 09:38:01
// Design Name: 
// Module Name: ex
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

//ִ��ģ��
/*��ID/EXģ��õ���������alusel_i������������aluop_i��Դ������reg1_i��
Դ������reg2_i��Ҫд��Ŀ�ļĴ�����ַwd_i��������Щ���ݽ�������*/
//��ע�� �˴�Ϊ���幦��ʵ��ģ�� ����ӹ��ܺ���ע�������Ӧע��
//Ŀǰ�Ѿ�ʵ�� ori 
`include "defines.v"

module ex(
input wire rst,
//ID/EXģ�鴫�ݵ���Ϣ
input wire[`AluOpBus] aluop_i,  //��������
input wire[`AluSelBus] alusel_i,//����������
input wire[`RegDataBus] reg1_i,//Դ������1
input wire[`RegDataBus] reg2_i,//Դ������2
input wire[`RegAddrBus] wd_i,   //Ŀ�ļĴ���
input wire wreg_i,              //�Ƿ���Ŀ�ļĴ���

//ִ�н��
output reg[`RegAddrBus] wd_o,   //ִ�н׶ε�ָ��Ҫд��� Ŀ�ļĴ�����ַ
output reg wreg_o,              //�Ƿ���Ŀ�ļĴ���
output reg[`RegDataBus] wdata_o //����Ҫд��Ŀ�ļĴ����� ֵ
    );
// �߼�����Ľ��
reg[`RegDataBus] logicout;

// ��������
reg[`RegDataBus] arithmetic_res;           //������
wire[`RegDataBus] reg2_i_mux;   //����ڶ����������Ĳ���
wire[`RegDataBus] res_sum;      //�ӷ����

/*************************1.����Ӽ������********************************/
//1.1���޷��ż���reg2_i_mux���ڵڶ�����reg2_i�Ĳ��� ����reg2_i_mux���ڵڶ���������reg2_i
assign reg2_i_mux = (aluop_i == `EXE_SUBU_OP) ? (~reg2_i) + 1 : reg2_i; //ȡ����1
//1.2������
assign res_sum = reg1_i + reg2_i_mux;
//1.3���ݲ�ͬ�����res��ֵ
always @(*) begin
    if(rst == `RstEnable) begin
        arithmetic_res <= `Zero;
    end else begin
        case(aluop_i)   //��������
            `EXE_ADDU_OP: begin
                arithmetic_res <= res_sum;  //�ӷ�
            end //EXE_ADDU_OP
            `EXE_SUBU_OP: begin
                arithmetic_res <= res_sum;  //����
            end
        endcase
    end // else
end //always

/*************************2.�߼�������********************************/
/***************2.1����aluop_i�����������ͽ�������********************/    
always @(*) begin
    if(rst == `RstEnable) begin
        logicout <= `Zero;
    end else begin
        case(aluop_i)
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;    //ʵ�� �� ����
            end
            default: begin
                logicout <= `Zero;
            end //default
        endcase
    end//else
end//always

/*************** last.����alusel_iѡ��һ��������Ϊ���ս��********************/   
always @(*) begin
    wd_o <= wd_i;   //Ҫд��Ŀ�ļĴ���
    //�޷��ж��޷��żӼ����Ƿ���� ����������Ƿ��д
    wreg_o <= wreg_i;   //�Ƿ�Ҫд
    case (alusel_i)
        `EXE_RES_LOGIC: begin       //�߼����㣬д��������
            wdata_o <= logicout;    
        end
        `EXE_RES_ARITHMETIC: begin  //�������㣬д��������
            wdata_o <= arithmetic_res;
        end
        default: begin
            wdata_o <= `Zero;
        end
    endcase
end //always

endmodule
