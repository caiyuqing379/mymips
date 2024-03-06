`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 21:11:43
// Design Name: 
// Module Name: MULT_DIV
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
 
module MULT_DIV(
       input clk,
       input reset,
       input flush,
       input [`AluFuncBus] func,
       input [`RegBus] reg1_i,
       input [`RegBus] reg2_i,
       output reg[`DoubleRegBus] result,
       output wire stallreq_for_div
    );
    
     wire[`RegBus] op1_mult, op2_mult;
     wire[`DoubleRegBus] mult_result;
       
      //取得乘法操作的操作数，如果是有符号除法且操作数是负数，那么取反加一
      assign op1_mult = ((func == `FUNCT_MULT) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
      assign op2_mult = ((func == `FUNCT_MULT) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;        
      assign mult_result = op1_mult * op2_mult;
      
      
      wire[`DoubleRegBus] div_result;
      wire div_done;
      wire div_start;
      
      assign div_start = ~reset ? 1'b0: ((func == `FUNCT_DIV)||(func == `FUNCT_DIVU)) &&  (div_done == 1'b0)? 1'b1 :1'b0;
      
      assign stallreq_for_div = ~reset ? 1'b0 : ((func == `FUNCT_DIV)||(func == `FUNCT_DIVU)) &&  (div_done == 1'b0)? 1'b1 :1'b0;
      
      DIV div(clk,reset,div_start,flush,func == `FUNCT_DIV,reg1_i,reg2_i,div_result,div_done);
      
         always @(*) 
          begin
           if(!reset)
           begin
               result <= `DoubleRegWidth'h0;
           end
           else begin
             case (func)
               `FUNCT_MULT: begin 
                              result <= reg1_i[31] ^ reg2_i[31] ? ~mult_result + 1 : mult_result;
                           end
               `FUNCT_MULTU: begin
                               result <= mult_result;
                            end
               `FUNCT_DIV, `FUNCT_DIVU: begin
                                          result <= div_result;
                                       end
               default: result <= {`ZeroWord,`ZeroWord}; 
             endcase
           end
         end
      
endmodule
