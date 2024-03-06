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


module FF (clk,rst,flush,stall1,stall2,next,status);
    parameter width = 8;
    input clk,rst,flush,stall1,stall2;
    input [width-1:0] next;
    output reg [width-1:0] status;
    
    always @ (posedge clk)   //Õ¨≤Ω«Â¡„
        begin
            if (~rst) begin
                status <= {width{1'b0}};
            end
            else if(flush == 1'b1) begin
                status <= {width{1'b0}};
            end
            else if(stall1 && !stall2) begin
                status <= {width{1'b0}};
            end
            else if(!stall1) begin
                status <= next;
            end
        end
        
endmodule
