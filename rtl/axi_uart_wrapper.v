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
// Function: Wrapper for UART instantiation
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_uart_wrapper
  #(parameter ID_WIDTH = 0,
    parameter INIT_FILE = "")
  (input wire 		      clk,
   input wire 		     rst_n,

   input wire 		     i_uart_rx,
   output wire 		     o_uart_tx,
   output wire 		     o_uart_irq,
   input wire [ID_WIDTH-1:0] i_awid,
   input wire [11:0] 	     i_awaddr,
   input wire [7:0] 	     i_awlen,
   input wire [2:0] 	     i_awsize,
   input wire [1:0] 	     i_awburst,
   input wire 		     i_awvalid,
   output wire 		     o_awready,

   input wire [ID_WIDTH-1:0] i_arid,
   input wire [11:0] 	     i_araddr,
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

   output reg [ID_WIDTH-1:0] o_bid,
   output wire [1:0] 	     o_bresp,
   output wire 		     o_bvalid,
   input wire 		     i_bready,

   output reg [ID_WIDTH-1:0] o_rid,
   output wire [63:0] 	     o_rdata,
   output wire [1:0] 	     o_rresp,
   output wire 		     o_rlast,
   output wire 		     o_rvalid,
   input wire 		     i_rready);

   assign o_rlast = 1'b1;

   wire [11:2] 		      wb_adr;
   wire [31:0] 		      wb_dat;
   wire 		      wb_we;
   wire 		      wb_cyc;
   wire 		      wb_stb;
   wire 		      wb_ack;

   wire [7:0] 		      wb_rdt;

   always @(posedge clk)
     if (i_awvalid & o_awready)
       o_bid <= i_awid;

   always @(posedge clk)
     if (i_arvalid & o_arready)
       o_rid <= i_arid;

   axi2wb axi2wb
     (
      .i_clk (clk),
      .i_rst (~rst_n),
      .o_wb_adr     (wb_adr),
      .o_wb_dat     (wb_dat),
      .o_wb_sel     (),
      .o_wb_we      (wb_we),
      .o_wb_cyc     (wb_cyc),
      .o_wb_stb     (wb_stb),
      .i_wb_rdt     ({24'd0,wb_rdt}),
      .i_wb_ack     (wb_ack),
      .i_wb_err     (1'b0),

      .i_awaddr     (i_awaddr),
      .i_awvalid    (i_awvalid),
      .o_awready    (o_awready),

      .i_araddr     (i_araddr),
      .i_arvalid    (i_arvalid),
      .o_arready    (o_arready),

      .i_wdata     (i_wdata),
      .i_wstrb     (i_wstrb),
      .i_wvalid    (i_wvalid),
      .o_wready    (o_wready),

      .o_bvalid    (o_bvalid),
      .i_bready    (i_bready),

      .o_rdata     (o_rdata),
      .o_rvalid    (o_rvalid),
      .i_rready    (i_rready)
      );


   uart_top uart16550_0
     (
      // Wishbone slave interface
      .wb_clk_i	(clk),
      .wb_rst_i	(~rst_n),
      .wb_adr_i	(wb_adr[4:2]),
      .wb_dat_i	(wb_dat[7:0]),
      .wb_we_i	(wb_we),
      .wb_cyc_i	(wb_cyc),
      .wb_stb_i	(wb_stb),
      .wb_sel_i	(4'b0), // Not used in 8-bit mode
      .wb_dat_o	(wb_rdt),
      .wb_ack_o	(wb_ack),

      // Outputs
      .int_o     (o_uart_irq),
      .stx_pad_o (o_uart_tx),
      .rts_pad_o (),
      .dtr_pad_o (),

      // Inputs
      .srx_pad_i (i_uart_rx),
      .cts_pad_i (1'b0),
      .dsr_pad_i (1'b0),
      .ri_pad_i  (1'b0),
      .dcd_pad_i (1'b0));

endmodule
