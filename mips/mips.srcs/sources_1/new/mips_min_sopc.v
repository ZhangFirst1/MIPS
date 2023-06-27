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
//����ָ��洢��
wire[`InstAddrBus] inst_addr;
wire[`InstDataBus] inst;
wire rom_ce;

//ʵ����MIPS
mips mips0(
    .clk(clk), .rst(rst),
    .rom_addr_o(inst_addr), .rom_data_i(inst),
    .rom_ce_o(rom_ce)
);

//ʵ����ָ��洢��ROM
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr), .inst(inst)
);

endmodule
