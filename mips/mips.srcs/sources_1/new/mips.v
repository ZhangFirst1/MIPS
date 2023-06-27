`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:45:39
// Design Name: 
// Module Name: mips
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
//MIPS�����ļ�
`include "defines.v"

module mips(
input wire rst,
input wire clk,

input wire[`RegDataBus] rom_data_i, //��ָ��Ĵ���ȡ�õ�ָ��
output wire[`RegDataBus] rom_addr_o,//�����ָ��Ĵ����ĵ�ַ
output wire rom_ce_o                //ָ��洢��ʹ���ź�
    );
// ����IF/IDģ����� �� ����׶�IDģ������ �ı���
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstDataBus] id_inst_i;

// ��������׶�ID �� ͨ�üĴ���Regfileģ�� �ı���
wire reg1_read;
wire reg2_read;
wire[`RegDataBus] reg1_data;    //regfileģ������� ��һ���Ĵ����˿ڵ� ����
wire[`RegDataBus] reg2_data;    //regfileģ������� �ڶ����Ĵ����˿ڵ� ����
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// ��������׶�ID��� �� ID/EXģ������ �ı���
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegDataBus] id_reg1_o;
wire[`RegDataBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

// ����ID/EX��� �� ִ�н׶�EX���� �ı���
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegDataBus] ex_reg1_i;
wire[`RegDataBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

// ����EX��� �� EX/MEM���� �ı���
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegDataBus] ex_wdata_o;

// ����EX/MEM��� �� �ô�׶�MEM���� �ı���
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegDataBus] mem_wdata_i;

// ����MEM��� �� MEM/WB���� �ı���
//wire wb_wreg_o;
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegDataBus] mem_wdata_o;

// ����MEM/WB��� �� ��д�׶����� �ı���
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegDataBus] wb_wdata_i;

// pc_regʵ����
pc_reg U_PC(
    .clk(clk), .rst(rst), .pc(pc), .ce(rom_ce_o)
);
assign rom_addr_o = pc; //ָ��洢���������ַ����pc��ֵ

// IF/IDʵ����
if_id if_id0(
    .clk(clk), .rst(rst), 
    .if_pc(pc),//pc�����ĵ�ַ
    .if_inst(rom_data_i), //ȡ����ָ��
    .id_pc(id_pc_i), .id_inst(id_inst_i) //���ݵ�ID�׶�
);

// ����׶�IDʵ����
// ����˿ڹ�����ο�id�ļ��е�ע��
id id0(
    //IF/ID����
    .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i), 
    //EX���� ��������������
    .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o), .ex_wreg_i(ex_wreg_o),
    //MEM���� ��������������
    .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o), .mem_wreg_i(mem_wreg_o),
    //����Regfile������
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    //�͵�Regfile������
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    //�͵�ID/EX����Ϣ
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .wd_o(id_wd_o), .wreg_o(id_wreg_o)
);

// ͨ�üĴ���Regfileʵ����
regfile U_RF(
    .rst(rst), .clk(clk),
    .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i),
    .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
);

// ID/EXʵ����
id_ex id_ex0(
    .clk(clk), .rst(rst),
    //��ID ��������Ϣ
    .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_wd(id_wd_o), .id_wreg(id_wreg_o),
    //�͵�ִ��ģ��EX ����Ϣ
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i)
);

// EXģ������
ex ex0(
    .rst(rst),
    // ��ID/EXģ�鴫�ݹ����ĵ���Ϣ
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
    //�����EX/MEMģ�����Ϣ
    .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o)
 );

// EX/MEMģ������
ex_mem ex_mem0(
    .clk(clk), .rst(rst), 
    // ����ִ�н׶�EXģ�����Ϣ
    .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    // �͵��ô�׶�MEMģ�����Ϣ
    .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i)
);

// MEMģ������
mem U_DM(
    .rst(rst),
    // ����EX/MEMģ�����Ϣ
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
 
    // �͵�MEM/WBģ�����Ϣ
    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o)
);
 
// MEM/WBģ������
mem_wb mem_wb0(
    .clk(clk), .rst(rst),
    // ���Էô�׶�MEMģ�����Ϣ
    .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    // �͵���д�׶ε���Ϣ
    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

endmodule
