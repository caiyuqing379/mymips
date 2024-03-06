`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 11:24:50
// Design Name: 
// Module Name: FF
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


module DFF (clk,rst,next,status);
    parameter width = 8;
    input clk,rst;
    input [width-1:0] next;
    output reg [width-1:0] status;
    
    always @ (posedge clk)   //Õ¨≤Ω«Â¡„
        begin
            if (~rst) begin
                status <= {width{1'b0}};
            end
            else begin
                status <= next;
            end
        end
        
endmodule
