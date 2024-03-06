`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/22 10:33:41
// Design Name: 
// Module Name: MMU
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


module MMU(
    input wire reset,
    input wire[31:0] read_addr_in,
    input wire[31:0] write_addr_in,
    output wire[31:0] read_addr_out,
    output wire[31:0] write_addr_out
);

   assign read_addr_out = ~reset ? `ZeroWord : (read_addr_in[31:28]>=4'h0 && read_addr_in[31:28]<=4'h7) ? read_addr_in :
                                               (read_addr_in[31:28]>=4'h8 && read_addr_in[31:28]<=4'h9) ? {read_addr_in[31:28] - 4'h8, read_addr_in[27:0]} :
                                               (read_addr_in[31:28]>=4'ha && read_addr_in[31:28]<=4'hb) ? {read_addr_in[31:28] - 4'ha, read_addr_in[27:0]} :
                                               (read_addr_in[31:28]>=4'hc && read_addr_in[31:28]<=4'hd) ? read_addr_in : read_addr_in;

  assign write_addr_out = ~reset ? `ZeroWord : (write_addr_in[31:28]>=4'h0 && write_addr_in[31:28]<=4'h7) ? write_addr_in :
                                               (write_addr_in[31:28]>=4'h8 && write_addr_in[31:28]<=4'h9) ? {write_addr_in[31:28] - 4'h8, write_addr_in[27:0]} :
                                               (write_addr_in[31:28]>=4'ha && write_addr_in[31:28]<=4'hb) ? {write_addr_in[31:28] - 4'ha, write_addr_in[27:0]} :
                                               (write_addr_in[31:28]>=4'hc && write_addr_in[31:28]<=4'hd) ? write_addr_in : write_addr_in;
  

endmodule
