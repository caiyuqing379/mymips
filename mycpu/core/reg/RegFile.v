`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 21:18:59
// Design Name: 
// Module Name: RegFile
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

module RegFile(
    input wire clk,
    input wire reset,
    //写端口
    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] write_data,
    //读端口1
    input wire read_en1,
    input wire[`RegAddrBus] read_addr1,
    output wire[`RegBus] read_data1,
    //读端口2
    input wire read_en2,
    input wire[`RegAddrBus] read_addr2,
    output wire[`RegBus] read_data2
);
    //定义32个32位寄存器
    reg[`RegBus] registers[0:`RegNum-1];

    //写操作
    always @(posedge clk) 
    begin
        if (!reset) 
        begin
            registers[0] <= `ZeroWord;  registers[1] <= `ZeroWord;  registers[2] <= `ZeroWord;
            registers[3] <= `ZeroWord;  registers[4] <= `ZeroWord;  registers[5] <= `ZeroWord;
            registers[6] <= `ZeroWord;  registers[7] <= `ZeroWord;  registers[8] <= `ZeroWord;
            registers[9] <= `ZeroWord;  registers[10] <= `ZeroWord; registers[11] <= `ZeroWord;
            registers[12] <= `ZeroWord; registers[13] <= `ZeroWord; registers[14] <= `ZeroWord;
            registers[15] <= `ZeroWord; registers[16] <= `ZeroWord; registers[17] <= `ZeroWord;
            registers[18] <= `ZeroWord; registers[19] <= `ZeroWord; registers[20] <= `ZeroWord;
            registers[21] <= `ZeroWord; registers[22] <= `ZeroWord; registers[23] <= `ZeroWord;
            registers[24] <= `ZeroWord; registers[25] <= `ZeroWord; registers[26] <= `ZeroWord;
            registers[27] <= `ZeroWord; registers[28] <= `ZeroWord; registers[29] <= `ZeroWord;
            registers[30] <= `ZeroWord; registers[31] <= `ZeroWord;
        end
        else if (we && waddr) begin 
            registers[waddr] <= write_data;
        end
        else begin 
            registers[waddr] <= registers[waddr];
        end
    end


    // 读操作数1
    assign read_data1 = ~reset ? `ZeroWord : (read_addr1 == `NOPRegAddr)             ? `ZeroWord :
                                             (read_addr1 == waddr && we && read_en1) ? write_data :
                                             (read_en1)                              ? registers[read_addr1] : `ZeroWord;
    
    
    //读操作数2
    assign read_data2 = ~reset ? `ZeroWord : (read_addr2 == `NOPRegAddr)             ? `ZeroWord :
                                             (read_addr2 == waddr && we && read_en2) ? write_data :
                                             (read_en2)                              ? registers[read_addr2] : `ZeroWord;
    
endmodule
