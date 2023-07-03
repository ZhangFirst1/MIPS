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
//MIPS顶层文件
`include "defines.v"

module mips(
input wire rst,
input wire clk,

input wire[`RegDataBus] rom_data_i, //从指令寄存器取得的指令
output wire[`RegDataBus] rom_addr_o,//输出到指令寄存器的地址
output wire rom_ce_o,               //指令存储器使能信号

//新增接口 连接RAM
input wire[`RegDataBus] ram_data_i, //从数据存储器读取数据
output wire[`RegDataBus] ram_addr_o,//要访问的数据存储器地址
output wire[`RegDataBus] ram_data_o,//要写入数据存储器的数据
output wire ram_we_o,               //是否对数据存储器写操作
output wire[3:0] ram_sel_o,         //字节选择信号
output wire ram_ce_o                //数据存储器使能信号
    );
// 连接IF/ID模块输出 与 译码阶段ID模块输入 的变量
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstDataBus] id_inst_i;

// 连接译码阶段ID 与 通用寄存器Regfile模块 的变量
wire reg1_read;
wire reg2_read;
wire[`RegDataBus] reg1_data;    //regfile模块输入的 第一个寄存器端口的 输入
wire[`RegDataBus] reg2_data;    //regfile模块输入的 第二个寄存器端口的 输入
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// 连接译码阶段ID输出 与 ID/EX模块输入 的变量
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
wire[`RegDataBus] id_inst_o; // 传送指令与存取相关

// 连接ID/EX输出 与 执行阶段EX输入 的变量
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegDataBus] ex_reg1_i;
wire[`RegDataBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;
wire[`RegDataBus] ex_link_address_i;
wire id_is_in_delayslot_i;
wire[`RegDataBus] ex_inst_i; //传送指令与存取相关

// 连接EX输出 与 EX/MEM输入 的变量
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegDataBus] ex_wdata_o;
wire[`AluOpBus] ex_aluop_o; //访存类型
wire[`RegDataBus] ex_mem_addr_o; //访存地址
wire[`RegDataBus] ex_reg2_o; //要写入的数据

// 连接EX/MEM输出 与 访存阶段MEM输入 的变量
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegDataBus] mem_wdata_i;
wire[`AluOpBus] mem_aluop_i;  //访存地址
wire[`RegDataBus] mem_mem_addr_i; //要写入的数据的地址
wire[`RegDataBus] mem_reg2_i; //要写入的数据

// 连接MEM输出 与 MEM/WB输入 的变量
//wire wb_wreg_o;
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegDataBus] mem_wdata_o;

// 连接MEM/WB输出 与 回写阶段输入 的变量
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegDataBus] wb_wdata_i;

// 连接CTRL与各个部件 的变量
// 输入
wire id_stallreq_i;   //ID请求暂停
wire ex_stallreq_i;   //EX请求暂停
// 输出
wire[5:0] ctrl_stall_o;      //ctrl控制其他的部件

// pc_reg实例化
pc_reg U_PC(
    .clk(clk), .rst(rst), .pc(pc), .ce(rom_ce_o), .stall(ctrl_stall_o),
    //译码阶段送来的数据
    .branch_target_address_i(id_branch_target_address_o),
    .branch_flag_i(id_branch_flag_o)
);
assign rom_addr_o = pc; //指令存储器的输入地址就是pc的值

// IF/ID实例化
if_id if_id0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    .if_pc(pc),//pc产生的地址
    .if_inst(rom_data_i), //取出的指令
    .id_pc(id_pc_i), .id_inst(id_inst_i) //传递到ID阶段
);

// 译码阶段ID实例化
// 具体端口功能请参考id文件中的注释
id id0(
    //IF/ID传入
    .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i), 
    //EX传入 解决数据相关问题
    .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o), .ex_wreg_i(ex_wreg_o), .ex_aluop_i(ex_aluop_o),
    //MEM传入 解决数据相关问题
    .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o), .mem_wreg_i(mem_wreg_o),
    //ID/EX传入 解决跳转
    .is_in_delayslot_i(id_is_in_delayslot_i),
    //来自Regfile的输入
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    //送到Regfile的数据
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    //送到ID/EX的信息
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .wd_o(id_wd_o), .wreg_o(id_wreg_o),
    .is_in_delayslot_o(id_is_in_delayslot_o), .link_addr_o(id_link_addr_o), .next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
    .inst_o(id_inst_o), //存取相关
    //送到PC的信息
    .branch_target_address_o(id_branch_target_address_o), .branch_flag_o(id_branch_flag_o),
    //传到ctrl
    .stallreq(id_stallreq_i)
);

// 通用寄存器Regfile实例化
regfile U_RF(
    .rst(rst), .clk(clk),
    .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i),
    .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
);

// ID/EX实例化
id_ex id_ex0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    //从ID 传来的信息
    .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_wd(id_wd_o), .id_wreg(id_wreg_o),
    .id_is_in_delayslot(id_is_in_delayslot_o), .id_link_address(id_link_addr_o), .next_inst_in_delayslot_i(id_next_inst_in_delayslot_o),
    .id_inst(id_inst_o), //存取相关
    //送到执行模块EX 的信息
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i),
    .ex_is_in_delayslot(ex_is_in_delayslot_i),  .ex_link_address(ex_link_address_i),
    .ex_inst(ex_inst_i), //存取相关
    //送到ID的信息
    .is_in_delayslot_o(id_is_in_delayslot_i)
);

// EX模块例化
ex ex0(
    .rst(rst),
    // 从ID/EX模块传递过来的的信息
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
    .is_in_delayslot_i(ex_is_in_delayslot_i), .link_address_i(ex_link_address_i),
    .inst_i(ex_inst_i), //存取相关
    //输出到EX/MEM模块的信息
    .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .aluop_o(ex_aluop_o), //存取相关
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o),
    //传到ctrl
    .stallreq(ex_stallreq_i)
 );

// EX/MEM模块例化
ex_mem ex_mem0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    // 来自执行阶段EX模块的信息
    .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_aluop(ex_aluop_o), //存取相关
    .ex_mem_addr(ex_mem_addr_o),
     .ex_reg2(ex_reg2_o),
    // 送到访存阶段MEM模块的信息
    .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_aluop(mem_aluop_i), //存取相关
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2(mem_reg2_i)
);

// MEM模块例化
mem U_DM(
    .rst(rst),
    // 来自EX/MEM模块的信息
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .aluop_i(mem_aluop_i), //存取相关
    .mem_addr_i(mem_mem_addr_i),
    .reg2_i(mem_reg2_i),
 
    // 送到MEM/WB模块的信息
    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    
    //来自存储器的信息
    .mem_data_i(ram_data_i),
    
    //送到存储器的信息
    .mem_addr_o(ram_addr_o),    .mem_we_o(ram_we_o),
    .mem_sel_o(ram_sel_o),      .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o)
);
 
// MEM/WB模块例化
mem_wb mem_wb0(
    .clk(clk), .rst(rst), .stall(ctrl_stall_o),
    // 来自访存阶段MEM模块的信息
    .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    // 送到回写阶段的信息
    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

//CTRL模块
ctrl ctrl0(
    //各个模块输入
    .rst(rst), .stallreq_from_id(id_stallreq_i), .stallreq_from_ex(ex_stallreq_i),
    //向各个模块输出
    .stall(ctrl_stall_o)
);

endmodule

