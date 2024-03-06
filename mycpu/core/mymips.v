`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 08:36:22
// Design Name: 
// Module Name: mymips
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

 `include "./define/defines.v"
 
module mymips(
	input wire clk,
    input wire reset,
    input wire halt,
    input wire[`InstBus]       rom_data_i,
    input wire[`RegBus]        ram_data_i,
    input wire[`IntBus]        int_i,
    output wire                timer_int_o,
    output wire[`InstAddrBus]  rom_addr_o,
    output wire                rom_en_o,
    output wire[`DataAddrBus]  ram_addr_o,
    output wire                ram_we_o,
    output wire[`MemSel]       ram_sel_o,
    output wire[`DataBus]      ram_data_o,
    output wire                ram_en_o,
    output wire[`MemSel]       debug_reg_we,
    output wire[`RegBus]       debug_reg_write_data,
    output wire[`RegAddrBus]   debug_reg_write_addr,
    output wire[`InstAddrBus]  debug_pc_addr
);

   wire[`InstAddrBus] pc;
   wire[`InstAddrBus] id_pc_i;
   wire[`InstBus] id_inst_i;

   // 连接译码阶段ID模块的输出与ID/EX模块的输入
   wire[`AluFuncBus] id_func_o;
   wire[`InstShamtBus] id_shamt_o;
   wire[`RegBus] id_reg1_o;
   wire[`RegBus] id_reg2_o;
   wire id_mem_re_o;
   wire id_mem_we_o;
   wire id_mem_sign_ext_flag_o;
   wire[`MemSel] id_mem_sel_o;
   wire[`DataBus] id_mem_wdata_o;
   wire[`RegWriteBus] id_we_o;
   wire[`RegAddrBus] id_waddr_o;
   wire id_in_delayslot_o;
   wire[`RegBus] id_link_addr_o;
   wire id_cp0_we_o;
   wire id_cp0_re_o;
   wire[`CP0RegAddrBus] id_cp0_addr_o;
   wire[`RegBus] id_cp0_wdata_o;
   wire[`EXC_TYPE_BUS] id_exception_type_o;
   wire[`RegBus] id_current_inst_addr_o;

   // 连接ID/EX模块的输出与执行阶段EX模块的输入
   wire[`AluFuncBus] ex_func_i;
   wire[`InstShamtBus] ex_shamt_i;
   wire[`RegBus] ex_reg1_i;
   wire[`RegBus] ex_reg2_i;
   wire ex_mem_re_i;
   wire ex_mem_we_i;
   wire ex_mem_sign_ext_flag_i;
   wire[`MemSel] ex_mem_sel_i;
   wire[`DataBus] ex_mem_wdata_i;
   wire[`RegWriteBus] ex_we_i;
   wire[`RegAddrBus] ex_waddr_i;
   wire ex_in_delayslot_i;	
   wire[`RegBus] ex_link_addr_i;
   wire ex_cp0_we_i;
   wire ex_cp0_re_i;
   wire[`CP0RegAddrBus] ex_cp0_addr_i;
   wire[`RegBus] ex_cp0_wdata_i;
   wire[`EXC_TYPE_BUS] ex_exception_type_i;	
   wire[`RegBus] ex_current_inst_addr_i;
   
   // 连接执行阶段EX模块的输出与EX/MEM模块的输入
   wire ex_mem_re_o;
   wire ex_mem_we_o;
   wire ex_mem_sign_ext_flag_o;
   wire[`MemSel] ex_mem_sel_o;
   wire[`DataBus] ex_mem_wdata_o;
   wire[`RegWriteBus] ex_we_o;
   wire[`RegAddrBus] ex_waddr_o;
   wire[`RegBus] ex_wdata_o;
   wire[`RegBus] ex_hi_o;
   wire[`RegBus] ex_lo_o;
   wire ex_we_hilo_o;
   wire ex_cp0_we_o;
   wire[`CP0RegAddrBus] ex_cp0_waddr_o;
   wire[`RegBus] ex_cp0_wdata_o; 
   wire[`EXC_TYPE_BUS] ex_exception_type_o;
   wire[`RegBus] ex_current_inst_addr_o;
   wire ex_in_delayslot_o;

   // 连接EX/MEM模块的输出与访存阶段MEM模块的输入
   wire m_mem_re_i; 
   wire m_mem_we_i;   
   wire m_mem_sign_ext_flag_i;  
   wire[`MemSel] m_mem_sel_i;  
   wire[`DataBus] m_mem_wdata_i;
   wire[`RegWriteBus] mem_we_i;
   wire[`RegAddrBus] mem_waddr_i;
   wire[`RegBus] mem_wdata_i;
   wire[`RegBus] mem_hi_i;
   wire[`RegBus] mem_lo_i;
   wire mem_we_hilo_i;    
   wire mem_cp0_we_i;
   wire[`CP0RegAddrBus] mem_cp0_waddr_i;
   wire[`RegBus] mem_cp0_wdata_i;
   wire[`EXC_TYPE_BUS] mem_exception_type_i;	
   wire mem_in_delayslot_i;
   wire[`RegBus] mem_current_inst_addr_i;

   // 连接访存阶段MEM模块的输出与MEM/WB模块的输入
   wire[`RegWriteBus] mem_we_o;
   wire[`RegAddrBus] mem_waddr_o;
   wire[`RegBus] mem_wdata_o;
   wire[`RegBus] mem_hi_o;
   wire[`RegBus] mem_lo_o;
   wire mem_we_hilo_o;    
   wire mem_cp0_we_o;
   wire[`CP0RegAddrBus] mem_cp0_waddr_o;
   wire[`RegBus] mem_cp0_wdata_o;  
   wire[`RegBus] mem_latest_badvaddr_o;
   wire[`RegBus] mem_latest_epc_o;
   wire[`EXC_TYPE_BUS] mem_exception_type_o;
   wire mem_in_delayslot_o;
   wire[`InstAddrBus] mem_current_inst_addr_o;

   // 连接MEM/WB模块的输出与回写阶段的输入    
   wire[`RegWriteBus] wb_reg_we_i;
   wire[`RegAddrBus] wb_waddr_i;
   wire[`RegBus] wb_wdata_i;
   wire[`RegBus] wb_hi_i;
   wire[`RegBus] wb_lo_i;
   wire wb_we_hilo_i;  
   wire wb_cp0_we_i;
   wire[`CP0RegAddrBus] wb_cp0_waddr_i;
   wire[`RegBus] wb_cp0_wdata_i;
   wire[`RegBus] wb_latest_badvaddr_i;
   wire[`RegBus] wb_latest_epc_i;
   wire[`EXC_TYPE_BUS] wb_exception_type_i;
   wire wb_in_delayslot_i;
   wire[`InstAddrBus] wb_current_inst_addr_i;

   // 连接译码阶段ID模块与通用寄存器Regfile模块
   wire re_read1;
   wire re_read2;
   wire[`RegBus] reg_data1;
   wire[`RegBus] reg_data2;
   wire[`RegAddrBus] reg_addr1;
   wire[`RegAddrBus] reg_addr2;

	// 连接执行阶段与hilo模块的输出，读取HI、LO寄存器
	wire[`RegBus] hi;
	wire[`RegBus] lo;
	
	// 用于多周期的DIV、DIVU指令
	wire[`StallBus] stall;
    wire stallreq_from_id;    
    wire stallreq_from_ex;
    wire stallreq_div;
    wire[`AluFuncBus] mult_div_func;
    wire[`DoubleRegBus] m_d_result;
    wire[`RegBus] opdata1;
    wire[`RegBus] opdata2;
    
    // 用于分支跳转指令
    wire in_delayslot;
    wire id_next_in_delayslot_o;
    wire id_branch_flag;
    wire[`RegBus] id_branch_addr;
    
    // 读CP0
    wire[`RegBus] cp0_rdata_o;
    wire[`CP0RegAddrBus] cp0_raddr_i;
    
    // 与异常相关
    wire flush;
    wire[`RegBus]   exc_pc;
	wire[`RegBus]	cp0_status;
	wire[`RegBus]	cp0_cause;
	wire[`RegBus]	cp0_epc;
    
    assign debug_reg_we = {4{wb_reg_we_i}};
    assign debug_reg_write_data = wb_wdata_i;
    assign debug_reg_write_addr = wb_waddr_i;
    assign debug_pc_addr = wb_current_inst_addr_i;
  
   // pc_reg例化
   PC pc_reg(
      .clk(clk),
      .reset(reset),
      .stall(stall),
      .branch_flag(id_branch_flag),
      .branch_target_addr(id_branch_addr),
      .flush(flush),
      .except_pc(exc_pc),
      .pc(pc),
      .rom_enable(rom_en_o)           
      );

    assign rom_addr_o = pc;

    // IF/ID模块例化
    IF_ID if_id(
       .clk(clk),
       .reset(reset),
       .flush(flush),
       .stall(stall),
       .if_pc(pc),
       .if_inst(rom_data_i),
       .id_pc(id_pc_i),
       .id_inst(id_inst_i)          
      );

    // 译码阶段ID模块
    ID id(
       .reset(reset),
       .inst(id_inst_i),
       .pc(id_pc_i),
       .read_data1_i(reg_data1),
       .read_data2_i(reg_data2),
       // 送到regfile的信息
       .re_read1_o(re_read1),
       .re_read2_o(re_read2),       
       .reg_addr1_o(reg_addr1),
       .reg_addr2_o(reg_addr2), 
       // 处于执行阶段的指令的执行结果
       .ex_waddr_i(ex_waddr_o),
       .ex_we_i(ex_we_o),
       .ex_wdata_i(ex_wdata_o),
       // 处于访存阶段指令的执行结果
       .mem_waddr_i(mem_waddr_o),
       .mem_we_i(mem_we_o),
       .mem_wdata_i(mem_wdata_o),  
       .in_delayslot_i(in_delayslot),
       .ex_is_load_i(ex_mem_re_o),
       // 发送暂停请求
       .stallreq(stallreq_from_id),     
       // 送到ID/EX模块的信息
       .alu_func_o(id_func_o),
       .inst_shamt_o(id_shamt_o),
       .reg1_o(id_reg1_o),
       .reg2_o(id_reg2_o),
       .mem_re(id_mem_re_o),
       .mem_we(id_mem_we_o),
       .mem_sign_ext_flag(id_mem_sign_ext_flag_o),
       .mem_sel(id_mem_sel_o),
       .mem_wdata(id_mem_wdata_o),
       // 送给写回阶段的信息
       .reg_we_o(id_we_o),
       .waddr_o(id_waddr_o),
       // 处理分支跳转指令
       .next_in_delayslot_o(id_next_in_delayslot_o),       
       .branch_flag_o(id_branch_flag),
       .branch_target_addr_o(id_branch_addr),       
       .link_addr_o(id_link_addr_o),
       .in_delayslot_o(id_in_delayslot_o),
        // coprocessor 0
       .cp0_we_o(id_cp0_we_o),
       .cp0_re_o(id_cp0_re_o),
       .cp0_addr_o(id_cp0_addr_o),
       .cp0_wdata_o(id_cp0_wdata_o),
        // 异常信号
       .exception_type(id_exception_type_o),
       .current_inst_addr(id_current_inst_addr_o)
      );

     
    // 通用寄存器Regfile例化
    RegFile regfile(
        .clk(clk),
        .reset(reset),
        .we(wb_reg_we_i),
        .waddr(wb_waddr_i),
        .write_data(wb_wdata_i),
        .read_en1(re_read1),
        .read_addr1(reg_addr1),
        .read_data1(reg_data1),
        .read_en2(re_read2),
        .read_addr2(reg_addr2),
        .read_data2(reg_data2)
       );


    ID_EX id_ex(
        .clk(clk),
        .reset(reset), 
        .flush(flush),
        .stall(stall),
        //从译码阶段ID模块传递的信息
        .id_func(id_func_o),
        .id_shamt(id_shamt_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_mem_re(id_mem_re_o),
        .id_mem_we(id_mem_we_o),
        .id_mem_sign_ext_flag(id_mem_sign_ext_flag_o),
        .id_mem_sel(id_mem_sel_o),
        .id_mem_wdata(id_mem_wdata_o),
        .id_waddr(id_waddr_o),
        .id_we(id_we_o),
        .id_link_addr(id_link_addr_o),
        .id_in_delayslot(id_in_delayslot_o),
        .next_in_delayslot_i(id_next_in_delayslot_o),
        .id_cp0_we(id_cp0_we_o),
        .id_cp0_re(id_cp0_re_o),
        .id_cp0_addr(id_cp0_addr_o),
        .id_cp0_wdata(id_cp0_wdata_o),
        .id_exception_type(id_exception_type_o),
        .id_current_inst_addr(id_current_inst_addr_o),
        //传递到执行阶段EX模块的信息
        .ex_func(ex_func_i),
        .ex_shamt(ex_shamt_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_mem_re(ex_mem_re_i), 
        .ex_mem_we(ex_mem_we_i),   
        .ex_mem_sign_ext_flag(ex_mem_sign_ext_flag_i),  
        .ex_mem_sel(ex_mem_sel_i),  
        .ex_mem_wdata(ex_mem_wdata_i),
        .ex_waddr(ex_waddr_i),
        .ex_we(ex_we_i),
        .ex_link_addr(ex_link_addr_i),
        .ex_in_delayslot(ex_in_delayslot_i),
        .in_delayslot_o(in_delayslot),
        .ex_cp0_we(ex_cp0_we_i),
        .ex_cp0_re(ex_cp0_re_i),
        .ex_cp0_addr(ex_cp0_addr_i),
        .ex_cp0_wdata(ex_cp0_wdata_i),
        .ex_exception_type(ex_exception_type_i),
        .ex_current_inst_addr(ex_current_inst_addr_i)
       );        


     EX ex(
         .reset(reset),
         // 送到执行阶段EX模块的信息
         .alu_func_i(ex_func_i),
         .shamt(ex_shamt_i),
         .reg1_i(ex_reg1_i),
         .reg2_i(ex_reg2_i),
         .waddr_i(ex_waddr_i),
         .we_i(ex_we_i),
         // 访存阶段信息的输入
         .mem_re_i(ex_mem_re_i),
         .mem_we_i(ex_mem_we_i),
         .mem_sign_ext_flag_i(ex_mem_sign_ext_flag_i),
         .mem_sel_i(ex_mem_sel_i),
         .mem_wdata_i(ex_mem_wdata_i),
	     // HI、LO寄存器的值
         .hi_i(hi),
         .lo_i(lo),
         .mult_div_result(m_d_result),
         // 回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
         .wb_hi_i(wb_hi_i),
         .wb_lo_i(wb_lo_i),
         .wb_we_hilo_i(wb_we_hilo_i),   
         // 访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
         .mem_hi_i(mem_hi_i),
         .mem_lo_i(mem_lo_i),
         .mem_we_hilo_i(mem_we_hilo_i),
         .stallreq_from_div(stallreq_div),
         .link_addr_i(ex_link_addr_i),
         .in_delayslot_i(ex_in_delayslot_i),
         .exception_type_i(ex_exception_type_i),
         .current_inst_addr_i(ex_current_inst_addr_i),
          // 访问cp0
         .cp0_we_i(ex_cp0_we_i),
         .cp0_re_i(ex_cp0_re_i),
         .cp0_addr_i(ex_cp0_addr_i),
         .cp0_wdata_i(ex_cp0_wdata_i),  
         .cp0_rdata_i(cp0_rdata_o),
         // 访存阶段的指令是否要写CP0，用来检测数据相关
         .mem_cp0_we_i(mem_cp0_we_i),
	     .mem_cp0_waddr_i(mem_cp0_waddr_i),
	     .mem_cp0_wdata_i(mem_cp0_wdata_i),	
	     // 回写阶段的指令是否要写CP0，用来检测数据相关
         .wb_cp0_we_i(wb_cp0_we_i),
	     .wb_cp0_waddr_i(wb_cp0_waddr_i),
	     .wb_cp0_wdata_i(wb_cp0_wdata_i),
         // 发送暂停请求
         .stallreq(stallreq_from_ex),
         .alu_func_o(mult_div_func),
         .op1(opdata1),
         .op2(opdata2),
         // EX模块的输出到EX/MEM模块信息
         .mem_re_o(ex_mem_re_o),
         .mem_we_o(ex_mem_we_o),
         .mem_sign_ext_flag_o(ex_mem_sign_ext_flag_o),
         .mem_sel_o(ex_mem_sel_o),
         .mem_wdata_o(ex_mem_wdata_o),
         .waddr_o(ex_waddr_o),
         .we_o(ex_we_o),
         .wdata_o(ex_wdata_o),
         .hi_o(ex_hi_o),
         .lo_o(ex_lo_o),
         .we_hilo_o(ex_we_hilo_o),
         .cp0_raddr_o(cp0_raddr_i),
         .cp0_we_o(ex_cp0_we_o),
         .cp0_waddr_o(ex_cp0_waddr_o),
         .cp0_wdata_o(ex_cp0_wdata_o),
         // 异常信号
         .exception_type_o(ex_exception_type_o),
         .current_inst_addr_o(ex_current_inst_addr_o),
         .in_delayslot_o(ex_in_delayslot_o)
        );

  
     EX_MEM ex_mem(
         .clk(clk),
         .reset(reset),
         .flush(flush),
         .stall(stall),
         // 来自执行阶段EX模块的信息  
         .ex_mem_re(ex_mem_re_o),
         .ex_mem_we(ex_mem_we_o),
         .ex_mem_sign_ext_flag(ex_mem_sign_ext_flag_o),
         .ex_mem_sel(ex_mem_sel_o),
         .ex_mem_wdata(ex_mem_wdata_o),  
         .ex_waddr(ex_waddr_o),
         .ex_we(ex_we_o),
         .ex_wdata(ex_wdata_o),
         .ex_hi(ex_hi_o),
         .ex_lo(ex_lo_o),
         .ex_we_hilo(ex_we_hilo_o),    
         .ex_cp0_we(ex_cp0_we_o),
         .ex_cp0_waddr(ex_cp0_waddr_o),
         .ex_cp0_wdata(ex_cp0_wdata_o), 
         .ex_exception_type(ex_exception_type_o),
         .ex_current_inst_addr(ex_current_inst_addr_o),
         .ex_in_delayslot(ex_in_delayslot_o),
        // 送到访存阶段MEM模块的信息
         .m_mem_re(m_mem_re_i), 
         .m_mem_we(m_mem_we_i),   
         .m_mem_sign_ext_flag(m_mem_sign_ext_flag_i),  
         .m_mem_sel(m_mem_sel_i),  
         .m_mem_wdata(m_mem_wdata_i),
         .mem_waddr(mem_waddr_i),
         .mem_we(mem_we_i),
         .mem_wdata(mem_wdata_i),
         .mem_hi(mem_hi_i),
         .mem_lo(mem_lo_i),
         .mem_we_hilo(mem_we_hilo_i),
         .mem_cp0_we(mem_cp0_we_i),
         .mem_cp0_waddr(mem_cp0_waddr_i),
         .mem_cp0_wdata(mem_cp0_wdata_i),
         .mem_exception_type(mem_exception_type_i),
         .mem_current_inst_addr(mem_current_inst_addr_i),
         .mem_in_delayslot(mem_in_delayslot_i)                     
        );


     MEM mem(
        .reset(reset),
        // 来自EX/MEM模块的信息    
        .mem_re_i(m_mem_re_i), 
        .mem_we_i(m_mem_we_i),   
        .mem_sign_ext_flag_i(m_mem_sign_ext_flag_i),  
        .mem_sel_i(m_mem_sel_i),  
        .mem_wdata_i(m_mem_wdata_i),
        .waddr_i(mem_waddr_i),
        .we_i(mem_we_i),
        .wdata_i(mem_wdata_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),
        .we_hilo_i(mem_we_hilo_i), 
        .cp0_we_i(mem_cp0_we_i),
        .cp0_waddr_i(mem_cp0_waddr_i),
        .cp0_wdata_i(mem_cp0_wdata_i),
        // 来自ram的信息 
        .ram_rdata_i(ram_data_i),  
        // 异常信号
        .cp0_status_i(cp0_status),
        .cp0_cause_i(cp0_cause),
        .cp0_epc_i(cp0_epc),
        .exception_type_i(mem_exception_type_i),
        .in_delayslot_i(mem_in_delayslot_i),
        .current_inst_addr_i(mem_current_inst_addr_i),
       // 回写阶段的指令是否要写CP0，用来检测数据相关
        .wb_cp0_we_i(wb_cp0_we_i),
	    .wb_cp0_waddr_i(wb_cp0_waddr_i),
	    .wb_cp0_wdata_i(wb_cp0_wdata_i),         
        // 送到MEM/WB模块的信息
        .waddr_o(mem_waddr_o),
        .we_o(mem_we_o),
        .wdata_o(mem_wdata_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o),
        .we_hilo_o(mem_we_hilo_o),
        .cp0_we_o(mem_cp0_we_o),
        .cp0_waddr_o(mem_cp0_waddr_o),
        .cp0_wdata_o(mem_cp0_wdata_o),
        // 异常操作信号
        .cp0_badvaddr_wdata_o(mem_latest_badvaddr_o),
        .cp0_epc_o(mem_latest_epc_o),
        .exception_type_o(mem_exception_type_o),
        .in_delayslot_o(mem_in_delayslot_o),
        .current_inst_addr_o(mem_current_inst_addr_o),
        // 送到ram的信息
        .ram_addr_o(ram_addr_o),
        .ram_we_o(ram_we_o),
        .ram_sel_o(ram_sel_o),
        .ram_wdata_o(ram_data_o),
        .ram_en_o(ram_en_o)
       );


      // MEM/WB模块
     MEM_WB mem_wb(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        // 来自访存阶段MEM模块的信息    
        .mem_waddr(mem_waddr_o),
        .mem_we(mem_we_o),
        .mem_wdata(mem_wdata_o),
        .mem_hi(mem_hi_o),
        .mem_lo(mem_lo_o),
        .mem_we_hilo(mem_we_hilo_o),
        .mem_cp0_we(mem_cp0_we_o),
        .mem_cp0_waddr(mem_cp0_waddr_o),
        .mem_cp0_wdata(mem_cp0_wdata_o),
        .mem_current_inst_addr(mem_current_inst_addr_o),
        // 送到回写阶段的信息
        .wb_waddr(wb_waddr_i),
        .wb_we(wb_reg_we_i),
        .wb_wdata(wb_wdata_i),
        .wb_hi(wb_hi_i),
        .wb_lo(wb_lo_i),
        .wb_we_hilo(wb_we_hilo_i),
        .wb_cp0_we(wb_cp0_we_i),
        .wb_cp0_waddr(wb_cp0_waddr_i),
        .wb_cp0_wdata(wb_cp0_wdata_i),
        .wb_current_inst_addr(wb_current_inst_addr_i)                        
       );
       
       
        HILO hilo_reg(
               .clk(clk),
               .reset(reset),           
               //写端口
               .we(wb_we_hilo_i),
               .hi_i(wb_hi_i),
               .lo_i(wb_lo_i),           
               //读端口1
               .hi_o(hi),
               .lo_o(lo)    
             );
       
       
       	CTRL ctrl(
               .reset(reset),        
               // 来自译码阶段的暂停请求 
               .stallreq_from_id(stallreq_from_id),        
               // 来自执行阶段的暂停请求
               .stallreq_from_ex(stallreq_from_ex),   
               // 来自取指或访存阶段的的暂停请求
               .stallreq_from_if_or_mem(halt),
               	// 异常信号
               .cp0_epc(mem_latest_epc_o),
               .exception_type(mem_exception_type_o),
	           // 发送各个阶段的暂停信号  
               .stall(stall),
               // 异常操作信号
               .flush(flush),
               .exc_pc(exc_pc)      
              );             
       
              
        MULT_DIV  mult_div(
               .clk(clk),
               .reset(reset),
               .flush(flush),
               .func(mult_div_func),
               .reg1_i(opdata1),
               .reg2_i(opdata2),
               .result(m_d_result),
               .stallreq_for_div(stallreq_div)
             );  
             
             
        CP0  cp0_reg(
		      .clk(clk),
		      .reset(reset),
		      .we_i(wb_cp0_we_i),
		      .waddr_i(wb_cp0_waddr_i),
		      .raddr_i(cp0_raddr_i),
		      .wdata_i(wb_cp0_wdata_i),
		      .int_i(int_i),
		      .cp0_badvaddr_wdata_i(mem_latest_badvaddr_o),
		      .exception_type_i(mem_exception_type_o),
		      .current_inst_addr_i(mem_current_inst_addr_o),
		      .in_delayslot_i(mem_in_delayslot_o),
	          .status(cp0_status),
	          .cause(cp0_cause),
	          .epc(cp0_epc),
	          .rdata_o(cp0_rdata_o),  
		      .timer_int_o(timer_int_o)  		
	         );   
           
endmodule
