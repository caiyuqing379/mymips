`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 21:50:05
// Design Name: 
// Module Name: EX_MEM
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

module EX_MEM(
	input wire clk,
    input wire reset,
    input wire flush,
    input wire [`StallBus] stall,
    //来自执行阶段的信息    
    input wire              ex_mem_re,
    input wire              ex_mem_we,
    input wire              ex_mem_sign_ext_flag,
    input wire[`MemSel]     ex_mem_sel,
    input wire[`DataBus]    ex_mem_wdata,
    input wire[`RegAddrBus] ex_waddr,
    input wire[`RegWriteBus] ex_we,
    input wire[`RegBus]     ex_wdata,  
    input wire[`RegBus]     ex_hi,
    input wire[`RegBus]     ex_lo,
    input wire              ex_we_hilo,  
    input wire                 ex_cp0_we,
    input wire[`CP0RegAddrBus] ex_cp0_waddr,
    input wire[`RegBus]        ex_cp0_wdata,  
    input wire[`EXC_TYPE_BUS]  ex_exception_type,
    input wire[`InstAddrBus]   ex_current_inst_addr,
    input wire                 ex_in_delayslot,
    //送到访存阶段的信息
    output wire               m_mem_re, 
    output wire               m_mem_we,   
    output wire               m_mem_sign_ext_flag,  
    output wire[`MemSel]      m_mem_sel,  
    output wire[`DataBus]     m_mem_wdata,
    output wire[`RegAddrBus]  mem_waddr,
    output wire[`RegWriteBus] mem_we,
    output wire[`RegBus]      mem_wdata,
    output wire[`RegBus]      mem_hi,
    output wire[`RegBus]      mem_lo,
    output wire               mem_we_hilo,
    output wire                 mem_cp0_we,
    output wire[`CP0RegAddrBus] mem_cp0_waddr,
    output wire[`RegBus]        mem_cp0_wdata,
    output wire[`EXC_TYPE_BUS]  mem_exception_type,
    output wire[`InstAddrBus]   mem_current_inst_addr,
    output wire                 mem_in_delayslot
);

	FF #1                     ff1(clk,reset,flush,stall[3],stall[4],ex_mem_re,m_mem_re);
	FF #1                     ff2(clk,reset,flush,stall[3],stall[4],ex_mem_we,m_mem_we);
	FF #1                     ff3(clk,reset,flush,stall[3],stall[4],ex_mem_sign_ext_flag,m_mem_sign_ext_flag);
	FF #4                     ff4(clk,reset,flush,stall[3],stall[4],ex_mem_sel,m_mem_sel);
	FF #(`RegWidth)           ff5(clk,reset,flush,stall[3],stall[4],ex_mem_wdata,m_mem_wdata);
	FF #(`RegWidth)           ff6(clk,reset,flush,stall[3],stall[4],ex_wdata,mem_wdata);
    FF #(`RegNumLog2)         ff7(clk,reset,flush,stall[3],stall[4],ex_waddr,mem_waddr);
    FF #1                     ff8(clk,reset,flush,stall[3],stall[4],ex_we,mem_we);
    FF #(`RegWidth)           ff9(clk,reset,flush,stall[3],stall[4],ex_hi,mem_hi);
    FF #(`RegWidth)           ff10(clk,reset,flush,stall[3],stall[4],ex_lo,mem_lo);
    FF #1                     ff11(clk,reset,flush,stall[3],stall[4],ex_we_hilo,mem_we_hilo);
    FF #1                     ff12(clk,reset,flush,stall[3],stall[4],ex_cp0_we,mem_cp0_we);
    FF #8                     ff13(clk,reset,flush,stall[3],stall[4],ex_cp0_waddr,mem_cp0_waddr);
    FF #(`RegWidth)           ff14(clk,reset,flush,stall[3],stall[4],ex_cp0_wdata,mem_cp0_wdata);
    FF #(`EXC_TYPE_BUS_WIDTH) ff15(clk,reset,flush,stall[3],stall[4],ex_exception_type,mem_exception_type);
    FF #(`InstAddrWidth)      ff16(clk,reset,flush,stall[3],stall[4],ex_current_inst_addr,mem_current_inst_addr);
    FF #1                     ff17(clk,reset,flush,stall[3],stall[4],ex_in_delayslot,mem_in_delayslot);
    
endmodule
