`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 16:17:01
// Design Name: 
// Module Name: ALUControl
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

module ALUControl(
    input wire[`InstOpBus] op,
    input wire[`AluFuncBus] inst_func,
    input wire[`RegAddrBus] rt,
    output reg[`AluFuncBus] func
);

    // 为了执行阶段产生功能信息
    always @(*) begin
        case (op)
            `OP_SPECIAL: func <= inst_func;
            `OP_ORI: func <= `FUNCT_OR;
            `OP_ANDI: func <= `FUNCT_AND;
            `OP_XORI: func <= `FUNCT_XOR;
            `OP_LUI: func <= `FUNCT_OR;
            `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW,
            `OP_SB, `OP_SH, `OP_SW, `OP_ADDI: func <= `FUNCT_ADD;
            `OP_ADDIU: func <= `FUNCT_ADDU;
            `OP_SLTI: func <= `FUNCT_SLT;
            `OP_SLTIU: func <= `FUNCT_SLTU;
            `OP_JAL: func <= `FUNCT_JALR;
            `OP_REGIMM: begin
                          case (rt)
                              `REGIMM_BLTZAL, `REGIMM_BGEZAL: func <= `FUNCT_JALR;
                              default: func <= `FUNCT_NOP;
                          endcase
                       end
            default: func <= `FUNCT_NOP;
        endcase
    end

endmodule 
