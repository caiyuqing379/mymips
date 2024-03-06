`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/11 17:12:13
// Design Name: 
// Module Name: CP0
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

module CP0(
	input wire	clk,
	input wire	reset,
	input wire  we_i,
	input wire[`CP0RegAddrBus] waddr_i,
	input wire[`CP0RegAddrBus] raddr_i,
	input wire[`RegBus] wdata_i,	
	input wire[`IntBus] int_i,
	input wire[`RegBus] cp0_badvaddr_wdata_i,
	input wire[`EXC_TYPE_BUS] exception_type_i,
	input wire[`RegBus] current_inst_addr_i,
	input wire in_delayslot_i,	
	output reg[`RegBus] status,
	output reg[`RegBus] cause,
	output reg[`RegBus] epc,	
	output reg[`RegBus] rdata_o,
	output reg timer_int_o    	
);

    reg flag;
    
    // Coprocessor 0 registers
    reg[`RegBus] badvaddr,count,compare;
    
    
	always @ (posedge clk) 
	begin
		if(!reset) begin
		    badvaddr <= `ZeroWord;
		    flag <= 1'b0;
			count <= `ZeroWord;
			compare <= `ZeroWord;
			status <= 32'b00000000010000000000000000000000;
			cause <= `ZeroWord;
			epc <= `ZeroWord;
            timer_int_o <= `InterruptNotAssert;
		end 
		else begin
		  flag <= ~flag;
		  count <= (flag == 1'b1) ? count + 1'b1 : count;
		  cause[15:10] <= int_i;
		  timer_int_o <= (compare != `ZeroWord && count == compare) ? `InterruptAssert : timer_int_o;
		  cause[30] <= (compare != `ZeroWord && count == compare) ? `InterruptAssert : cause[30];
		  					
			if(we_i == 1'b1) 
			begin
				case (waddr_i) 
				    `CP0_REG_BADVADDR: badvaddr <= wdata_i;
					`CP0_REG_COUNT: count <= wdata_i;
					`CP0_REG_COMPARE:	begin
						                  compare <= wdata_i;
                                          timer_int_o <= `InterruptNotAssert;
                                          cause[30] <= `InterruptNotAssert;
					                    end
					`CP0_REG_STATUS: status <= wdata_i;
					`CP0_REG_EPC: epc <= wdata_i;
					 // cause寄存器只有IP[1:0]字段是可写的
					`CP0_REG_CAUSE: cause[9:8] <= wdata_i[9:8];		
				endcase  
			end		
			
			case (exception_type_i)
                 `EXC_TYPE_INT: begin
                                  epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                  cause[`CP0_SEG_BD] <= in_delayslot_i;
                                  status[`CP0_SEG_EXL] <= 1'b1;
                                  cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_INT;
                               end
                `EXC_TYPE_IF,`EXC_TYPE_ADEL: begin
                                  epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                  cause[`CP0_SEG_BD] <= in_delayslot_i;
                                  badvaddr <= cp0_badvaddr_wdata_i;
                                  status[`CP0_SEG_EXL] <= 1'b1;
                                  cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADEL;
                              end
                `EXC_TYPE_RI: begin
                                 epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                 cause[`CP0_SEG_BD] <= in_delayslot_i;
                                 status[`CP0_SEG_EXL] <= 1'b1;
                                 cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_RI;
                              end
                `EXC_TYPE_OV: begin
                                 epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                 cause[`CP0_SEG_BD] <= in_delayslot_i;
                                 status[`CP0_SEG_EXL] <= 1'b1;
                                 cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_OV;
                              end
                `EXC_TYPE_BP: begin
                                 epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                 cause[`CP0_SEG_BD] <= in_delayslot_i;
                                 status[`CP0_SEG_EXL] <= 1'b1;
                                 cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_BP;
                              end
                `EXC_TYPE_SYS: begin
                                  epc <= (status[1] == 1'b0) ? (in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i) : epc;
                                  cause[`CP0_SEG_BD] <= (status[1] == 1'b0) ? in_delayslot_i : cause[`CP0_SEG_BD];
                                  status[`CP0_SEG_EXL] <= 1'b1;
                                  cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_SYS;
                              end
                `EXC_TYPE_ADES: begin
                                   epc <= in_delayslot_i ? current_inst_addr_i - 3'h4 : current_inst_addr_i;
                                   cause[`CP0_SEG_BD] <= in_delayslot_i;
                                   badvaddr <= cp0_badvaddr_wdata_i;
                                   status[`CP0_SEG_EXL] <= 1'b1;
                                   cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADES;
                                   end
                `EXC_TYPE_ERET: begin
                                   status[`CP0_SEG_EXL] <= 0;
                                end
                default: begin end
            endcase	
		end    
	end      
			
			
	always @ (*) 
	begin
		if(!reset) begin
			rdata_o <= `ZeroWord;
		end 
		else begin
				case (raddr_i) 
				    `CP0_REG_BADVADDR: rdata_o <= badvaddr;
					`CP0_REG_COUNT: rdata_o <= count ;
					`CP0_REG_COMPARE: rdata_o <= compare ;
					`CP0_REG_STATUS: rdata_o <= status ;
					`CP0_REG_CAUSE: rdata_o <= cause ;
					`CP0_REG_EPC: rdata_o <= epc ;
					default: begin	end			
				endcase  		
		end    
	end      

endmodule
