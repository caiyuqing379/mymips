`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 10:07:09
// Design Name: 
// Module Name: CTRL
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

module CTRL(
	input wire reset,
	// 来自译码阶段的暂停请求
	input wire stallreq_from_id,
    // 来自执行阶段的暂停请求
	input wire stallreq_from_ex,
	// 来自取指或访存阶段的的暂停请求
	input wire stallreq_from_if_or_mem,
	// 异常信号
    input wire[`RegBus] cp0_epc,
    input wire[`EXC_TYPE_BUS] exception_type,
	//发送各个阶段的暂停信号
	output reg[`StallBus] stall,
    // 异常操作信号
    output reg flush,
    output reg[`InstAddrBus] exc_pc
);
   
	always @ (*) 
	begin
		if(!reset) begin
			stall <= 6'b000000;
			flush <= 1'b0;
			exc_pc <= `ZeroWord;
		end 
		else if(exception_type != `EXC_TYPE_NULL && stallreq_from_if_or_mem == `NoStop) begin
		    flush <= 1'b1;
		    stall <= 6'b000000;
		    exc_pc <= (exception_type == `EXC_TYPE_ERET) ? cp0_epc :`INIT_PC;
		end 
		else if(stallreq_from_if_or_mem == `Stop) begin
			stall <= 6'b111111;
			flush <= 1'b0;
		end 
		else if(stallreq_from_ex == `Stop) begin
			stall <= 6'b001111;
			flush <= 1'b0;
		end 
		else if(stallreq_from_id == `Stop) begin
			stall <= 6'b000111;		
			flush <= 1'b0;	
		end 
		else begin
			stall <= 6'b000000;
			flush <= 1'b0;
			exc_pc <= `ZeroWord;
		end    
	end      
			
endmodule
