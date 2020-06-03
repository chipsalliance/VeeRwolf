// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Peter Gustavsson <peter.gustavsson@qamcom.se>
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
// Function: AXI lite to Wishbone non pipelined bridge
// Comments: Assumes single accesses to a 32bit register on an 64bit aligned address
//
//********************************************************************************

`default_nettype none
module axi2wb
  #(parameter AW = 12,
    parameter IW = 0)
  (
   input wire i_clk,
   input wire i_rst,

   // Wishbone master
   output reg [AW-1:2] o_wb_adr,
   output reg [31:0] o_wb_dat,
   output reg [3:0] o_wb_sel,
   output reg o_wb_we,
   output reg o_wb_cyc,
   output reg o_wb_stb,

   input wire [31:0] i_wb_rdt,
   input wire i_wb_ack,
   input wire i_wb_err,

   // AXI slave
   // AXI adress write channel
   input wire [AW-1:0] i_awaddr,
   input wire [IW-1:0] i_awid,
   input wire i_awvalid,
   output reg o_awready,
   //AXI adress read channel
   input wire [AW-1:0] i_araddr,
   input wire [IW-1:0] i_arid,
   input wire i_arvalid,
   output reg o_arready,
   //AXI write channel
   input wire [63:0] i_wdata,
   input wire [7:0] i_wstrb,
   input wire i_wvalid,
   output reg o_wready,
   //AXI response channel
   output reg [IW-1:0] o_bid,
   output wire [1:0] o_bresp,
   output reg o_bvalid,
   input wire i_bready,
   //AXI read channel
   output reg [63:0] o_rdata,
   output reg [IW-1:0] o_rid,
   output wire [1:0] o_rresp,
   output wire o_rlast,
   output reg o_rvalid,
   input wire i_rready
   );

   assign o_bresp = 2'b00;
   assign o_rresp = 2'b00;
   assign o_rlast = 1'b1;

   reg        hi_32b_w;
   reg 	      arbiter;
   reg 	[31:0]  wb_rdt_low;


   parameter STATESIZE = 4;

   parameter [STATESIZE-1:0]
     IDLE = 4'd0,
     AWACK = 4'd1,
     WBWACK= 4'd2,
     WBRACK1 = 4'd3,
     WBR2 = 4'd4,
     WBRACK2 = 4'd5,
     BAXI = 4'd6,
     RRAXI = 4'd7;

   reg [STATESIZE-1:0] cs;

   // formal helper registers
   reg 		       aw_req;
   reg 		       w_req;
   reg 		       ar_req;


   initial o_rvalid = 1'b0;
   initial o_bvalid = 1'b0;
   initial o_wb_stb = 1'b0;
   initial o_wb_cyc = 1'b0;
   initial o_wb_we = 1'b0;
   initial cs = 4'd0;
   initial aw_req = 1'b0;
   initial w_req = 1'b0;
   initial ar_req = 1'b0;


   always @(posedge i_clk) begin
      if (i_rst) begin
	 o_awready <= 1'b0;
	 o_wready <= 1'b0;
	 o_arready <= 1'b0;
	 o_rvalid <= 1'b0;
	 o_bvalid <= 1'b0;
	 o_wb_adr <= {AW-2{1'b0}};
	 o_wb_cyc <= 1'b0;
	 o_wb_stb <= 1'b0;
	 o_wb_sel <= 4'd0;
	 o_wb_we <= 1'b0;
	 arbiter <= 1'b1;
	 wb_rdt_low <= 32'hDEADBEEF;
	 cs <= IDLE;

	 aw_req <= 1'b0;
	 w_req <= 1'b0;
	 ar_req <= 1'b0;
	 o_bid <= {IW{1'b0}};
	 o_rid <= {IW{1'b0}};

      end
      else begin
	 if (i_awvalid & o_awready)
	   o_bid <= i_awid;

	 if (i_arvalid & o_arready)
	   o_rid <= i_arid;

	 o_awready <= 1'b0;
	 o_wready <= 1'b0;
	 o_arready <= 1'b0;

	 if (i_awvalid && o_awready)
	   aw_req <= 1'b1;
	 else if (i_bready && o_bvalid)
	   aw_req <= 1'b0;

	 if (i_wvalid && o_wready)
	   w_req <= 1'b1;
	 else if (i_bready && o_bvalid)
	   w_req <= 1'b0;

	 if (i_arvalid && o_arready)
	   ar_req <= 1'b1;
	 else if (i_rready && o_rvalid)
	   ar_req <= 1'b0;

	 case (cs)
	   IDLE : begin
	      arbiter <= 1'b1;
	      if (i_awvalid && arbiter) begin
		 o_wb_adr[AW-1:3] <= i_awaddr[AW-1:3];
		 o_awready <= 1'b1;
		 arbiter <= 1'b0;
		 if (i_wvalid) begin
		    hi_32b_w = (i_wstrb[3:0] == 4'h0) ? 1'b1 : 1'b0;
		    o_wb_adr[2] <= hi_32b_w;
		    o_wb_cyc <= 1'b1;
		    o_wb_stb <= 1'b1;
		    o_wb_sel <= hi_32b_w ? i_wstrb[7:4] : i_wstrb[3:0];
		    o_wb_dat <= hi_32b_w ? i_wdata[63:32] : i_wdata[31:0];
		    o_wb_we <= 1'b1;
		    o_wready <= 1'b1;
		    cs <= WBWACK;
		 end
		 else begin
		    cs <= AWACK;
		 end
	      end
	      else if (i_arvalid) begin
		 o_wb_adr[AW-1:2] <= i_araddr[AW-1:2];
		 o_wb_sel <= 4'hF;
		 o_wb_cyc <= 1'b1;
		 o_wb_stb <= 1'b1;
		 o_arready <= 1'b1;
		 cs <= WBRACK1;
	      end
	   end

	   AWACK : begin
	      if (i_wvalid) begin
		 hi_32b_w = (i_wstrb[3:0] == 4'h0) ? 1'b1 : 1'b0;
		 o_wb_adr[2] <= hi_32b_w;
		 o_wb_cyc <= 1'b1;
		 o_wb_stb <= 1'b1;
		 o_wb_sel <= hi_32b_w ? i_wstrb[7:4] : i_wstrb[3:0];
		 o_wb_dat <= hi_32b_w ? i_wdata[63:32] : i_wdata[31:0];
		 o_wb_we <= 1'b1;
		 o_wready <= 1'b1;
		 cs <= WBWACK;
	      end
	   end

	   WBWACK : begin
	      if ( i_wb_err || i_wb_ack ) begin
		 o_wb_cyc <= 1'b0;
		 o_wb_stb <= 1'b0;
		 o_wb_sel <= 4'h0;
		 o_wb_we <= 1'b0;
		 o_bvalid <= 1'b1;
		 cs <= BAXI;
	      end
	   end

	   WBRACK1 : begin
	      if ( i_wb_err || i_wb_ack) begin
		 o_wb_cyc <= 1'b0;
		 o_wb_stb <= 1'b0;
		 o_wb_sel <= 4'h0;
		 wb_rdt_low <= i_wb_rdt;
		 cs <= WBR2;
	      end
	   end

	   WBR2 : begin
	      o_wb_adr[2] <= 1'b1;
	      o_wb_sel <= 4'hF;
	      o_wb_cyc <= 1'b1;
	      o_wb_stb <= 1'b1;
	      cs <= WBRACK2;
	   end


	   WBRACK2 : begin
	      if ( i_wb_err || i_wb_ack) begin
		 o_wb_cyc <= 1'b0;
		 o_wb_stb <= 1'b0;
		 o_wb_sel <= 4'h0;
		 o_rvalid <= 1'b1;
		 o_rdata <= {i_wb_rdt, wb_rdt_low};
		 cs <= RRAXI;
	      end
	   end

	   BAXI : begin
	      o_bvalid <= 1'b1;
	      if (i_bready) begin
		 o_bvalid <= 1'b0;
		 cs <= IDLE;
	      end
	   end

	   RRAXI : begin
	      o_rvalid <= 1'b1;
	      if (i_rready) begin
		 o_rvalid <= 1'b0;
		 cs <= IDLE;
	      end
	   end

	   default : begin
	      o_awready <= 1'b0;
	      o_wready <= 1'b0;
	      o_arready <= 1'b0;
	      o_rvalid <= 1'b0;
	      o_bvalid <= 1'b0;
	      o_wb_adr <= {AW-2{1'b0}};
	      o_wb_cyc <= 1'b0;
	      o_wb_stb <= 1'b0;
	      o_wb_sel <= 4'd0;
	      o_wb_we <= 1'b0;
	      arbiter <= 1'b1;
	      cs <= IDLE;
	   end
	 endcase
      end
   end

`ifdef FORMAL
   localparam	F_LGDEPTH = 4;

   wire	[(F_LGDEPTH-1):0]	faxi_awr_outstanding,
				faxi_wr_outstanding,
				faxi_rd_outstanding;


   faxil_slave
     #(
         .C_AXI_DATA_WIDTH(64),
	 .C_AXI_ADDR_WIDTH(AW),
	 .F_OPT_BRESP      (1'b1),
	 .F_OPT_RRESP      (1'b1),
	 .F_AXI_MAXWAIT    (16),
	 .F_AXI_MAXDELAY   (4),
	 .F_AXI_MAXRSTALL  (1),
	 .F_LGDEPTH(F_LGDEPTH))
   faxil_slave
     (
	    .i_clk(i_clk),
	    .i_axi_reset_n(~i_rst),
	    //
       	    .i_axi_awaddr(i_awaddr),
	    .i_axi_awcache(4'h0),
	    .i_axi_awprot(3'd0),
	    .i_axi_awvalid(i_awvalid),
	    .i_axi_awready(o_awready),
	    //
	    .i_axi_wdata(i_wdata),
	    .i_axi_wstrb(i_wstrb),
	    .i_axi_wvalid(i_wvalid),
	    .i_axi_wready(o_wready),
	    //
	    .i_axi_bresp(2'd0),
	    .i_axi_bvalid(o_bvalid),
	    .i_axi_bready(i_bready),
	    //
	    .i_axi_araddr(i_araddr),
	    .i_axi_arprot(3'd0),
	    .i_axi_arcache(4'h0),
	    .i_axi_arvalid(i_arvalid),
	    .i_axi_arready(o_arready),
	    //
	    .i_axi_rdata(o_rdata),
	    .i_axi_rresp(2'd0),
	    .i_axi_rvalid(o_rvalid),
	    .i_axi_rready(i_rready),
	    //
	    .f_axi_rd_outstanding(faxi_rd_outstanding),
	    .f_axi_wr_outstanding(faxi_wr_outstanding),
	    .f_axi_awr_outstanding(faxi_awr_outstanding));


   always @(*) begin

      assert(faxi_awr_outstanding <= 1);
      assert(faxi_wr_outstanding <= 1);
      assert(faxi_rd_outstanding <= 1);

      case (cs)
	IDLE : begin
	   assert(!o_wb_we);
	   assert(!o_wb_stb);
	   assert(!o_wb_cyc);
	   assert(!aw_req);
	   assert(!ar_req);
	   assert(!w_req);
	   assert(faxi_awr_outstanding == 0);
	   assert(faxi_wr_outstanding == 0);
	   assert(faxi_rd_outstanding == 0);
	end
	AWACK : begin
	   assert(!o_wb_we);
	   assert(!o_wb_stb);
	   assert(!o_wb_cyc);
	   assert(faxi_awr_outstanding == (aw_req ? 1:0));
	   assert(faxi_wr_outstanding == 0);
	   assert(faxi_rd_outstanding == 0);
	end
	WBWACK : begin
	   assert(faxi_awr_outstanding == (aw_req ? 1:0));
	   assert(faxi_wr_outstanding == (w_req ? 1:0));
	   assert(faxi_rd_outstanding == 0);
	end
	WBRACK : begin
	   assert(faxi_awr_outstanding == 0);
	   assert(faxi_wr_outstanding == 0);
	   assert(faxi_rd_outstanding == (ar_req ? 1:0));
	   end
	BAXI : begin
	   assert(faxi_rd_outstanding == 0);
	end
	RRAXI : begin
	   assert(faxi_awr_outstanding == 0);
	   assert(faxi_wr_outstanding == 0);
	end

	default:
	  assert(0);
      endcase // case (cs)
   end

   fwbc_master
     #(.AW (AW-2),
       .DW (32),
       .F_MAX_DELAY (4),
       .OPT_BUS_ABORT (0))
   fwbc_master
     (.i_clk      (i_clk),
      .i_reset    (i_rst),
      .i_wb_addr  (o_wb_adr),
      .i_wb_data  (o_wb_dat),
      .i_wb_sel   (o_wb_sel),
      .i_wb_we    (o_wb_we),
      .i_wb_cyc   (o_wb_cyc),
      .i_wb_stb   (o_wb_stb),
      .i_wb_cti   (3'd0),
      .i_wb_bte   (2'd0),
      .i_wb_idata (i_wb_rdt),
      .i_wb_ack   (i_wb_ack),
      .i_wb_err   (i_wb_err),
      .i_wb_rty   (1'b0));

`endif
endmodule
`default_nettype wire
