`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/23 09:48:39
// Design Name: 
// Module Name: MEM
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
 
module MEM(
	input wire reset,
    // 来自执行阶段的信息    
    input wire          mem_re_i,
    input wire          mem_we_i,
    input wire          mem_sign_ext_flag_i,
    input wire[`MemSel] mem_sel_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus]  waddr_i,
    input wire[`RegWriteBus] we_i,
    input wire[`RegBus]      wdata_i,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,
    input wire          we_hilo_i,
    input wire                 cp0_we_i,
    input wire[`CP0RegAddrBus] cp0_waddr_i,
    input wire[`RegBus]        cp0_wdata_i,
    // 来自ram的信息
    input wire[`DataBus] ram_rdata_i,
    // 异常信号
    input wire[`RegBus] cp0_status_i,
    input wire[`RegBus] cp0_cause_i,
    input wire[`RegBus] cp0_epc_i,
    input wire[`EXC_TYPE_BUS] exception_type_i,
    input wire in_delayslot_i,
    input wire[`InstAddrBus] current_inst_addr_i,
    // 回写阶段的指令是否要写CP0，用来检测数据相关
    input wire                 wb_cp0_we_i,
	input wire[`CP0RegAddrBus] wb_cp0_waddr_i,
	input wire[`RegBus]        wb_cp0_wdata_i,
    // 送到回写阶段的信息
    output wire[`RegAddrBus] waddr_o,
    output wire[`RegWriteBus]we_o,
    output reg[`RegBus]      wdata_o,
    output wire[`RegBus]     hi_o,
    output wire[`RegBus]     lo_o,
    output wire              we_hilo_o,
    output wire                 cp0_we_o,
    output wire[`CP0RegAddrBus] cp0_waddr_o,
    output wire[`RegBus]        cp0_wdata_o,
    // 与异常相关的信息
    output wire[`RegBus] cp0_badvaddr_wdata_o,
    output wire[`RegBus] cp0_epc_o,
    output wire[`EXC_TYPE_BUS] exception_type_o,
    output wire in_delayslot_o,
    output wire[`InstAddrBus] current_inst_addr_o,
    //送到ram的信息
    output wire[`DataAddrBus] ram_addr_o,
    output wire               ram_we_o,
    output reg[`MemSel]       ram_sel_o,
    output reg[`DataBus]      ram_wdata_o,
    output wire               ram_en_o
);
    
    // to WB stage
    assign we_o = reset ? we_i : 4'b0000;
    assign waddr_o = reset ? waddr_i : `NOPRegAddr;
    assign hi_o = reset ? hi_i : `ZeroWord;
    assign lo_o = reset ? lo_i : `ZeroWord;
    assign we_hilo_o = reset ? we_hilo_i : 1'b0;
    assign cp0_we_o = reset ? cp0_we_i : 1'b0;
    assign cp0_waddr_o = reset ? cp0_waddr_i : 8'd0;
    assign cp0_wdata_o = reset ? cp0_wdata_i : `ZeroWord;
    
    // 访存地址
    wire[`DataAddrBus] address = wdata_i;
    
    assign ram_we_o = reset ? (mem_we_i & (~(|exception_type_o))) : 1'b0;

    // 产生ram使能信号
    assign ram_en_o = ~reset ? 1'b0 : (mem_we_i == 1'b1 || mem_re_i == 1'b1) ? 1'b1 : 1'b0;

    // 产生ram读写的地址
   assign ram_addr_o = ~reset ? `ZeroWord : (mem_we_i == 1'b1 || mem_re_i == 1'b1) ? {address[31:2], 2'b00} : `ZeroWord;

    // 写数据存储器 ：产生ram的写片选信号和数据
    always @(*) begin
        if (!reset) begin
            ram_sel_o <= 4'b0000;
        end

        else if (mem_we_i == 1'b1) begin
              
            if (mem_sel_i == 4'b0001)           // byte
            begin   
                ram_wdata_o <= {4{mem_wdata_i[7:0]}};
                case (address[1:0])
                    2'b00: ram_sel_o <= 4'b0001;
                    2'b01: ram_sel_o <= 4'b0010;
                    2'b10: ram_sel_o <= 4'b0100;
                    2'b11: ram_sel_o <= 4'b1000;
                    default: ram_sel_o <= 4'b0000;
                endcase
            end
            else if (mem_sel_i == 4'b0011)     // half word
            begin   
                ram_wdata_o <= {2{mem_wdata_i[15:0]}};
                case (address[1:0])
                    2'b00: ram_sel_o <= 4'b0011;
                    2'b10: ram_sel_o <= 4'b1100;
                    default: ram_sel_o <= 4'b0000;
                endcase
            end
            else if (mem_sel_i == 4'b1111)    // word
            begin   
                ram_wdata_o <= mem_wdata_i;
                case (address[1:0])
                    2'b00: ram_sel_o <= 4'b1111;
                    default: ram_sel_o <= 4'b0000;
                endcase
            end
            else begin
                ram_sel_o <= 4'b0000;
            end
        end
        else begin
            ram_sel_o <= 4'b0000;
        end
    end

    // 读数据存储器
    always @(*) begin
        if (!reset) begin
            wdata_o <= `ZeroWord;
        end

        else begin
            if (mem_re_i == 1'b1) begin

                if (mem_sel_i == 4'b0001) 
                begin
                    case(address[1:0])
                        2'b00: wdata_o <= mem_sign_ext_flag_i ? {{24{ram_rdata_i[7]}}, ram_rdata_i[7:0]} : {24'b0, ram_rdata_i[7:0]};
                        2'b01: wdata_o <= mem_sign_ext_flag_i ? {{24{ram_rdata_i[15]}}, ram_rdata_i[15:8]} : {24'b0, ram_rdata_i[15:8]};
                        2'b10: wdata_o <= mem_sign_ext_flag_i ? {{24{ram_rdata_i[23]}}, ram_rdata_i[23:16]} : {24'b0, ram_rdata_i[23:16]};
                        2'b11: wdata_o <= mem_sign_ext_flag_i ? {{24{ram_rdata_i[31]}}, ram_rdata_i[31:24]} : {24'b0, ram_rdata_i[31:24]};
                        default: wdata_o <= `ZeroWord;
                    endcase
                end
                else if (mem_sel_i == 4'b0011) 
                begin
                    case (address[1:0])
                        2'b00: wdata_o <= mem_sign_ext_flag_i ? {{16{ram_rdata_i[15]}}, ram_rdata_i[15:0]} : {16'b0, ram_rdata_i[15:0]};
                        2'b10: wdata_o <= mem_sign_ext_flag_i ? {{16{ram_rdata_i[31]}}, ram_rdata_i[31:16]} : {16'b0, ram_rdata_i[31:16]};
                        default: wdata_o <= `ZeroWord;
                    endcase
                end
                else if (mem_sel_i == 4'b1111) 
                begin
                    case (address[1:0])
                        2'b00: wdata_o <= ram_rdata_i;
                        default: wdata_o <= `ZeroWord;
                    endcase
                end
                else begin
                    wdata_o <= `ZeroWord;
                end
            end
            else if (mem_we_i == 1'b1) begin
                wdata_o <= `ZeroWord;
            end
            else begin
                wdata_o <= wdata_i;
            end
        end
    end
    
    
     // 产生异常信号
    wire adel_tag, ades_tag, int_oc, int_en;
	wire[`RegBus] cp0_status,cp0_cause;	
	
	assign cp0_status = ~reset ? `ZeroWord : ((wb_cp0_we_i == 1'b1) && (wb_cp0_waddr_i == `CP0_REG_STATUS )) ? wb_cp0_wdata_i : cp0_status_i;
	
	assign cp0_cause = ~reset ? `ZeroWord : ((wb_cp0_we_i == 1'b1) && (wb_cp0_waddr_i == `CP0_REG_CAUSE )) 
	                          ? {cp0_cause_i[31:10],wb_cp0_wdata_i[9:8], cp0_cause_i[7:0]} : cp0_cause_i;
		
	assign cp0_epc_o = ~reset ? `ZeroWord : ((wb_cp0_we_i == 1'b1) && (wb_cp0_waddr_i == `CP0_REG_EPC )) ? wb_cp0_wdata_i : cp0_epc_i;

    assign in_delayslot_o = reset ? in_delayslot_i : 1'b0;

    assign current_inst_addr_o = reset ? current_inst_addr_i : `ZeroWord;
    

    // 中断能否发生
    assign int_oc = |(cp0_cause[`CP0_SEG_IP] & cp0_status[`CP0_SEG_IM]);

   // 是否使能中断
    assign int_en = !cp0_status[`CP0_SEG_EXL] && cp0_status[`CP0_SEG_IE];

    assign {adel_tag,ades_tag,cp0_badvaddr_wdata_o} = ~reset                               ? {2'b00,`ZeroWord} : 
                                                     (current_inst_addr_i[1:0] != 2'b00)   ? {2'b10,current_inst_addr_i}:
                                                     (mem_sel_i == 4'b0011 && address[0])  ? {mem_re_i,mem_we_i,address}:
                                                     (mem_sel_i == 4'b1111 && address[1:0])? {mem_re_i,mem_we_i,address}:{2'b00,`ZeroWord};


    assign exception_type_o = ~reset ? `EXC_TYPE_NULL :(current_inst_addr_i != `ZeroWord)    ?
                                                     ( (int_oc && int_en)                    ? `EXC_TYPE_INT :
                                                       (current_inst_addr_i[1:0])            ? `EXC_TYPE_IF  :
                                                       (exception_type_i[`EXC_TYPE_POS_RI])  ? `EXC_TYPE_RI  :
                                                       (exception_type_i[`EXC_TYPE_POS_OV])  ? `EXC_TYPE_OV  :
                                                       (exception_type_i[`EXC_TYPE_POS_BP])  ? `EXC_TYPE_BP  :
                                                       (exception_type_i[`EXC_TYPE_POS_SYS]) ? `EXC_TYPE_SYS :
                                                       (adel_tag == 1'b1)                    ? `EXC_TYPE_ADEL:            
                                                       (ades_tag == 1'b1)                    ? `EXC_TYPE_ADES:
                                                       (exception_type_i[`EXC_TYPE_POS_ERET])? `EXC_TYPE_ERET: `EXC_TYPE_NULL ): `EXC_TYPE_NULL ;

endmodule
