`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 16:21:21
// Design Name: 
// Module Name: IF_ID
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

module IF_ID(
	input wire clk,
	input wire reset,
	input wire flush,
	input wire[`StallBus] stall,
	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,
	output wire[`InstAddrBus] id_pc,
	output wire[`InstBus] id_inst  	
);

  FF #32  ff1(clk,reset,flush,stall[1],stall[2],if_pc,id_pc);
  FF #32  ff2(clk,reset,flush,stall[1],stall[2],if_inst,id_inst);
  
endmodule
