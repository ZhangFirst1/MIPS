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

/***************1.����aluop_i�����������ͽ������㣨��ʱֻ�л�********************/    
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

/***************1.����alusel_iѡ��һ��������Ϊ���ս������ʱֻ�л�********************/   
always @(*) begin
    wd_o <= wd_i;   //Ҫд��Ŀ�ļĴ���
    wreg_o <= wreg_i;   //�Ƿ�Ҫд
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;    //���������
        end
        default: begin
            wdata_o <= `Zero;
        end
    endcase
end //always

endmodule
