`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 21:41:47
// Design Name: 
// Module Name: DIV
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

module DIV(
    input wire clk,
    input wire reset,
    input wire en,
    input wire cancel,
    input wire sign_flag,
    input wire[`RegBus] op1,
    input wire[`RegBus] op2,
    output reg[`DoubleRegBus] result,
    output reg done
    );    
    
    wire [`RegWidth:0] temp;
    wire [`RegBus] temp_op1;
    wire [`RegBus] temp_op2;
    reg  [1:0] state;
    reg  [5:0] count;
    reg  [`DoubleRegWidth:0] dividend;
    reg  [`RegBus] divisor;

    assign temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

    assign temp_op1 = sign_flag && op1[31] ? ~op1 + 1 : op1;

    assign temp_op2 = sign_flag && op2[31] ? ~op2 + 1 : op2;


    always @(posedge clk) 
    begin
        if(!reset) 
        begin
            state <= `DivFree;
            result <= {`ZeroWord,`ZeroWord};
            done <=  1'b0;    
        end
        else begin
            case (state)
                `DivFree: begin
                              if(en && !cancel) begin
                                 if( op2 == `ZeroWord ) begin
                                        state <= `DivByZero;
                                 end 
                                 else begin
                                      state <= `DivOn;
                                      count <= 6'd0;
                                      dividend <= {31'b0, temp_op1, 1'b0};
                                      divisor  <= temp_op2;
                                      end 
                              end
                              else begin
                                   done <= 1'b0;
                                   result <= {`ZeroWord,`ZeroWord};
                              end
                          end
                `DivByZero: begin
                            dividend <= {`ZeroWord,`ZeroWord};
                            state <= `DivEnd;
                            end                
                `DivOn: begin
                          if( !cancel ) 
                          begin
                              if(count != 6'd32) begin
                                   dividend <= temp[32] ? {dividend[63:0], 1'b0} : {temp[31:0], dividend[31:0], 1'b1};
                                   count <= count + 1'b1;
                              end
                              else begin
                                    dividend[31: 0] <= (sign_flag && (op1[31] ^ op2[31])) ? ~dividend[31: 0] + 1 : dividend[31: 0];                       
                                    dividend[64:33] <= (sign_flag && (op1[31] ^ dividend[64])) ?  ~dividend[64:33] + 1 : dividend[64:33];
                                    state <= `DivEnd;
                                    count <= 6'd0;
                              end
                          end else begin
                            state <= `DivFree;
                          end
                       end                
                `DivEnd: begin
                          result <= {dividend[64:33], dividend[31:0]};  
                          done <= 1'b1;
                          if(!en) 
                             begin
                               state <= `DivFree;
                               done <= 1'b0;
                               result <= {`ZeroWord,`ZeroWord};
                             end
                       end      
                 default: begin end          
           endcase
        end
    end
    
endmodule
