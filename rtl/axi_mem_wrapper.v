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
// Function: Wrapper for on-chip memory instantiations
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_mem_wrapper
  #(parameter ID_WIDTH = 0,
    parameter MEM_SIZE = 0,
    parameter mem_clear = 0,
    parameter INIT_FILE = "")
  (input wire 		      clk,
   input wire 		     rst_n,

   input wire [ID_WIDTH-1:0] i_awid,
   input wire [31:0] 	     i_awaddr,
   input wire [7:0] 	     i_awlen,
   input wire [2:0] 	     i_awsize,
   input wire [1:0] 	     i_awburst,
   input wire 		     i_awvalid,
   output wire 		     o_awready,

   input wire [ID_WIDTH-1:0] i_arid,
   input wire [31:0] 	     i_araddr,
   input wire [7:0] 	     i_arlen,
   input wire [2:0] 	     i_arsize,
   input wire [1:0] 	     i_arburst,
   input wire 		     i_arvalid,
   output wire 		     o_arready,

   input wire [63:0] 	     i_wdata,
   input wire [7:0] 	     i_wstrb,
   input wire 		     i_wlast,
   input wire 		     i_wvalid,
   output wire 		     o_wready,

   output wire [ID_WIDTH-1:0] o_bid,
   output wire [1:0] 	     o_bresp,
   output wire 		     o_bvalid,
   input wire 		     i_bready,

   output wire [ID_WIDTH-1:0] o_rid,
   output wire [63:0] 	     o_rdata,
   output wire [1:0] 	     o_rresp,
   output wire 		     o_rlast,
   output wire 		     o_rvalid,
   input wire 		     i_rready);

   localparam AW = $clog2(MEM_SIZE);

   wire [AW-1:2] wb_adr;
   wire [31:0] 		      wb_dat;
   wire [3:0] 		      wb_sel;
   wire 		      wb_we;
   wire 		      wb_cyc;
   wire 		      wb_stb;
   reg 			      wb_ack;

   wire [31:0] 		      wb_rdt;

   axi2wb
     #(.AW (AW),
       .IW (ID_WIDTH))
   axi2wb
     (
      .i_clk (clk),
      .i_rst (~rst_n),
      .o_wb_adr     (wb_adr),
      .o_wb_dat     (wb_dat),
      .o_wb_sel     (wb_sel),
      .o_wb_we      (wb_we),
      .o_wb_cyc     (wb_cyc),
      .o_wb_stb     (wb_stb),
      .i_wb_rdt     (wb_rdt),
      .i_wb_ack     (wb_ack),
      .i_wb_err     (1'b0),

      .i_awaddr     (i_awaddr[AW-1:0]),
      .i_awid       (i_awid),
      .i_awvalid    (i_awvalid),
      .o_awready    (o_awready),

      .i_araddr     (i_araddr[AW-1:0]),
      .i_arid       (i_arid),
      .i_arvalid    (i_arvalid),
      .o_arready    (o_arready),

      .i_wdata     (i_wdata),
      .i_wstrb     (i_wstrb),
      .i_wvalid    (i_wvalid),
      .o_wready    (o_wready),

      .o_bid       (o_bid),
      .o_bresp     (o_bresp),
      .o_bvalid    (o_bvalid),
      .i_bready    (i_bready),

      .o_rdata     (o_rdata),
      .o_rid       (o_rid),
      .o_rresp     (o_rresp),
      .o_rlast     (o_rlast),
      .o_rvalid    (o_rvalid),
      .i_rready    (i_rready)
      );

   wire [31:0] 	 mem_addr;
   wire [63:0] 	 mem_wdata;
   wire [63:0] 	 mem_rdata;

   wire [7:0] 	 mem_we;

   assign mem_we[3:0] = (wb_cyc & wb_stb & wb_we & !wb_adr[2]) ? wb_sel : 4'd0;
   assign mem_we[7:4] = (wb_cyc & wb_stb & wb_we &  wb_adr[2]) ? wb_sel : 4'd0;

   assign mem_wdata = {wb_dat, wb_dat};

   assign wb_rdt = wb_adr[2] ? mem_rdata[63:32] : mem_rdata[31:0];

   always @(posedge clk) begin
      wb_ack <= wb_cyc & wb_stb & !wb_ack;
      if (~rst_n)
	wb_ack <= 1'b0;
   end

   dpram64
     #(.SIZE (MEM_SIZE),
       .mem_clear (mem_clear),
       .memfile (INIT_FILE))
   ram
     (.clk   (clk),
      .we    (mem_we),
      .din   (mem_wdata),
      .waddr ({wb_adr[AW-1:3],3'b000}),
      .raddr ({wb_adr[AW-1:3],3'b000}),
      .dout  (mem_rdata));

endmodule
