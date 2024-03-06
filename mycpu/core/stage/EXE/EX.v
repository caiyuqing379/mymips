`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 21:49:27
// Design Name: 
// Module Name: EX
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
 
module EX(
	input wire reset,
    // �͵�ִ�н׶ε���Ϣ
    input wire[`AluFuncBus]   alu_func_i,
    input wire[`InstShamtBus] shamt,
    input wire[`RegBus]       reg1_i,
    input wire[`RegBus]       reg2_i,
    input wire[`RegAddrBus]   waddr_i,
    input wire[`RegWriteBus]  we_i,
    // �ô�׶���Ϣ������
    input wire            mem_re_i,
    input wire            mem_we_i,
    input wire            mem_sign_ext_flag_i,
    input wire[`MemSel]   mem_sel_i,
    input wire[`DataBus]  mem_wdata_i,
	// HI��LO�Ĵ�����ֵ
    input wire[`RegBus]   hi_i,
    input wire[`RegBus]   lo_i,
    // �˷��������Ľ��
    input wire [`DoubleRegBus] mult_div_result,
    // ��д�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
    input wire[`RegBus]   wb_hi_i,
    input wire[`RegBus]   wb_lo_i,
    input wire            wb_we_hilo_i,   
    // �ô�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
    input wire[`RegBus]   mem_hi_i,
    input wire[`RegBus]   mem_lo_i,
    input wire            mem_we_hilo_i,
    // ���Գ���������ͣ����
    input wire  stallreq_from_div,
    // �Ƿ�ת�ơ��Լ�link address
    input wire[`RegBus] link_addr_i,
    input wire in_delayslot_i,  
    input wire[`EXC_TYPE_BUS] exception_type_i,
    input wire[`InstAddrBus] current_inst_addr_i,
    // ����cp0
    input wire                 cp0_we_i,
    input wire                 cp0_re_i,
    input wire[`CP0RegAddrBus] cp0_addr_i,
    input wire[`RegBus]        cp0_wdata_i,  
    input wire[`RegBus]        cp0_rdata_i,
    // �ô�׶ε�ָ���Ƿ�ҪдCP0����������������
    input wire                 mem_cp0_we_i,
	input wire[`CP0RegAddrBus] mem_cp0_waddr_i,
	input wire[`RegBus]        mem_cp0_wdata_i,	
	// ��д�׶ε�ָ���Ƿ�ҪдCP0����������������
    input wire                 wb_cp0_we_i,
	input wire[`CP0RegAddrBus] wb_cp0_waddr_i,
	input wire[`RegBus]        wb_cp0_wdata_i,
    // ��ͣ����
    output wire stallreq,
    output wire [`AluFuncBus] alu_func_o,
    output wire [`RegBus] op1,
    output wire [`RegBus] op2,
    // �͵��ô�׶ε���Ϣ
    output wire mem_re_o,
    output wire mem_we_o,
    output wire mem_sign_ext_flag_o,
    output wire[`MemSel] mem_sel_o,
    output wire[`DataBus] mem_wdata_o,
    // �͵�д�ؽ׶ε���Ϣ
    output wire[`RegAddrBus] waddr_o,
    output wire[`RegWriteBus] we_o,
    output wire[`RegBus] wdata_o,
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg we_hilo_o,
    output wire[`CP0RegAddrBus] cp0_raddr_o,
    output wire                 cp0_we_o,
    output wire[`CP0RegAddrBus] cp0_waddr_o,
    output wire[`RegBus]        cp0_wdata_o,
    // �쳣�ź�
    output wire[`EXC_TYPE_BUS] exception_type_o,
    output wire[`InstAddrBus] current_inst_addr_o,
    output wire in_delayslot_o
); 
    
    assign stallreq = reset ? stallreq_from_div : 1'b0;
    assign alu_func_o = reset ? alu_func_i : 6'h0;
    assign op1 = reset ? reg1_i : 1'b0;
    assign op2 = reset ? reg2_i : 1'b0;
    // to MEM stage
    assign mem_re_o = reset ? mem_re_i : 1'b0;
    assign mem_we_o = reset ? mem_we_i : 1'b0;
    assign mem_sign_ext_flag_o = reset ? mem_sign_ext_flag_i : 1'b0;
    assign mem_sel_o = reset ? mem_sel_i : 4'b0000;
    assign mem_wdata_o = reset ? mem_wdata_i : `ZeroWord; 
    // to CP0
    assign cp0_we_o = reset ? cp0_we_i : 1'b0;
    assign cp0_waddr_o = reset ? cp0_addr_i : 8'd0;
    assign cp0_wdata_o = reset ? cp0_wdata_i : `ZeroWord; 
    
    wire overflow_sum;  // �Ƿ����
    wire reg1_lt_reg2;  // ��һ���������Ƿ�С�ڵڶ���������
    wire [`RegBus] reg2_i_mux;  // �ڶ����������Ĳ���
    wire [`RegBus] result_sum;  // �ӷ����
    
    // ������2�Ĳ���
    assign reg2_i_mux=(alu_func_i == `FUNCT_SUB ||alu_func_i == `FUNCT_SUBU || alu_func_i == `FUNCT_SLT) ?(~reg2_i) + 1 : reg2_i;
    
    // ������1�Ͳ�����2֮��
    assign result_sum = reg1_i + reg2_i_mux;
    
    // �����־
    assign overflow_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
                       
    // ���������1�Ƿ�С�ڲ�����2     
    assign reg1_lt_reg2=((alu_func_i == `FUNCT_SLT)) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
                                                        (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);                   
    
    
    // HI & LO
    wire[`RegBus] hi,lo;
    
    // �õ����µ�HI��LO�Ĵ�����ֵ���˴�Ҫ���ָ�������������
    assign {hi,lo} = ~reset ? {`ZeroWord,`ZeroWord} : (mem_we_hilo_i == 1'b1) ? 
                              {mem_hi_i,mem_lo_i}   : (wb_we_hilo_i == 1'b1) ? 
                              {wb_hi_i,wb_lo_i}     : {hi_i,lo_i};  
    
    // cp0
    wire[`RegBus] cp0_temp;
    
    assign cp0_raddr_o = reset ? cp0_addr_i : 8'd0;
    
    // �õ����µ�cp0�Ĵ�����ֵ���˴�Ҫ���ָ�������������
    assign cp0_temp = ~reset ? `ZeroWord       : (mem_cp0_we_i == 1'b1 && mem_cp0_waddr_i == cp0_raddr_o) ?
                               mem_cp0_wdata_i : (wb_cp0_we_i == 1'b1 && wb_cp0_waddr_i == cp0_raddr_o) ?
                               wb_cp0_wdata_i  : cp0_rdata_i;
                                   
    
    // write registers
    reg[`RegBus] result;
    assign wdata_o = reset ? result:`ZeroWord;
    assign we_o = ~reset ? 4'b0000 : (((alu_func_i == `FUNCT_ADD) || (alu_func_i == `FUNCT_SUB)) && overflow_sum)? 4'b0000 : we_i;
    assign waddr_o = reset ? waddr_i:`NOPRegAddr;
    
    always @(*) begin
        case (alu_func_i)
            `FUNCT_OR: result <= reg1_i | reg2_i;
            `FUNCT_AND: result <= reg1_i & reg2_i;
            `FUNCT_XOR: result <= reg1_i ^ reg2_i;
            `FUNCT_NOR: result <= ~(reg1_i | reg2_i);
            `FUNCT_SLL: result <= reg2_i << shamt;            
            `FUNCT_SRL: result <= reg2_i >> shamt;
            `FUNCT_SRA: result <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, shamt})) | reg2_i >> shamt;
            `FUNCT_SLLV: result <= reg2_i << reg1_i[4:0];
            `FUNCT_SRLV: result <= reg2_i >> reg1_i[4:0];
            `FUNCT_SRAV: result <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
             // hi & lo
            `FUNCT_MFHI: result <= hi;
            `FUNCT_MFLO: result <= lo;
             // arithmetic
            `FUNCT_ADD,`FUNCT_ADDU,`FUNCT_SUB,`FUNCT_SUBU: result <= result_sum;            
             // comparison
            `FUNCT_SLT,`FUNCT_SLTU: result <= reg1_lt_reg2;
            `FUNCT_JALR: result <= link_addr_i;
            // cp0
             default: result <= cp0_re_i ? cp0_temp : `ZeroWord;
        endcase
    end
    
    // write HI & LO
        always @(*) 
        begin
            if(!reset)
            begin
               we_hilo_o <= 1'b0;
               hi_o <= `ZeroWord;
               lo_o <= `ZeroWord;
            end
            else begin 
             case (alu_func_i)
                `FUNCT_MTHI: begin
                               we_hilo_o <= 1'b1;
                               hi_o <= reg1_i;
                               lo_o <= lo;
                             end  
                `FUNCT_MTLO: begin
                               we_hilo_o <= 1'b1;
                               hi_o <= hi;   
                               lo_o <= reg1_i;
                             end
                `FUNCT_MULT,`FUNCT_MULTU,
                `FUNCT_DIV,`FUNCT_DIVU:begin
                                         we_hilo_o <= 1'b1;
                                         hi_o <= mult_div_result[63:32];
                                         lo_o <= mult_div_result[31:0];
                                       end
                default: begin
                           we_hilo_o <= 1'b0;
                           hi_o <= hi;
                           lo_o <= lo;
                         end
             endcase
            end
        end
        
        
    // �����쳣�ź�
    wire overflow_exception;
    assign overflow_exception = reset ? (exception_type_i[`EXC_TYPE_POS_OV] ? overflow_sum : 1'b0) : 1'b0;

    assign exception_type_o = reset ? {exception_type_i[4:2], overflow_exception, exception_type_i[0]} : `EXC_TYPE_NULL;

    assign in_delayslot_o = reset ? in_delayslot_i : 1'b0;

    assign current_inst_addr_o = reset ? current_inst_addr_i : `ZeroWord;
    
endmodule
