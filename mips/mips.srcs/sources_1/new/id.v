`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/25 20:14:05
// Design Name: 
// Module Name: id
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
//IDģ��
//��ָ��������룬�õ�������������͡������͡�Դ������1��Դ������2��Ҫд���Ŀ�ļĴ�����ַ����Ϣ
`include "defines.v"

module id(
input wire rst,     //��λ
input wire[`InstAddrBus] pc_i,    //����׶�ָ���Ӧ�ĵ�ַ
input wire[`InstDataBus] inst_i,  //����׶ε�ָ��(32bit)

//��ȡ��regfile��ֵ
input wire[`RegDataBus] reg1_data_i,//regfileģ������� ��һ���Ĵ����˿ڵ� ����
input wire[`RegDataBus] reg2_data_i,//regfileģ������� �ڶ����Ĵ����˿ڵ� ����

//�����regfile����Ϣ
output reg reg1_read_o,         //regfileģ��� ��һ�����Ĵ����˿ڵ� ʹ���ź�
output reg reg2_read_o,         //regfileģ��� �ڶ������Ĵ����˿ڵ� ʹ���ź�
output reg[`RegAddrBus] reg1_addr_o,         //regfileģ��� ��һ�����Ĵ����˿ڵ� ��ַ�ź�
output reg[`RegAddrBus] reg2_addr_o,         //regfileģ��� �ڶ������Ĵ����˿ڵ� ��ַ�ź�

/************������Ϊ�˽�������������Ĵ�ʩ��ʹ������ǰ�ƣ�*************/
//ִ�н׶�ָ�������������ָ��������أ�
input wire ex_wreg_i,               //���� ִ�н׶� �Ƿ�Ҫд��Ŀ�ļĴ���
input wire[`RegDataBus] ex_wdata_i,  //���� ִ�н׶� Ҫд��Ŀ�ļĴ���������
input wire[`RegAddrBus] ex_wd_i,    //���� ִ�н׶� Ŀ�ļĴ�����ַ
//�ô�׶ν����������һ��ָ��������أ�
input wire mem_wreg_i,              //ͬ�� �����ڷô�׶�
input wire[`RegDataBus] mem_wdata_i,
input wire[`RegAddrBus] mem_wd_i,

//�͵�ִ�н׶ε���Ϣ
output reg[`AluOpBus] aluop_o,  //����׶ε�ָ��Ҫ���е������������
output reg[`AluSelBus] alusel_o,//����׶ε�ָ��Ҫ���е����������
output reg[`RegDataBus] reg1_o, //����׶�Դ������1��32λ��
output reg[`RegDataBus] reg2_o, //����׶�ԭ������2
output reg[`RegAddrBus] wd_o,   //����׶�Ҫд���Ŀ�ļĴ�����ַ��5λ��
output reg wreg_o,               //����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
output wire[`RegDataBus] inst_o,     //�����ǰ��������׶ε�ָ��

/************************����Ϊ��ʵ��ת��ָ��***********************************/
input wire is_in_delayslot_i,           //����һ����ת��ָ���ô��һ��ָ���������׶Σ�is_in_delayslot_iΪtrue����ʾ���ӳٲ�ָ��
output reg branch_flag_o,               //�Ƿ���ת��
output reg is_in_delayslot_o,           //��ǰ����׶ε�ָ���Ƿ����ӳٲ�
output reg next_inst_in_delayslot_o,    //��һ����������׶ε�ָ���Ƿ�λ���ӳٲ�
output reg[`RegDataBus] link_addr_o,    //ת��ָ��Ҫ����ķ��ص�ַ
output reg[`RegDataBus] branch_target_address_o,    //ת�Ƶ���Ŀ���ַ

//��ͣ
output wire stallreq
    );
//ȡ��ָ���ָ���롢������
//����ori �ж�26-31λ��ֵ�����ж�
wire[5:0] op = inst_i[31:26];   //op�ֶ�
wire[4:0] op2 = inst_i[10:6];   //shamt�ֶ�
wire[5:0] op3 = inst_i[5:0];    //func�ֶ�
wire[4:0] op4 = inst_i[20:16];  //rt�ֶ�
//��ͣ
assign stallreq = `NoStop;

//����ָ��ִ����Ҫ��������
reg[`RegDataBus] imm;

//ָʾָ���Ƿ���Ч
reg instValid;

//����׶ε�ָ��
assign inst_o = inst_i;

