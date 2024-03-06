`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/22 18:41:09
// Design Name: 
// Module Name: cpu_axi_interface_connect
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


module cpu_axi_interface_connect(
    input wire        aclk,
    input wire        aresetn,
    input wire[4:0]   int4_0,

    output wire[3:0]  arid,
    output wire[31:0] araddr,
    output wire[7:0]  arlen,
    output wire[2:0]  arsize,
    output wire[1:0]  arburst,
    output wire[1:0]  arlock,
    output wire[3:0]  arcache,
    output wire[2:0]  arprot,
    output wire       arvalid,
    input  wire       arready,

    input wire [3:0]  rid,
    input wire [31:0] rdata,
    input wire [1:0]  rresp,
    input wire        rlast,
    input wire        rvalid,
    output wire       rready,

    output wire[3:0]  awid,
    output wire[31:0] awaddr,
    output wire[7:0]  awlen,
    output wire[2:0]  awsize,
    output wire[1:0]  awburst,
    output wire[1:0]  awlock,
    output wire[3:0]  awcache,
    output wire[2:0]  awprot,
    output wire       awvalid,
    input  wire       awready,

    output wire[3:0]  wid,
    output wire[31:0] wdata,
    output wire[3:0]  wstrb,
    output wire       wlast,
    output wire       wvalid,
    input wire        wready,

    input wire [3:0]  bid,
    input wire [1:0]  bresp,
    input wire        bvalid,
    output wire       bready,

    output wire[31:0] debug_pc_addr,
    output wire[3:0]  debug_reg_write_en,
    output wire[4:0]  debug_reg_write_addr,
    output wire[31:0] debug_reg_write_data
);

    wire timer_int;
    wire halt_con;
    wire[3:0]  debug_reg_write_en_con;

    wire       ram_en_con;
    wire[3:0]  ram_write_en_con;
    wire[31:0] ram_write_data_con;
    wire[31:0] ram_addr_con;
    wire[31:0] ram_read_data_con;

    wire       rom_en_con;
    wire[31:0] rom_addr_con;
    wire[31:0] rom_read_data_con;

    wire       inst_req_con;
    wire       inst_wr_con;
    wire[1:0]  inst_size_con;
    wire[31:0] inst_addr_con;
    wire[31:0] inst_wdata_con;
    wire[31:0] inst_rdata_con;
    wire       inst_addr_ok_con;
    wire       inst_data_ok_con;

    wire       data_req_con;
    wire       data_wr_con;
    wire[1:0]  data_size_con;
    wire[31:0] data_addr_con;
    wire[31:0] data_wdata_con;
    wire[31:0] data_rdata_con;
    wire       data_addr_ok_con;
    wire       data_data_ok_con;

    wire[31:0] read_addr_con;
    wire[31:0] write_addr_con;

    assign debug_reg_write_en = halt_con ? 4'b0000 : debug_reg_write_en_con;

    MMU mmu(
        .reset(aresetn),
        .read_addr_in(read_addr_con),
        .write_addr_in(write_addr_con),
        .read_addr_out(araddr),
        .write_addr_out(awaddr)
    );

    cpu_axi_interface axi_interface(
        .clk(aclk),
        .resetn(aresetn),

        .inst_req(inst_req_con),
        .inst_wr(inst_wr_con),
        .inst_size(inst_size_con),
        .inst_addr(inst_addr_con),
        .inst_wdata(inst_wdata_con),
        .inst_rdata(inst_rdata_con),
        .inst_addr_ok(inst_addr_ok_con),
        .inst_data_ok(inst_data_ok_con),

        .data_req(data_req_con),
        .data_wr(data_wr_con),
        .data_size(data_size_con),
        .data_addr(data_addr_con),
        .data_wdata(data_wdata_con),
        .data_rdata(data_rdata_con),
        .data_addr_ok(data_addr_ok_con),
        .data_data_ok(data_data_ok_con),

        .arid(arid),
        .araddr(read_addr_con),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),

        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),

        .awid(awid),
        .awaddr(write_addr_con),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),

        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),

        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );

    SRAMArbiter sram_arbiter(
        .clk(aclk),
        .reset(aresetn),

        .rom_en(rom_en_con),
        .rom_write_en(4'b0000),
        .rom_write_data(32'h00000000),
        .rom_addr(rom_addr_con),
        .rom_read_data(rom_read_data_con),
        
        .ram_en(ram_en_con),
        .ram_write_en(ram_write_en_con),
        .ram_write_data(ram_write_data_con),
        .ram_addr(ram_addr_con),
        .ram_read_data(ram_read_data_con),

        .inst_rdata(inst_rdata_con),
        .inst_addr_ok(inst_addr_ok_con),
        .inst_data_ok(inst_data_ok_con),
        .inst_req(inst_req_con),
        .inst_wr(inst_wr_con),
        .inst_size(inst_size_con),
        .inst_addr(inst_addr_con),
        .inst_wdata(inst_wdata_con),

        .data_rdata(data_rdata_con),
        .data_addr_ok(data_addr_ok_con),
        .data_data_ok(data_data_ok_con),
        .data_req(data_req_con),
        .data_wr(data_wr_con),
        .data_size(data_size_con),
        .data_addr(data_addr_con),
        .data_wdata(data_wdata_con),

        .halt(halt_con)
    );

  wire ram_we;

  mymips mymips(
		.clk(aclk),
		.reset(aresetn),
		.halt(halt_con),
		.rom_data_i(rom_read_data_con),
	    .ram_data_i(ram_read_data_con),
	    .int_i({timer_int, int4_0}),
        .timer_int_o(timer_int),
		.rom_addr_o(rom_addr_con),
		.rom_en_o(rom_en_con),
        .ram_addr_o(ram_addr_con),
        .ram_we_o(ram_we),
        .ram_sel_o(ram_write_en_con),
        .ram_data_o(ram_write_data_con),
        .ram_en_o(ram_en_con),
        .debug_reg_we(debug_reg_write_en_con),
        .debug_reg_write_data(debug_reg_write_data),
        .debug_reg_write_addr(debug_reg_write_addr),
        .debug_pc_addr(debug_pc_addr)
	);

endmodule 
