`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 15:07:34
// Design Name: 
// Module Name: PC
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

`define STARTADDR 32'hbfc00000

module PC(
    input wire clk,
    input wire reset,
    // 来自控制模块的信息
    input wire [`StallBus] stall,   
    // 来自译码阶段的信息
    input wire branch_flag,
    input wire[`RegBus] branch_target_addr,
    // 流水线清除信号
    input wire flush,
    input wire[`InstAddrBus] except_pc,
    output reg[`InstAddrBus] pc,        
    output reg rom_enable
    );
    
	always @ (posedge clk) 
	begin
        if (!reset) begin
            rom_enable <= 1'b0;
        end 
        else begin
            rom_enable <= 1'b1;
        end
    end
    
   	always @ (posedge clk)
   	begin
        if (rom_enable == 1'b0) begin
            pc <= `STARTADDR;
        end 
        else 
            if(flush == 1'b1) begin
               pc <= except_pc;
             end 
        else 
            if(stall[0] == `NoStop) 
            begin
                if(branch_flag == `Branch) begin
                   pc <= branch_target_addr;
                end 
                else begin
                   pc <= pc + 3'd4;
                end
            end
    end
    
endmodule