//��תָ���������
wire[`RegDataBus] pc_plus_8;
wire[`RegDataBus] pc_plus_4;
wire[`RegDataBus] offset_ltwo_extend;  //��ָ֧��offset������λ������չ��32λ

assign pc_plus_8 = pc_i + 8;    //���浱ǰ����׶�ָ������2��ָ��ĵ�ַ
assign pc_plus_4 = pc_i + 4;    //���浱ǰ����׶�ָ������1��ָ��ĵ�ַ
assign offset_ltwo_extend = {{14{inst_i[15]}}, inst_i[15:0], 2'b00}; //�������ٷ�����չ

/*******************1.��ָ������***********************/
always @(*) begin
    if (rst == `RstEnable) begin    //��λ����
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instValid <= `InstInValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
        link_addr_o <= `MarsZero;   //���ص�ַ
        branch_target_address_o <= `MarsZero;   //Ŀ���ַ
        branch_flag_o <= `NotBranch;        //ľ��ת��
        next_inst_in_delayslot_o <= `NotInDelaySlot; 
    end else begin                  //�Ǹ�λ
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11];  //rd�ֶ�
        wreg_o <= `WriteDisable;
        instValid <= `InstInValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];   //Ĭ��ͨ��Regfile���˿�1��ȡ�ļĴ�����ַ
        reg2_addr_o <= inst_i[20:16];   //Ĭ��ͨ��Regfile���˿�2��ȡ�ļĴ�����ַ
        imm <= `Zero;
        link_addr_o <= `MarsZero;
        branch_target_address_o <= `MarsZero;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
    case (op)
        `EXE_ORI:begin      //����op��ֵ�ж��Ƿ�Ϊoriָ��
            wreg_o <= `WriteEnable; //ori��Ҫ���д��Ŀ�ļĴ���������WriteEnable
            aluop_o <= `EXE_OR_OP;  //������������� or
            alusel_o <= `EXE_RES_LOGIC;//�����������߼�����
            reg1_read_o <= 1'b1; //��Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ���
            reg2_read_o <= 1'b0; //����Ҫͨ��2��
            imm <= {16'h0, inst_i[15:0]};   //ָ��ִ����Ҫ�������� {}Ϊ����ƴ��
            wd_o <= inst_i[20:16];  //ִ��ָ��Ҫд��Ŀ�ļĴ�����ַrt
            instValid <= `InstValid;    //oriָ������Чָ��
        end
        `EXE_SPECIAL_INST: begin    //�Ƿ�ΪSPECIAL��addu��subu��
            case(op2)
                5'b00000: begin      //λ��Ϊ0
                    case(op3)
                        `EXE_ADDU: begin    //ADDUָ��
                            wreg_o <= `WriteEnable;     //����ע����ο�ori
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instValid <= `InstValid;
                        end
                        `EXE_SUBU: begin    //SUBUָ��
                             wreg_o <= `WriteEnable;     //����ע����ο�ori
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instValid <= `InstValid;                       
                        end                      
                    endcase //op3              
                end     //5'b00000
            endcase    //op2
        end //EXE_SPECIAL_INST
        `EXE_JAL: begin     //JALָ��
            wreg_o <= `WriteEnable;     //jal��Ҫ���淵�ص�ַ��wreg_oΪWriteEnable
            aluop_o <= `EXE_JAL_OP;
            alusel_o <= `EXE_RES_JUMP_BRANCH;
            reg1_read_o <= 1'b0;        //�����ȡͨ�üĴ���
            reg2_read_o <= 1'b0;
            wd_o <= 5'b11111;           //jal�����ص�ַд���Ĵ���$31��
            link_addr_o <= pc_plus_8;   //���÷��ص�ַΪ��2��ָ��ĵ�ַ
            branch_flag_o <= `Branch;   //�Ǿ���ת��ָ��
            next_inst_in_delayslot_o <= `InDelaySlot; //��һ��ָ�����ӳٲ���
            instValid = `InstValid;
            //branch_target_address_o <= {pc_plus_4[31:28],2'b00, inst_i[25:2], 2'b00}; //��ת��ַ
            branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
        end
        `EXE_BEQ: begin     //BEQָ��
            wreg_o <= `WriteDisable;    //����Ҫ���淵�ص�ַF
            aluop_o <= `EXE_BEQ_OP;     //��������
            alusel_o <= `EXE_RES_JUMP_BRANCH;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            instValid = `InstValid;
            if (reg1_o == reg2_o) begin //����beg��ת����
                branch_target_address_o <= pc_plus_4 + offset_ltwo_extend;  //��ת��ַ
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;   // ��һ��ָ�����ӳٲ���
            end 
        end
        `EXE_LW: begin
            wreg_o <= `WriteEnable;     //��Ҫ�����ؽ��д��Ŀ�ļĴ���
            aluop_o <= `EXE_LW_OP;
            alusel_o <= `EXE_RES_LOAD_STORE;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            wd_o <= inst_i[20:16];      //Ŀ�ļĴ���Ϊָ���20:16λ
            instValid <= `InstValid;
        end
        `EXE_SW: begin
            wreg_o <= `WriteDisable;    //����д��Ĵ���
            aluop_o <= `EXE_SW_OP;
            alusel_o <= `EXE_RES_LOAD_STORE; 
            reg1_read_o <= 1'b1;        //����׶�reg1_o����base�Ĵ�����ֵ
            reg2_read_o <= 1'b1;        //reg2_o��rt�Ĵ�����ֵ
            instValid <= `InstValid;
        end
        default: begin
        end
    endcase //case op
    end //else begin
end //always

/*******************2.ȷ��Դ������1***********************/

always @ (*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `Zero;
    //����������if���ڽ���������������
    //���Regfileģ����˿�1Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд�ļĴ�����ֱ�Ӱ�ִ�н������reg1_o
    end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o <= ex_wdata_i;
    //���Regfileģ����˿�1Ҫ��ȡ�ļĴ����Ƿô�׶�Ҫд�ļĴ�����ֱ�Ӱ�ִ�н����reg1_o
    end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o <= mem_wdata_i;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile���˿�1�����ֵ
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm;          //������
    end else begin
        reg1_o <= `Zero;
    end
end

/*******************3.ȷ��Դ������2***********************/
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `Zero;
    //����������if���ڽ���������������
    //���Regfileģ����˿�2Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд�ļĴ�����ֱ�Ӱ�ִ�н������reg1_o
    end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o <= ex_wdata_i;
    //���Regfileģ����˿�2Ҫ��ȡ�ļĴ����Ƿô�׶�Ҫд�ļĴ�����ֱ�Ӱ�ִ�н����reg1_o
    end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o <= mem_wdata_i;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile���˿�1�����ֵ
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm;          //������
    end else begin
        reg2_o <= `Zero;
    end
end

/********************�жϵ�ǰָ���Ƿ����ӳٲ�����******************************/
always @(*) begin
    if(rst == `RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end

endmodule
