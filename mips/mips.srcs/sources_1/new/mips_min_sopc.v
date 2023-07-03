`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 16:13:23
// Design Name: 
// Module Name: mips_min_sopc
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
//��СSOPC
`include "defines.v"

module mips_min_sopc(
input wire clk,
input wire rst
    );
//����ָ��洢�����
wire[`InstAddrBus] inst_addr;
wire[`InstDataBus] inst;
wire rom_ce;
//�������ݼĴ������
 wire mem_we_i;
 wire[`RegDataBus] mem_addr_i;
 wire[`RegDataBus] mem_data_i;
 wire[`RegDataBus] mem_data_o;
 wire[3:0] mem_sel_i;  
 wire mem_ce_i;  
//ʵ����MIPS
mips mips0(
    .clk(clk), .rst(rst),
    .rom_addr_o(inst_addr),
     .rom_data_i(inst),
    .rom_ce_o(rom_ce),
    .ram_we_o(mem_we_i),
    .ram_addr_o(mem_addr_i),
    .ram_sel_o(mem_sel_i),
    .ram_data_o(mem_data_i),
    .ram_data_i(mem_data_o),
    .ram_ce_o(mem_ce_i)
);

//ʵ����ָ��洢��ROM
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr), .inst(inst)
);
//ʵ�������ݴ洢��RAM
	data_ram data_ram0(
    .clk(clk),
    .we(mem_we_i),
    .addr(mem_addr_i),
    .sel(mem_sel_i),
    .data_i(mem_data_i),
    .data_o(mem_data_o),
    .ce(mem_ce_i)        
);
endmodule
