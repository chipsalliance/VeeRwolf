// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Basic 32-bit Wishbone to 64-bit AXI converter
// Comments:
//
//********************************************************************************

`default_nettype none
module wb2axi
  #(parameter BYTE_SWAP = 1)
   (
   input wire 	      i_clk,
   input wire 	      i_rst,
   input wire [31:0]  i_wb_adr,
   input wire [31:0]  i_wb_dat,
   input wire [3:0]   i_wb_sel,
   input wire 	      i_wb_we,
   input wire 	      i_wb_cyc,
   input wire 	      i_wb_stb,
   output wire [31:0] o_wb_rdt,
   output wire 	      o_wb_ack,

   output wire [31:0] o_awaddr,
   output wire 	      o_awvalid,
   input wire 	      i_awready,

   output wire [31:0] o_araddr,
   output wire 	      o_arvalid,
   input wire 	      i_arready,

   output wire [63:0] o_wdata,
   output wire [7:0]  o_wstrb,
   output wire 	      o_wvalid,
   input wire 	      i_wready,

   input wire 	      i_bvalid,
   output reg 	      o_bready = 1'b1,

   input wire [63:0]  i_rdata,
   input wire 	      i_rvalid,
   output reg 	      o_rready = 1'b1);

   reg 		      awdone = 1'b0;
   reg 		      ardone = 1'b0;
   reg 		      wdone  = 1'b0;
   reg 		      busy   = 1'b0;


   wire [31:0] 	      wb_dat_i;
   wire [3:0] 	      wb_sel_i;
   wire [31:0] 	      wb_rdt_i;

   //Do conditional byteswapping
   generate
      genvar 	       i;
      if (BYTE_SWAP) begin
	 for (i=0;i<4; i++)
	   begin
	      assign o_wb_rdt[i*8 +: 8] = wb_rdt_i[(4-i)*8-1 -: 8];
	      assign wb_dat_i[i*8 +: 8] = i_wb_dat[(4-i)*8-1 -: 8];
	      assign wb_sel_i[i +: 1] = i_wb_sel[3-i -: 1];
	   end
      end
      else begin
	 assign o_wb_rdt = wb_rdt_i;
	 assign wb_dat_i = i_wb_dat;
	 assign wb_sel_i = i_wb_sel;
      end
   endgenerate

   assign o_awaddr  = {i_wb_adr[31:3], 3'b000};
   assign o_awvalid = busy & i_wb_we & !awdone;

   assign o_araddr  = {i_wb_adr[31:3], 3'b000};
   assign o_arvalid = busy & !i_wb_we & !ardone;

   assign o_wdata  = {wb_dat_i, wb_dat_i};
   assign o_wstrb  = i_wb_adr[2] ? {wb_sel_i,4'd0} : {4'd0, wb_sel_i};
   assign o_wvalid = busy & i_wb_we & !wdone;

   assign wb_rdt_i = i_wb_adr[2] ? i_rdata[63:32] : i_rdata[31:0];

   assign o_wb_ack = i_bvalid | i_rvalid;

   always @(posedge i_clk) begin
      if (!busy) begin
	 awdone <= 1'b0;
	 ardone <= 1'b0;
	 wdone  <= 1'b0;
      end

      if (o_awvalid & i_awready) awdone <= 1'b1;
      if (o_arvalid & i_arready) ardone <= 1'b1;
      if (o_wvalid  & i_wready)   wdone <= 1'b1;

      if (o_wb_ack)
	busy <= 1'b0;
      else if (i_wb_cyc & i_wb_stb)
	busy <= 1'b1;

      if (i_rst) begin
	 busy <= 1'b0;
	 awdone <= 1'b0;
	 ardone <= 1'b0;
	 wdone  <= 1'b0;
      end
   end

`ifdef FORMAL
   localparam F_LGDEPTH = 5;
   wire [F_LGDEPTH-1:0] faxi_awr_outstanding, faxi_wr_outstanding, faxi_rd_outstanding;

   faxil_master
     #(
       .C_AXI_DATA_WIDTH (64),
       .C_AXI_ADDR_WIDTH (28),
       .F_OPT_ASSUME_RESET (1),
       .F_OPT_BRESP      (1'b0),
       .F_OPT_RRESP      (1'b0),
       .F_AXI_MAXWAIT    (4),
       .F_AXI_MAXDELAY   (4),
       .F_AXI_MAXRSTALL  (1),
       .F_LGDEPTH        (F_LGDEPTH))
   faxil_master
     (
      .i_clk (i_clk),
      .i_axi_reset_n (~i_rst),

      .i_axi_awready (i_awready),
      .i_axi_awaddr  (o_awaddr),
      .i_axi_awcache (4'h0),
      .i_axi_awprot  (3'd0),
      .i_axi_awvalid (o_awvalid),

      .i_axi_wready  (i_wready),
      .i_axi_wdata   (o_wdata),
      .i_axi_wstrb   (o_wstrb),
      .i_axi_wvalid  (o_wvalid),

      .i_axi_bresp   (2'd0),
      .i_axi_bvalid  (i_bvalid),
      .i_axi_bready  (o_bready),

      .i_axi_arready (i_arready),
      .i_axi_araddr  (o_araddr),
      .i_axi_arcache (4'h0),
      .i_axi_arprot  (3'd0),
      .i_axi_arvalid (o_arvalid),

      .i_axi_rresp   (2'd0),
      .i_axi_rvalid  (i_rvalid),
      .i_axi_rdata   (i_rdata),
      .i_axi_rready  (o_rready),

      .f_axi_rd_outstanding  (faxi_rd_outstanding),
      .f_axi_wr_outstanding  (faxi_wr_outstanding),
      .f_axi_awr_outstanding (faxi_awr_outstanding));

   always @(*)
   begin
	assert(o_rready);
	assert(o_bready);

	assert(faxi_awr_outstanding <= 1);
	assert(faxi_wr_outstanding <= 1);
	assert(faxi_rd_outstanding <= 1);
	if (!busy) begin
		assert(!o_wb_ack);
		assert(faxi_awr_outstanding == 0);
		assert(faxi_wr_outstanding == 0);
		assert(faxi_rd_outstanding == 0);
	end else begin
	    assert(i_wb_stb);
	    if (!i_wb_we) begin
		assert(!awdone);
		assert(!wdone);
		assert(faxi_awr_outstanding == 0);
		assert(faxi_wr_outstanding == 0);
		assert(faxi_rd_outstanding == (ardone ? 1:0));
	    end else begin
		assert(!ardone);
		assert(faxi_awr_outstanding == (awdone ? 1:0));
		assert(faxi_wr_outstanding  == ( wdone ? 1:0));
		assert(faxi_rd_outstanding == 0);
	    end
	end
   end

   fwbc_slave
     #(.AW (32),
       .F_MAX_DELAY (10),
       .OPT_BUS_ABORT (0))
   fwbc_slave
     (.i_clk      (i_clk),
      .i_reset    (i_rst),
      .i_wb_addr  (i_wb_adr),
      .i_wb_data  (i_wb_dat),
      .i_wb_sel   (i_wb_sel),
      .i_wb_we    (i_wb_we),
      .i_wb_cyc   (i_wb_cyc),
      .i_wb_stb   (i_wb_stb),
      .i_wb_cti   (3'd0),
      .i_wb_bte   (2'd0),
      .i_wb_idata (o_wb_rdt),
      .i_wb_ack   (o_wb_ack),
      .i_wb_err   (1'b0),
      .i_wb_rty   (1'b0));

	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge i_clk)
		f_past_valid <= 1;

	// This *should* be part of the fwbc_* properties ...
	always @(posedge i_clk)
	if (f_past_valid && $past(!i_rst && i_wb_stb && !o_wb_ack))
	begin
		assume($stable(i_wb_stb));
		assume($stable(i_wb_we));
		assume($stable(i_wb_adr));
		assume($stable(i_wb_dat));
		assume($stable(i_wb_sel));
	end

	reg	[2:0]	count_writes, count_reads;

	initial	count_writes = 0;
	always @(posedge i_clk)
	if (i_rst)
		count_writes <= 0;
	else if (o_wb_ack && i_bvalid && !(&count_writes))
		count_writes <= count_writes + 1;

	initial	count_reads = 0;
	always @(posedge i_clk)
	if (i_rst)
		count_reads <= 0;
	else if (o_wb_ack && !(&count_writes))
		count_reads <= count_reads + 1;

	always @(*)
		cover(count_writes == 3'h3);
	always @(*)
		cover(count_reads == 3'h3);

`endif
endmodule
