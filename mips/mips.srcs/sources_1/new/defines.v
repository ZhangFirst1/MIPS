`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 15:01:38
// Design Name: 
// Module Name: defines
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

//******************ȫ�ֺ궨��**********************//
`define RstEnable    1'b1         //��λ�ź���Ч
`define RstDisable   1'b0         //��λ�ź���Ч
`define Zero         32'h00000000 //32λ0
`define MarsZero     32'h00003000 //Mars�������
`define WriteEnable  1'b1         //ʹ�ܶ�д
`define WriteDisable 1'b0         //��ֹд
`define ReadEnable   1'b1         //ʹ�ܶ˶�
`define ReadDisable  1'b0         //��ֹ��
`define AluOpBus     7:0          //����׶ε����aluop_o�Ŀ��
`define AluSelBus    2:0          //����׶ε����alusel_o�Ŀ��
`define InstValid    1'b0         //ָ����Ч
`define InstInValid  1'b1        //ָ����Ч
`define True_v       1'b1        //�߼�"��"
`define False_v      1'b0        //�߼�"��"
`define ChipEnable   1'b1        //оƬʹ��
`define ChipDisable  1'b0        //оƬ��ֹ

//******************����ָ���**********************//
`define EXE_ORI      6'b001101   //ָ��ori��ָ����
`define EXE_ADDU     6'b100001   //ָ��ADDU��ָ����
`define EXE_SUBU     6'b100011   //ָ��SUBU��ָ����
`define EXE_BEQ      6'b000100   //ָ��BEQ��ָ����
`define EXE_JAL      6'b000011   //ָ��JAL��ָ����
`define EXE_LW       6'b100011   //ָ��LW��ָ����
`define EXE_SW       6'b101011   //ָ��SW��ָ����

`define EXE_SPECIAL_INST   6'b000000    //��������

//��ע�� �˴�������ָ���������MIPS32 Release1ָ� ���Ǳ�����MIPS-Lite1ָ�
//���������޸ı���λ�� ��Сָ���
//AluOp
`define EXE_OR_OP   8'b00100101   //������ָ����
`define EXE_NOP_OP  8'b00000000
`define EXE_ADDU_OP 8'b00100001
`define EXE_SUBU_OP 8'b00100011
`define EXE_JAL_OP  8'b01010000
`define EXE_BEQ_OP  8'b01010001
`define EXE_LW_OP   8'b11100011
`define EXE_SW_OP   8'b11101011
//AluSel
`define EXE_RES_LOGIC   3'b001     //�������Ӳ�����
`define EXE_RES_ARITHMETIC 3'b100	//��������
`define EXE_RES_NOP 3'b000
`define EXE_RES_JUMP_BRANCH 3'b110 //��תָ��
`define EXE_RES_LOAD_STORE 3'b111  //����ָ��

//******************�����ж�ָ���Ƿ�����ʱ�������Ƿ�Ϊ��ָ֧��**********************//
`define InDelaySlot    1'b1     //���ӳٲ���
`define NotInDelaySlot 1'b0     //����
`define Branch 1'b1
`define NotBranch 1'b0

//******************�洢��ROM���**********************//
`define InstAddrBus 31:0 //ROM�ĵ�ַ���߿��
`define InstDataBus 31:0 //ROM���������߿��
`define InstMemNum 1023   //ָ��洢�������С
`define InstMemNumLog2 10   //ָ��洢����ʵ�ʵ�ַ���

//******************ͨ�üĴ���RegFile���**********************//
`define RegAddrBus  4:0         //��ַ�߿��
`define RegDataBus  31:0        //�����߿��
`define RegWidth    32          //ͨ�üĴ������
`define DoubleRegWidth 64       //�������
`define DoubleRegDataBus 63:0   //���������߿��
`define RegNum          32      //ͨ�üĴ�������
`define RegNumLog2      5       //Ѱַͨ�üĴ���λ��
`define NOPRegAddr      5'b00000