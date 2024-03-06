`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 14:49:19
// Design Name: 
// Module Name: HILO
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

`include "../define/defines.v"

module HILO(
	input wire clk,
	input wire	reset,	
	//Ð´¶Ë¿Ú
	input wire	we,
	input wire[`RegBus]	 hi_i,
	input wire[`RegBus]	 lo_i,	
	//¶Á¶Ë¿Ú1
	output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o	
);

	always @ (posedge clk) begin
		if (!reset) 
		begin
		    hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end 
		else if(we == 1'b1) 
		begin
			 hi_o <= hi_i;
			 lo_o <= lo_i;
		end
	end

endmodule
