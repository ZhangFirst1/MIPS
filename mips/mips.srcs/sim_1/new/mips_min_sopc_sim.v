`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 16:24:07
// Design Name: 
// Module Name: mips_min_sopc_sim
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


module mips_min_sopc_sim();
reg CLOCK_50; 
 reg rst; 
 
 // ÿ��10ns��CLOCK_50�źŷ�תһ�Σ�����һ��������20ns����Ӧ50MHz 
initial begin 
 CLOCK_50 = 1'b0; 
 forever #10 CLOCK_50 = ~CLOCK_50; 
end 
 
 // ���ʱ�̣���λ�ź���Ч���ڵ�195ns����λ�ź���Ч����СSOPC��ʼ����
 // ����1000ns����ͣ����
initial begin 
 rst = 1'b1; 
 #195 rst= 1'b0; 
 #1000 $stop; 
end 
 
 // ������СSOPC 
mips_min_sopc mips_min_sopc0( 
 .clk(CLOCK_50), 
 .rst(rst) 
); 
endmodule
