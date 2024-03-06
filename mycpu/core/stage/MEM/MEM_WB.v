`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/23 09:49:07
// Design Name: 
// Module Name: MEM_WB
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

module MEM_WB(
	input wire clk,
    input wire reset,
    input wire flush,
    input wire [`StallBus] stall,
    //来自访存阶段的信息    
    input wire[`RegAddrBus] mem_waddr,
    input wire[`RegWriteBus] mem_we,
    input wire[`RegBus] mem_wdata,
    input wire[`RegBus] mem_hi,
    input wire[`RegBus] mem_lo,
    input wire mem_we_hilo,
    input wire mem_cp0_we,
    input wire[`CP0RegAddrBus] mem_cp0_waddr,
    input wire[`RegBus] mem_cp0_wdata,
    input wire[`InstAddrBus] mem_current_inst_addr,
    //送到回写阶段的信息
    output wire[`RegAddrBus] wb_waddr,
    output wire[`RegWriteBus]wb_we,
    output wire[`RegBus] wb_wdata,
    output wire[`RegBus] wb_hi,
    output wire[`RegBus] wb_lo,
    output wire wb_we_hilo,
    output wire wb_cp0_we,
    output wire[`CP0RegAddrBus] wb_cp0_waddr,
    output wire[`RegBus] wb_cp0_wdata,
    output wire[`InstAddrBus] wb_current_inst_addr
 );
    
    FF #(`RegWidth)           ff1(clk,reset,flush,stall[4],stall[5],mem_wdata,wb_wdata);
    FF #(`RegNumLog2)         ff2(clk,reset,flush,stall[4],stall[5],mem_waddr,wb_waddr);
    FF #1                     ff3(clk,reset,flush,stall[4],stall[5],mem_we,wb_we);
    FF #(`RegWidth)           ff4(clk,reset,flush,stall[4],stall[5],mem_hi,wb_hi);
    FF #(`RegWidth)           ff5(clk,reset,flush,stall[4],stall[5],mem_lo,wb_lo);
    FF #1                     ff6(clk,reset,flush,stall[4],stall[5],mem_we_hilo,wb_we_hilo);
    FF #1                     ff7(clk,reset,flush,stall[4],stall[5],mem_cp0_we,wb_cp0_we);
    FF #8                     ff8(clk,reset,flush,stall[4],stall[5],mem_cp0_waddr,wb_cp0_waddr);
    FF #(`RegWidth)           ff9(clk,reset,flush,stall[4],stall[5],mem_cp0_wdata,wb_cp0_wdata);
    FF #(`InstAddrWidth)      ff14(clk,reset,flush,stall[4],stall[5],mem_current_inst_addr,wb_current_inst_addr);
    
endmodule
