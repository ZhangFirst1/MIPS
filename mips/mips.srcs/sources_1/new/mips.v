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
output wire rom_ce_o,               //ָ��洢��ʹ���ź�

//�����ӿ� ����RAM
input wire[`RegDataBus] ram_data_i, //�����ݴ洢����ȡ����
output wire[`RegDataBus] ram_addr_o,//Ҫ���ʵ����ݴ洢����ַ
output wire[`RegDataBus] ram_data_o,//Ҫд�����ݴ洢��������
output wire ram_we_o,               //�Ƿ�����ݴ洢��д����
output wire[3:0] ram_sel_o,         //�ֽ�ѡ���ź�
output wire ram_ce_o                //���ݴ洢��ʹ���ź�
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
wire id_is_in_delayslot_o;
wire[`RegDataBus] id_link_addr_o;
wire id_next_inst_in_delayslot_o;
wire[`RegDataBus] id_branch_target_address_o;
wire id_branch_flag_o;
wire[`RegDataBus] id_inst_o; // ����ָ�����ȡ���

// ����ID/EX��� �� ִ�н׶�EX���� �ı���
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegDataBus] ex_reg1_i;
wire[`RegDataBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;
wire[`RegDataBus] ex_link_address_i;
wire id_is_in_delayslot_i;
wire[`RegDataBus] ex_inst_i; //����ָ�����ȡ���

// ����EX��� �� EX/MEM���� �ı���
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegDataBus] ex_wdata_o;
wire[`AluOpBus] ex_aluop_o; //�ô�����
wire[`RegDataBus] ex_mem_addr_o; //�ô��ַ
wire[`RegDataBus] ex_reg2_o; //Ҫд�������

// ����EX/MEM��� �� �ô�׶�MEM���� �ı���
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegDataBus] mem_wdata_i;
wire[`AluOpBus] mem_aluop_i;  //�ô��ַ
wire[`RegDataBus] mem_mem_addr_i; //Ҫд������ݵĵ�ַ
wire[`RegDataBus] mem_reg2_i; //Ҫд�������

// ����MEM��� �� MEM/WB���� �ı���
//wire wb_wreg_o;
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegDataBus] mem_wdata_o;

// ����MEM/WB��� �� ��д�׶����� �ı���
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegDataBus] wb_wdata_i;

// ����CTRL��������� �ı���
// ����
wire id_stallreq_i;   //ID������ͣ
wire ex_stallreq_i;   //EX������ͣ
// ���
wire[5:0] ctrl_stall_o;      //ctrl���������Ĳ���

// pc_regʵ����
pc_reg U_PC(
    .clk(clk), .rst(rst), .pc(pc), .ce(rom_ce_o), .stall(ctrl_stall_o),
    //����׶�����������
    .branch_target_address_i(id_branch_target_address_o),
    .branch_flag_i(id_branch_flag_o)
);
assign rom_addr_o = pc; //ָ��洢���������ַ����pc��ֵ

// IF/IDʵ����
if_id if_id0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
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
    .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o), .ex_wreg_i(ex_wreg_o), .ex_aluop_i(ex_aluop_o),
    //MEM���� ��������������
    .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o), .mem_wreg_i(mem_wreg_o),
    //ID/EX���� �����ת
    .is_in_delayslot_i(id_is_in_delayslot_i),
    //����Regfile������
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    //�͵�Regfile������
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    //�͵�ID/EX����Ϣ
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .wd_o(id_wd_o), .wreg_o(id_wreg_o),
    .is_in_delayslot_o(id_is_in_delayslot_o), .link_addr_o(id_link_addr_o), .next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
    .inst_o(id_inst_o), //��ȡ���
    //�͵�PC����Ϣ
    .branch_target_address_o(id_branch_target_address_o), .branch_flag_o(id_branch_flag_o),
    //����ctrl
    .stallreq(id_stallreq_i)
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
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    //��ID ��������Ϣ
    .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_wd(id_wd_o), .id_wreg(id_wreg_o),
    .id_is_in_delayslot(id_is_in_delayslot_o), .id_link_address(id_link_addr_o), .next_inst_in_delayslot_i(id_next_inst_in_delayslot_o),
    .id_inst(id_inst_o), //��ȡ���
    //�͵�ִ��ģ��EX ����Ϣ
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i),
    .ex_is_in_delayslot(ex_is_in_delayslot_i),  .ex_link_address(ex_link_address_i),
    .ex_inst(ex_inst_i), //��ȡ���
    //�͵�ID����Ϣ
    .is_in_delayslot_o(id_is_in_delayslot_i)
);

// EXģ������
ex ex0(
    .rst(rst),
    // ��ID/EXģ�鴫�ݹ����ĵ���Ϣ
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
    .is_in_delayslot_i(ex_is_in_delayslot_i), .link_address_i(ex_link_address_i),
    .inst_i(ex_inst_i), //��ȡ���
    //�����EX/MEMģ�����Ϣ
    .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .aluop_o(ex_aluop_o), //��ȡ���
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o),
    //����ctrl
    .stallreq(ex_stallreq_i)
 );

// EX/MEMģ������
ex_mem ex_mem0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    // ����ִ�н׶�EXģ�����Ϣ
    .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_aluop(ex_aluop_o), //��ȡ���
    .ex_mem_addr(ex_mem_addr_o),
     .ex_reg2(ex_reg2_o),
    // �͵��ô�׶�MEMģ�����Ϣ
    .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_aluop(mem_aluop_i), //��ȡ���
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2(mem_reg2_i)
);

// MEMģ������
mem U_DM(
    .rst(rst),
    // ����EX/MEMģ�����Ϣ
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .aluop_i(mem_aluop_i), //��ȡ���
    .mem_addr_i(mem_mem_addr_i),
    .reg2_i(mem_reg2_i),
 
    // �͵�MEM/WBģ�����Ϣ
    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    
    //���Դ洢������Ϣ
    .mem_data_i(ram_data_i),
    
    //�͵��洢������Ϣ
    .mem_addr_o(ram_addr_o),    .mem_we_o(ram_we_o),
    .mem_sel_o(ram_sel_o),      .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o)
);
 
// MEM/WBģ������
mem_wb mem_wb0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    // ���Էô�׶�MEMģ�����Ϣ
    .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    // �͵���д�׶ε���Ϣ
    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

//CTRLģ��
ctrl ctrl0(
    //����ģ������
    .rst(rst), .stallreq_from_id(id_stallreq_i), .stallreq_from_ex(ex_stallreq_i),
    //�����ģ�����
    .stall(ctrl_stall_o)
);

endmodule

