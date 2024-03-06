`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 14:57:10
// Design Name: 
// Module Name: defines
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

// 全局
`define OpWidth 6
`define AluFuncBus 5:0
`define IntBus 5:0
`define ZeroWord 32'h00000000
`define InstOpBus 5:0
`define InstShamtBus 4:0
`define InstImmBus 15:0
`define StallBus 5:0
`define Stop 1'b1
`define NoStop 1'b0
`define Branch 1'b1
`define NoBranch 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0



// 指令操作码

// r-type (SPECIAL)
`define OP_SPECIAL    6'b000000
// reg-imm
`define OP_REGIMM     6'b000001
// some branch instructions
`define REGIMM_BLTZ     5'b00000
`define REGIMM_BLTZAL   5'b10000
`define REGIMM_BGEZ     5'b00001
`define REGIMM_BGEZAL   5'b10001
// j-type
`define OP_J          6'b000010
`define OP_JAL        6'b000011
// branch
`define OP_BEQ        6'b000100
`define OP_BNE        6'b000101
`define OP_BLEZ       6'b000110
`define OP_BGTZ       6'b000111
// arithmetic
`define OP_ADDI       6'b001000
`define OP_ADDIU      6'b001001
// comparison
`define OP_SLTI       6'b001010
`define OP_SLTIU      6'b001011
// logic
`define OP_ANDI       6'b001100
`define OP_ORI        6'b001101
`define OP_XORI       6'b001110
// immediate
`define OP_LUI        6'b001111
// coprocessor
`define OP_CP0        6'b010000
// memory accessing
`define OP_LB         6'b100000
`define OP_LH         6'b100001
`define OP_LW         6'b100011
`define OP_LBU        6'b100100
`define OP_LHU        6'b100101
`define OP_SB         6'b101000
`define OP_SH         6'b101001
`define OP_SW         6'b101011



// 功能码

// shift
`define FUNCT_SLL       6'b000000
`define FUNCT_SRL       6'b000010
`define FUNCT_SRA       6'b000011
`define FUNCT_SLLV      6'b000100
`define FUNCT_SRLV      6'b000110
`define FUNCT_SRAV      6'b000111
// jump
`define FUNCT_JR        6'b001000
`define FUNCT_JALR      6'b001001
// interruption
`define FUNCT_SYSCALL   6'b001100
`define FUNCT_BREAK     6'b001101
// HI & LO
`define FUNCT_MFHI      6'b010000
`define FUNCT_MTHI      6'b010001
`define FUNCT_MFLO      6'b010010
`define FUNCT_MTLO      6'b010011
// multiplication & division
`define FUNCT_MULT      6'b011000
`define FUNCT_MULTU     6'b011001
`define FUNCT_DIV       6'b011010
`define FUNCT_DIVU      6'b011011
// arithmetic
`define FUNCT_ADD       6'b100000
`define FUNCT_ADDU      6'b100001
`define FUNCT_SUB       6'b100010
`define FUNCT_SUBU      6'b100011
// logic
`define FUNCT_AND       6'b100100
`define FUNCT_OR        6'b100101
`define FUNCT_XOR       6'b100110
`define FUNCT_NOR       6'b100111
// comparison
`define FUNCT_SLT       6'b101010
`define FUNCT_SLTU      6'b101011

`define FUNCT_NOP       6'b111111



// 指令存储器inst_rom
`define InstAddrWidth 32
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17



// 数据存储器data_ram
`define MemSel 3:0
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0



// 通用寄存器regfile
`define RegWriteBus 0:0
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000



// 除法
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11



// coprocessor instructions
`define CP0_MFC0        5'b00000
`define CP0_MTC0        5'b00100
`define CP0_ERET        5'b10000
`define CP0_ERET_FULL   32'h42000018

// coprocessor 0 register address 
`define CP0RegAddrBus 7:0
`define CP0_REG_BADVADDR 8'b01000000
`define CP0_REG_COUNT    8'b01001000        
`define CP0_REG_COMPARE  8'b01011000      
`define CP0_REG_STATUS   8'b01100000       
`define CP0_REG_CAUSE    8'b01101000        
`define CP0_REG_EPC      8'b01110000      

// coprocessor 0 segment of STATUS & CAUSE
`define CP0_SEG_BEV           22      // STATUS
`define CP0_SEG_IM            15:8    // STATUS
`define CP0_SEG_EXL           1       // STATUS
`define CP0_SEG_IE            0       // STATUS
`define CP0_SEG_BD            31      // CAUSE
`define CP0_SEG_TI            30      // CAUSE
`define CP0_SEG_HWI           15:10   // CAUSE
`define CP0_SEG_SWI           9:8     // CAUSE
`define CP0_SEG_IP            15:8    // CAUSE
`define CP0_SEG_EXCCODE       6:2     // CAUSE    



// exception entrance
`define INIT_PC             32'hBFC00380

// exception type bus
`define EXC_TYPE_BUS          4:0
`define EXC_TYPE_BUS_WIDTH    5

// exception type segment position
`define EXC_TYPE_POS_RI     0
`define EXC_TYPE_POS_OV     1
`define EXC_TYPE_POS_BP     2
`define EXC_TYPE_POS_SYS    3 
`define EXC_TYPE_POS_ERET   4

// exception type 
`define EXC_TYPE_NULL       5'h0
`define EXC_TYPE_INT        5'h1
`define EXC_TYPE_IF         5'h2
`define EXC_TYPE_RI         5'h3
`define EXC_TYPE_OV         5'h4
`define EXC_TYPE_BP         5'h5
`define EXC_TYPE_SYS        5'h6
`define EXC_TYPE_ADEL       5'h7
`define EXC_TYPE_ADES       5'h8
`define EXC_TYPE_ERET       5'h9

// ExcCode 
`define CP0_EXCCODE_INT          5'h00
`define CP0_EXCCODE_ADEL         5'h04
`define CP0_EXCCODE_ADES         5'h05
`define CP0_EXCCODE_SYS          5'h08
`define CP0_EXCCODE_BP           5'h09
`define CP0_EXCCODE_RI           5'h0a
`define CP0_EXCCODE_OV           5'h0c