`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/21 11:24:34
// Design Name: 
// Module Name: SRAMArbiter
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

module SRAMArbiter(
    input wire clk,
    input wire reset,
    // ROM 接口
    input wire rom_en,
    input wire[3:0] rom_write_en,
    input wire[31:0] rom_write_data,
    input wire[31:0] rom_addr,
    output reg[31:0] rom_read_data,
    // RAM 接口
    input wire ram_en,
    input wire[3:0] ram_write_en,
    input wire[31:0] ram_write_data,
    input wire[31:0] ram_addr,
    output reg[31:0] ram_read_data,
    // 指令类sram信号
    input wire[31:0] inst_rdata,
    input wire inst_addr_ok,
    input wire inst_data_ok,
    output wire inst_req,
    output wire inst_wr,
    output wire[1:0] inst_size,
    output wire[31:0] inst_addr,
    output wire[31:0] inst_wdata,
    // 数据类sram信号
    input wire[31:0] data_rdata,
    input wire data_addr_ok,
    input wire data_data_ok,
    output wire data_req,
    output wire data_wr,
    output wire[1:0] data_size,
    output wire[31:0] data_addr,
    output wire[31:0] data_wdata,
    // CPU signals
    output wire halt
);

    parameter State_IDLE = 0, State_Busy =1, State_RAM = 2, State_ROM = 3;
    wire[1:0] state;
    reg[1:0] next_state;

    // AXI control signals
    reg ram_req, rom_req;
    reg[1:0] wr_data_size;
    reg[31:0] wr_data_addr;
    
    assign inst_req = rom_req;
    assign inst_wr = 0;
    assign inst_size = 2'b10;
    assign inst_addr = rom_addr;
    assign inst_wdata = 0;

    assign data_req = ram_req;
    assign data_wr = |ram_write_en;
    assign data_size = wr_data_size;
    assign data_addr = wr_data_addr;
    assign data_wdata = ram_write_data;

    // 流水线暂停信号
    assign halt = state != State_IDLE;

    DFF #2 mydff(clk,reset,next_state,state);

    // 产生下一个状态
    always @(*) begin
        case (state)
            State_IDLE: next_state <= State_Busy;
            State_Busy: next_state <= ram_en ? State_RAM : rom_en ? State_ROM : State_IDLE;
            State_RAM: next_state <= data_data_ok ? (rom_en ? State_ROM : State_IDLE) : State_RAM;
            State_ROM: next_state <= inst_data_ok ? State_IDLE : State_ROM;
            default: next_state <= State_IDLE;
        endcase
    end

    // 发送地址请求
    reg ram_access_tag, rom_access_tag;
    always @(posedge clk) begin
        if (!reset) begin
            ram_req <= 0;
            rom_req <= 0;
            ram_access_tag <= 0;
            rom_access_tag <= 0;
        end
        else if (state == State_RAM) 
        begin
            if (!ram_access_tag) begin
                if (data_addr_ok && ram_req) begin
                    ram_req <= 0;
                    ram_access_tag <= 1;
                end
                else begin
                    ram_req <= 1;
                end
            end
        end
        else if (state == State_ROM) 
        begin
            if (!rom_access_tag) begin
                if (inst_addr_ok && rom_req) begin // 一旦握手成功就拉低
                    rom_req <= 0;
                    rom_access_tag <= 1;
                end
                else begin
                    rom_req <= 1;
                end
            end
        end
        else begin
            ram_access_tag <= 0;
            rom_access_tag <= 0;
        end
    end
    
    // 产生写的数据的size和addr
    always @(*) begin
        if (!reset) begin
            wr_data_size <= 0;
            wr_data_addr <= 0;
        end
        else if (!data_wr) begin
            wr_data_size <= 2'b10;
            wr_data_addr <= ram_addr;
        end
        else begin
            case (ram_write_en)
                4'b0001: begin
                            wr_data_size <= 2'b00;
                            wr_data_addr <= {ram_addr[31:2], 2'b00};
                         end 
                4'b0010: begin
                            wr_data_size <= 2'b00;
                            wr_data_addr <= {ram_addr[31:2], 2'b01};
                         end 
                4'b0100: begin
                            wr_data_size <= 2'b00;
                            wr_data_addr <= {ram_addr[31:2], 2'b10};
                         end 
                4'b1000: begin
                            wr_data_size <= 2'b00;
                            wr_data_addr <= {ram_addr[31:2], 2'b11};
                         end 
                4'b0011: begin
                            wr_data_size <= 2'b01;
                            wr_data_addr <= {ram_addr[31:2], 2'b00};
                         end 
                4'b1100: begin
                            wr_data_size <= 2'b01;
                            wr_data_addr <= {ram_addr[31:2], 2'b10};
                         end 
                4'b1111: begin
                            wr_data_size <= 2'b10;
                            wr_data_addr <= {ram_addr[31:2], 2'b00};
                         end 
                default: begin
                            wr_data_size <= 0;
                            wr_data_addr <= 0;
                         end
            endcase
        end
    end


    // 接收数据
    always @(posedge clk) begin
        if (!reset) begin
           ram_read_data <= 0;
           rom_read_data <= 0;
        end
        else if (ram_en && data_data_ok && !data_wr) begin
              ram_read_data <= data_rdata;
        end
        else if (rom_en && inst_data_ok) begin
              rom_read_data <= inst_rdata;
        end
    end

endmodule 
