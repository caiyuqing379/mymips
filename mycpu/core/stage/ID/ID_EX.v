`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 21:23:17
// Design Name: 
// Module Name: ID_EX
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

`include "../../define/defines.v"

module ID_EX(
	input wire clk,
	input wire reset,
	input wire flush,
	input wire [`StallBus] stall,
	//从译码阶段传递的信息
	input wire[`AluFuncBus]    id_func,
	input wire[`InstShamtBus]  id_shamt,
	input wire[`RegBus]        id_reg1,
	input wire[`RegBus]        id_reg2,
    input wire                 id_mem_re,
    input wire                 id_mem_we,
    input wire                 id_mem_sign_ext_flag,
    input wire[`MemSel]        id_mem_sel,
    input wire[`DataBus]       id_mem_wdata,
	input wire[`RegAddrBus]    id_waddr,
	input wire[`RegWriteBus]   id_we,	
    input wire[`RegBus]        id_link_addr,
    input wire                 id_in_delayslot,
    input wire                 next_in_delayslot_i,
    input wire                 id_cp0_we,
    input wire                 id_cp0_re,
    input wire[`CP0RegAddrBus] id_cp0_addr,
    input wire[`RegBus]        id_cp0_wdata,
    input wire[`EXC_TYPE_BUS]  id_exception_type,
    input wire[`InstAddrBus]   id_current_inst_addr,
	//传递到执行阶段的信息
	output wire[`AluFuncBus]    ex_func,
	output wire[`InstShamtBus]  ex_shamt,
	output wire[`RegBus]        ex_reg1,
	output wire[`RegBus]        ex_reg2,	
    output wire                 ex_mem_re, 
    output wire                 ex_mem_we,   
    output wire                 ex_mem_sign_ext_flag,  
    output wire[`MemSel]        ex_mem_sel,  
    output wire[`DataBus]       ex_mem_wdata,
	output wire[`RegAddrBus]    ex_waddr,
	output wire[`RegWriteBus]   ex_we,
    output wire[`RegBus]        ex_link_addr,
    output wire                 ex_in_delayslot,
    output wire                 in_delayslot_o,
    output wire                 ex_cp0_we,
    output wire                 ex_cp0_re,
    output wire[`CP0RegAddrBus] ex_cp0_addr,
    output wire[`RegBus]        ex_cp0_wdata,
    output wire[`EXC_TYPE_BUS]  ex_exception_type,
    output wire[`InstAddrBus]   ex_current_inst_addr
);

    FF #(`OpWidth)            ff1(clk,reset,flush,stall[2],stall[3],id_func,ex_func);
    FF #5                     ff2(clk,reset,flush,stall[2],stall[3],id_shamt,ex_shamt);
    FF #(`RegWidth)           ff4(clk,reset,flush,stall[2],stall[3],id_reg1,ex_reg1);
	FF #(`RegWidth)           ff5(clk,reset,flush,stall[2],stall[3],id_reg2,ex_reg2);
	FF #1                     ff6(clk,reset,flush,stall[2],stall[3],id_mem_re,ex_mem_re);
	FF #1                     ff7(clk,reset,flush,stall[2],stall[3],id_mem_we,ex_mem_we);
	FF #1                     ff8(clk,reset,flush,stall[2],stall[3],id_mem_sign_ext_flag,ex_mem_sign_ext_flag);
	FF #4                     ff9(clk,reset,flush,stall[2],stall[3],id_mem_sel,ex_mem_sel);
	FF #(`RegWidth)           ff10(clk,reset,flush,stall[2],stall[3],id_mem_wdata,ex_mem_wdata);
	FF #(`RegNumLog2)         ff11(clk,reset,flush,stall[2],stall[3],id_waddr,ex_waddr);
	FF #1                     ff12(clk,reset,flush,stall[2],stall[3],id_we,ex_we);
    FF #(`RegWidth)           ff13(clk,reset,flush,stall[2],stall[3],id_link_addr,ex_link_addr);
    FF #1                     ff14(clk,reset,flush,stall[2],stall[3],id_in_delayslot,ex_in_delayslot);
    FF #1                     ff15(clk,reset,flush,stall[2],stall[3],next_in_delayslot_i,in_delayslot_o);
    FF #1                     ff16(clk,reset,flush,stall[2],stall[3],id_cp0_we,ex_cp0_we);
    FF #1                     ff17(clk,reset,flush,stall[2],stall[3],id_cp0_re,ex_cp0_re);
    FF #8                     ff18(clk,reset,flush,stall[2],stall[3],id_cp0_addr,ex_cp0_addr);
    FF #(`RegWidth)           ff19(clk,reset,flush,stall[2],stall[3],id_cp0_wdata,ex_cp0_wdata);
    FF #(`EXC_TYPE_BUS_WIDTH) ff20(clk,reset,flush,stall[2],stall[3],id_exception_type,ex_exception_type);
    FF #(`InstAddrWidth)      ff21(clk,reset,flush,stall[2],stall[3],id_current_inst_addr,ex_current_inst_addr);
	
endmodule
