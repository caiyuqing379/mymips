`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 13:05:44
// Design Name: 
// Module Name: ID
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
 
module ID(
    input wire reset,
    input wire[`InstBus] inst,
    input wire[`InstAddrBus] pc,
    // 读取的RegFile的值
    input wire[`RegBus] read_data1_i,
    input wire[`RegBus] read_data2_i,
    // 输出到RegFile的信息
    output reg re_read1_o,
    output reg re_read2_o,
    output reg [`RegAddrBus] reg_addr1_o,
    output reg [`RegAddrBus] reg_addr2_o,
    // 处于执行阶段的指令的执行结果
    input wire [`RegAddrBus] ex_waddr_i,
    input wire ex_we_i,
    input wire [`RegBus] ex_wdata_i,
    // 处于访存阶段指令的执行结果
    input wire [`RegAddrBus] mem_waddr_i,
    input wire mem_we_i,
    input wire [`RegBus] mem_wdata_i, 
    // 当前处于译码阶段的指令是否位于延迟槽
    input wire in_delayslot_i,
    input wire ex_is_load_i,
    // 发送暂停请求
    output wire stallreq,
    // 送到执行阶段的信息
    output wire[`AluFuncBus] alu_func_o,
    output wire[`InstShamtBus] inst_shamt_o,
    output reg [`RegBus] reg1_o,
    output wire [`RegBus] reg2_o,
    // 送到访存阶段的信息
    output wire mem_re,
    output wire mem_we,
    output wire mem_sign_ext_flag,
    output wire[`MemSel] mem_sel,
    output wire[`DataBus] mem_wdata,
    // 送给写回阶段的信息
    output wire[`RegWriteBus] reg_we_o,
    output reg[`RegAddrBus] waddr_o,    
    // 处理分支跳转指令
    output reg next_in_delayslot_o,       
    output reg branch_flag_o,
    output reg[`RegBus] branch_target_addr_o,       
    output reg[`RegBus] link_addr_o,
    output wire in_delayslot_o,
    // coprocessor 0
    output reg cp0_we_o,
    output reg cp0_re_o,
    output reg[`CP0RegAddrBus] cp0_addr_o,
    output reg[`RegBus] cp0_wdata_o,
    // 异常信号
    output wire[`EXC_TYPE_BUS] exception_type,
    output wire[`InstAddrBus] current_inst_addr
    );
    
    reg[`RegWriteBus] we_reg_o;
    assign reg_we_o = we_reg_o;
    
    reg stallreq_for_reg1_loadrelate, stallreq_for_reg2_loadrelate;
    assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
    
    // 从指令中获取信息
    wire[5:0] inst_op = inst[31:26];
    wire[4:0] inst_rs = inst[25:21];
    wire[4:0] inst_rt = inst[20:16];
    wire[4:0] inst_rd = inst[15:11];
    assign inst_shamt_o = inst[10:6];
    wire[5:0] inst_func = inst[5:0];

    // 保存指令执行所需要的立即数
    reg [`RegBus] imm;
    wire[`RegBus] zero_extended_imm = {16'b0, inst[15:0]};
    wire[`RegBus] zero_extended_imm_hi = {inst[15:0], 16'b0};
    wire[`RegBus] sign_extended_imm = {{16{inst[15]}}, inst[15:0]};

    // 获取读和写registers的信息
    always @(*) begin
        if (!reset) 
        begin
            re_read1_o <= 0;
            re_read2_o <= 0;
            reg_addr1_o <= `NOPRegAddr;
            reg_addr2_o <= `NOPRegAddr;
            we_reg_o <= 0;
            waddr_o <= `NOPRegAddr;
            imm <= `ZeroWord;
        end
        else begin
             re_read1_o <= 0;
             re_read2_o <= 0;
             reg_addr1_o <= inst_rs;
             reg_addr2_o <= inst_rt;
             we_reg_o <= 0;
             waddr_o <= inst_rd;
             imm <= `ZeroWord;
            case (inst_op)
                `OP_ANDI,`OP_ORI,`OP_XORI: begin
                                             re_read1_o <= 1;
                                             re_read2_o <= 0;
                                             we_reg_o <= 1;
                                             waddr_o <= inst_rt;
                                             imm <= zero_extended_imm;
                                           end
                `OP_LUI: begin
                           re_read1_o <= 1;
                           re_read2_o <= 0;
                           we_reg_o <= 1;
                           waddr_o <= inst_rt;
                           imm <= zero_extended_imm_hi;
                         end
                `OP_SPECIAL:begin
                              case(inst[25:0])
                                   26'd0:begin      //nop
                                         end
                                   default:begin
                                             re_read1_o <= 1;
                                             re_read2_o <= 1;
                                             we_reg_o <= 1;                      
                                           end
                              endcase
                            end
                `OP_ADDI,`OP_ADDIU,`OP_SLTI,`OP_SLTIU,
                `OP_LB,`OP_LH,`OP_LW,`OP_LBU,`OP_LHU:begin
                                                         re_read1_o <= 1;
                                                         re_read2_o <= 0;
                                                         we_reg_o <= 1;
                                                         waddr_o <= inst_rt;
                                                         imm <= sign_extended_imm;
                                                      end
                `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
                `OP_SB, `OP_SH, `OP_SW: begin
                                          re_read1_o <= 1;
                                          re_read2_o <= 1;
                                          we_reg_o <= 0;
                                        end
                `OP_REGIMM: begin
                               case (inst_rt)
                                  `REGIMM_BGEZAL, `REGIMM_BLTZAL: begin
                                                                    re_read1_o <= 1;
                                                                    re_read2_o <= 0;
                                                                    we_reg_o <= 1;
                                                                    waddr_o <= 5'b11111;
                                                                  end
                                 `REGIMM_BGEZ,`REGIMM_BLTZ: begin
                                                              re_read1_o <= 1;
                                                              re_read2_o <= 0;
                                                              we_reg_o <= 0;
                                                            end
                                 default: begin end
                              endcase
                           end
                `OP_LUI: begin
                            re_read1_o <= 0;
                            re_read2_o <= 0;
                            we_reg_o <= 1;
                            waddr_o <= inst_rt;
                         end
                `OP_JAL: begin
                            re_read1_o <= 0;
                            re_read2_o <= 0;
                            we_reg_o <= 1;
                            waddr_o <= 5'b11111;
                        end
                `OP_CP0: begin
                            case({inst_rs,inst[10:3]})
                               {`CP0_MFC0,8'd0}: begin
                                             re_read1_o <= 0;
                                             re_read2_o <= 0;
                                             we_reg_o <= 1;
                                             waddr_o <= inst_rt;
                                          end
                               {`CP0_MTC0,8'd0}: begin
                                             re_read1_o <= 1;
                                             reg_addr1_o <= inst_rt;
                                             re_read2_o <= 0;
                                             we_reg_o <= 0;
                                          end
                                 default: begin end
                             endcase
                        end
                default: begin end
           endcase
        end
    end

    // 产生ALU控制信号
    ALUControl alu_control(inst_op, inst_func, inst_rt, alu_func_o);

    // 确定进行运算的源操作数1
    always @(*) begin
        stallreq_for_reg1_loadrelate <= `NoStop;
        if (!reset) 
        begin
            reg1_o <= `ZeroWord;
        end
        else if(ex_is_load_i == 1'b1 && ex_waddr_i == reg_addr1_o && re_read1_o == 1'b1 ) begin
                  stallreq_for_reg1_loadrelate <= `Stop;    
        end
        else if(re_read1_o && ex_we_i && ex_waddr_i == reg_addr1_o)begin
            reg1_o <= ex_wdata_i;
        end
        else if(re_read1_o && mem_we_i && mem_waddr_i == reg_addr1_o)begin
            reg1_o <= mem_wdata_i;
        end
        else if( re_read1_o==1'b1) begin
            reg1_o <= read_data1_i;
        end
        else if( re_read1_o==1'b0) begin
            reg1_o <= imm;
        end
        else begin
            reg1_o <= `ZeroWord;
        end
    end

     reg[`RegBus] temp_reg2_o;
     
    // 确定进行运算的源操作数2
    always @(*) begin
        stallreq_for_reg2_loadrelate <= `NoStop;
        if (!reset) 
        begin
            temp_reg2_o <= `ZeroWord;
        end
        else if(ex_is_load_i == 1'b1 && ex_waddr_i == reg_addr2_o && re_read2_o == 1'b1 ) begin
                  stallreq_for_reg2_loadrelate <= `Stop;    
        end
        else if(re_read2_o && ex_we_i && ex_waddr_i == reg_addr2_o)begin
            temp_reg2_o <= ex_wdata_i;
        end
        else if(re_read2_o && mem_we_i && mem_waddr_i == reg_addr2_o)begin
            temp_reg2_o <= mem_wdata_i;
        end
        else if( re_read2_o==1'b1) begin
            temp_reg2_o <= read_data2_i;
        end
        else if( re_read2_o==1'b0) begin
            temp_reg2_o <= imm;
        end
        else begin
            temp_reg2_o <= `ZeroWord;
        end
    end
    
    assign reg2_o = (inst_op == `OP_SB || inst_op == `OP_SH || inst_op == `OP_SW) ? sign_extended_imm : temp_reg2_o;
        
        
    // 计算分支地址
    wire[`InstAddrBus] pc_plus4 = pc + 3'h4;
    wire[`InstAddrBus] pc_plus8 = pc + 4'h8;
    wire[25:0] jump_addr = inst[25:0];
    wire[`RegBus] sign_extended_imm_sll2 = {{14{inst[15]}}, inst[15:0], 2'b00};
    
    assign in_delayslot_o = reset ? in_delayslot_i : 1'b0;

    always @(*) begin
        if (!reset) begin
            link_addr_o <= `ZeroWord;
            branch_flag_o <= `NoBranch;
            branch_target_addr_o <= `ZeroWord;
            next_in_delayslot_o <= 1'b0;
        end
        else begin
            case (inst_op)
                `OP_J: begin
                          link_addr_o <= `ZeroWord;
                          branch_flag_o <= `Branch;
                          branch_target_addr_o <= (pc == {pc_plus4[31:28], jump_addr, 2'b00}) ? `INIT_PC : {pc_plus4[31:28], jump_addr, 2'b00};
                          next_in_delayslot_o <= `InDelaySlot;
                       end
                `OP_SPECIAL: begin
                                case(inst_func)
                                    `FUNCT_JR: begin
                                                  link_addr_o <= `ZeroWord;
                                                  branch_flag_o <= `Branch;
                                                  branch_target_addr_o <= (pc == reg1_o) ? `INIT_PC : reg1_o;
                                                  next_in_delayslot_o <= `InDelaySlot;
                                               end
                                    `FUNCT_JALR: begin
                                                    link_addr_o <= pc_plus8;
                                                    branch_flag_o <= `Branch;
                                                    branch_target_addr_o <= (pc == reg1_o) ? `INIT_PC : reg1_o;
                                                    next_in_delayslot_o <= `InDelaySlot;
                                                 end                                                   

                                   default: begin 
                                               link_addr_o <= `ZeroWord;
                                               branch_flag_o <= `NoBranch;
                                               branch_target_addr_o <= `ZeroWord;
                                               next_in_delayslot_o <= `NotInDelaySlot;
                                            end
                                  endcase
                              end
                `OP_JAL: begin
                            link_addr_o <= pc_plus8;
                            branch_flag_o <= `Branch;
                            branch_target_addr_o <= (pc == {pc_plus4[31:28], jump_addr, 2'b00}) ? `INIT_PC : {pc_plus4[31:28], jump_addr, 2'b00};
                            next_in_delayslot_o <= `InDelaySlot;
                         end
                `OP_BEQ: begin
                             link_addr_o <= `ZeroWord;
                             next_in_delayslot_o <= `InDelaySlot;
                             if(reg1_o == reg2_o)
                             begin
                                 branch_flag_o <= `Branch;
                                 branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                             end
                             else begin
                                     branch_flag_o <= `NoBranch;
                                     branch_target_addr_o <= `ZeroWord;
                             end
                          end
                `OP_BGTZ: begin
                             link_addr_o <= `ZeroWord;
                             next_in_delayslot_o <= `InDelaySlot;
                             if (!reg1_o[31] && reg1_o) 
                             begin
                                 branch_flag_o <= `Branch;
                                 branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                             end
                             else begin
                                     branch_flag_o <= `NoBranch;
                                     branch_target_addr_o <= `ZeroWord;
                             end 
                          end
                `OP_BLEZ: begin
                             link_addr_o <= `ZeroWord;
                             next_in_delayslot_o <= `InDelaySlot;
                             if (reg1_o[31] || !reg1_o) 
                             begin
                                 branch_flag_o <= `Branch;
                                 branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                             end
                             else begin
                                  branch_flag_o <= `NoBranch;
                                  branch_target_addr_o <= `ZeroWord;
                             end 
                         end
                `OP_BNE: begin
                             link_addr_o <= `ZeroWord;
                             next_in_delayslot_o <= `InDelaySlot;                             
                             if ( reg1_o != reg2_o) 
                             begin
                                branch_flag_o <= `Branch;
                                branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                             end
                             else begin
                                     branch_flag_o <= `NoBranch;
                                     branch_target_addr_o <= `ZeroWord;
                            end 
                         end
                `OP_REGIMM: begin
                               case (inst_rt)
                                 `REGIMM_BLTZ: begin
                                                  link_addr_o <= `ZeroWord;
                                                  next_in_delayslot_o <= `InDelaySlot;
                                                  if (reg1_o[31] == 1'b1) 
                                                  begin
                                                      branch_flag_o <= `Branch;
                                                      branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;                                                      
                                                  end
                                                  else begin
                                                          branch_flag_o <= `NoBranch;
                                                          branch_target_addr_o <= `ZeroWord;
                                                  end 
                                              end
                               `REGIMM_BLTZAL: begin
                                                  link_addr_o <= pc_plus8;
                                                  next_in_delayslot_o <= `InDelaySlot;
                                                  if (reg1_o[31] == 1'b1) 
                                                  begin
                                                     branch_flag_o <= `Branch;
                                                     branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                                                  end
                                                  else begin
                                                          branch_flag_o <= `NoBranch;
                                                          branch_target_addr_o <= `ZeroWord;
                                                       end 
                                              end
                               `REGIMM_BGEZ: begin
                                                  link_addr_o <= `ZeroWord;
                                                  next_in_delayslot_o <= `InDelaySlot;
                                                  if (reg1_o[31] == 1'b0) 
                                                  begin
                                                     branch_flag_o <= `Branch;
                                                     branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                                                  end
                                                  else begin
                                                          branch_flag_o <= `NoBranch;
                                                          branch_target_addr_o <= `ZeroWord;
                                                  end 
                                            end
                                `REGIMM_BGEZAL: begin
                                                   link_addr_o <= pc_plus8;
                                                   next_in_delayslot_o <= `InDelaySlot;
                                                   if (reg1_o[31] == 1'b0) 
                                                   begin
                                                      branch_flag_o <= `Branch;
                                                      branch_target_addr_o <= (pc == pc_plus4 + sign_extended_imm_sll2) ? `INIT_PC : pc_plus4 + sign_extended_imm_sll2;
                                                   end
                                                   else begin
                                                          branch_flag_o <= `NoBranch;
                                                          branch_target_addr_o <= `ZeroWord;
                                                   end 
                                                end                                
                                default: begin
                                             link_addr_o <= `ZeroWord;
                                             branch_flag_o <= `NoBranch;
                                             branch_target_addr_o <= `ZeroWord;
                                             next_in_delayslot_o <= `NotInDelaySlot;
                                         end
                             endcase
                           end
               default: begin
                           link_addr_o <= `ZeroWord;
                           branch_flag_o <= `NoBranch;
                           branch_target_addr_o <= `ZeroWord;
                           next_in_delayslot_o <= `NotInDelaySlot;
                        end
            endcase
        end
    end
    
    
    // 确定送到访存阶段的信息
    assign mem_we = ~reset ? 1'b0 : (inst_op == `OP_SB || inst_op == `OP_SH || inst_op == `OP_SW) ? 1'b1: 1'b0 ;
    
    assign mem_re = ~reset ? 1'b0 : (inst_op == `OP_LB || inst_op == `OP_LBU || inst_op == `OP_LH 
                                     || inst_op == `OP_LHU || inst_op == `OP_LW) ? 1'b1 :1'b0;
                                     
    assign mem_sign_ext_flag = ~reset ? 1'b0 : (inst_op == `OP_LB || inst_op == `OP_LH || inst_op == `OP_LW) ? 1'b1 : 1'b0;
    
    assign mem_wdata = ~reset ? 1'b0 : (inst_op == `OP_SB || inst_op == `OP_SH || inst_op == `OP_SW) ? temp_reg2_o: 1'b0 ;
    
    assign mem_sel = ~reset ? 4'b0000 : (inst_op == `OP_LB || inst_op == `OP_LBU || inst_op == `OP_SB )
                            ? 4'b0001 : (inst_op == `OP_LH || inst_op == `OP_LHU || inst_op == `OP_SH)
                            ? 4'b0011 : (inst_op == `OP_LW || inst_op == `OP_SW)
                            ? 4'b1111 :4'b0000;                 
                            
                            
    // 产生CP0的读写地址和数据
    always @(*) begin
        if (!reset) begin
            cp0_we_o <= 1'b0;
            cp0_re_o <= 1'b0;
            cp0_addr_o <= 8'd0;
            cp0_wdata_o <= `ZeroWord;
        end
        else begin
               case({inst_op,inst_rs,inst[10:3]})
               {`OP_CP0,`CP0_MTC0,8'd0}: begin
                                            cp0_we_o <= 1'b1;
                                            cp0_re_o <= 1'b0;
                                            cp0_addr_o <= {inst_rd, inst[2:0]};
                                            cp0_wdata_o <= reg1_o;
                                         end
               {`OP_CP0,`CP0_MFC0,8'd0}: begin
                                            cp0_we_o <= 1'b0;
                                            cp0_re_o <= 1'b1;
                                            cp0_addr_o <= {inst_rd, inst[2:0]};
                                            cp0_wdata_o <= `ZeroWord;
                                         end

              default: begin
                          cp0_we_o <= 1'b0;
                          cp0_re_o <= 1'b0;
                          cp0_addr_o <= 8'd0;
                          cp0_wdata_o <= `ZeroWord;
                      end                  
            endcase
        end
    end
    
    
    // 产生异常信号
    reg invalid_inst_tag, overflow_inst_tag, syscall_tag, break_tag, eret_tag;
    assign exception_type = reset ? { eret_tag, syscall_tag, break_tag, overflow_inst_tag, invalid_inst_tag } : `EXC_TYPE_NULL;
    assign current_inst_addr = reset ? pc : `ZeroWord;

    always @(*) begin
        if (!reset) 
        begin
            {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00000;
        end
        else begin
            if (inst == `CP0_ERET_FULL) 
            begin
                {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00001;
            end
            else begin
                case (inst_op)
                    `OP_SPECIAL: begin
                        case (inst_func)
                            `FUNCT_SLL, `FUNCT_SRL, `FUNCT_SRA, `FUNCT_SLLV,
                            `FUNCT_SRLV, `FUNCT_SRAV, `FUNCT_JR, `FUNCT_JALR,
                            `FUNCT_MFHI, `FUNCT_MTHI, `FUNCT_MFLO, `FUNCT_MTLO,
                            `FUNCT_MULT, `FUNCT_MULTU, `FUNCT_DIV, `FUNCT_DIVU,
                            `FUNCT_ADDU, `FUNCT_SUBU, `FUNCT_AND, `FUNCT_OR,
                            `FUNCT_XOR, `FUNCT_NOR, `FUNCT_SLT, `FUNCT_SLTU: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00000;
                            `FUNCT_ADD, `FUNCT_SUB: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b01000;
                            `FUNCT_SYSCALL: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00100;
                            `FUNCT_BREAK: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00010;
                            default: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b10000;
                        endcase
                    end
                    `OP_REGIMM: begin
                        case (inst_rt)
                            `REGIMM_BLTZ, `REGIMM_BLTZAL, `REGIMM_BGEZ,
                            `REGIMM_BGEZAL: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00000;
                            default: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b10000;
                        endcase
                    end
                    `OP_CP0: begin
                        case (inst_rs)
                            `CP0_MFC0, `CP0_MTC0: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00000;
                            default: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b10000;
                        endcase
                    end
                    `OP_J, `OP_JAL, `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
                    `OP_ADDIU, `OP_SLTI, `OP_SLTIU, `OP_ANDI, `OP_ORI,
                    `OP_XORI, `OP_LUI, `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
                    `OP_LHU, `OP_SB, `OP_SH, `OP_SW: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b00000;
                    `OP_ADDI: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b01000;
                    default: {invalid_inst_tag,overflow_inst_tag,syscall_tag,break_tag,eret_tag} <= 5'b10000;
                endcase
            end
        end
    end

endmodule
