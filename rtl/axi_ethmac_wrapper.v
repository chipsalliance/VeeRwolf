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
// Function: Wrapper for ETHMAC instantiation
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_ethmac_wrapper
  #(parameter ID_WIDTH = 0)
  (
   input wire 		      clk,
   input wire 		      rst_n,
   // AXI Master interface, 64bit data
   // AW
   output wire [31:0] 	      o_dma_awaddr,
   output reg 		      o_dma_awid = 1'd0,
   output reg [7:0] 	      o_dma_awlen = 8'd0,
   output reg [2:0] 	      o_dma_awsize = 3'd3,
   output reg [1:0] 	      o_dma_awburst = 2'd1,
   output reg 		      o_dma_awlock = 1'b0,
   output reg [3:0] 	      o_dma_awcache = 4'hf,
   output reg [2:0] 	      o_dma_awprot = 3'd0,
   output reg [3:0] 	      o_dma_awregion = 4'd0,
   output reg [3:0] 	      o_dma_awqos = 4'd0,
   output wire 		      o_dma_awvalid,
   input wire 		      i_dma_awready,
   // W
   output wire [63:0] 	      o_dma_wdata,
   output wire [7:0] 	      o_dma_wstrb,
   output reg 		      o_dma_wlast = 1'b1,
   output wire 		      o_dma_wvalid,
   input wire 		      i_dma_wready,
   // B
   input wire 		      i_dma_bid,
   input wire [1:0] 	      i_dma_bresp,
   output wire 		      o_dma_bready,
   input wire 		      i_dma_bvalid,
   // AR
   output reg 		      o_dma_arid = 1'd0,
   output wire [31:0] 	      o_dma_araddr,
   output reg [7:0] 	      o_dma_arlen = 8'd0,
   output reg [2:0] 	      o_dma_arsize = 3'd3,
   output reg [1:0] 	      o_dma_arburst = 2'd1,
   output reg 		      o_dma_arlock = 1'b0,
   output reg [3:0] 	      o_dma_arcache = 4'hf,
   output reg [2:0] 	      o_dma_arprot = 3'd0,
   output reg [3:0] 	      o_dma_arregion = 4'd0,
   output reg [3:0] 	      o_dma_arqos = 4'd0,
   output wire 		      o_dma_arvalid,
   input wire 		      i_dma_arready,
   // R
   input wire [63:0] 	      i_dma_rdata,
   input wire 		      i_dma_rvalid,
   input wire 		      i_dma_rid,
   input wire [1:0] 	      i_dma_rresp,
   input wire 		      i_dma_rlast,
   output wire 		      o_dma_rready,

   // AXI Slave interface, 64 bit data
   // AW
   input wire [ID_WIDTH-1:0]  i_awid,
   input wire [11:0] 	      i_awaddr,
   input wire [7:0] 	      i_awlen,
   input wire [2:0] 	      i_awsize,
   input wire [1:0] 	      i_awburst,
   input wire 		      i_awvalid,
   output wire 		      o_awready,
   // AR
   input wire [ID_WIDTH-1:0]  i_arid,
   input wire [11:0] 	      i_araddr,
   input wire [7:0] 	      i_arlen,
   input wire [2:0] 	      i_arsize,
   input wire [1:0] 	      i_arburst,
   input wire 		      i_arvalid,
   output wire 		      o_arready,
   // W
   input wire [63:0] 	      i_wdata,
   input wire [7:0] 	      i_wstrb,
   input wire 		      i_wlast,
   input wire 		      i_wvalid,
   output wire 		      o_wready,
   // B
   output reg [ID_WIDTH-1:0] o_bid,
   output wire [1:0] 	      o_bresp,
   output wire 		      o_bvalid,
   input wire 		      i_bready,
   // R
   output reg [ID_WIDTH-1:0] o_rid,
   output wire [63:0] 	      o_rdata,
   output wire [1:0] 	      o_rresp,
   output wire 		      o_rlast,
   output wire 		      o_rvalid,
   input wire 		      i_rready,
   // MII TX
   input wire 		      i_mtx_clk_pad,
   output wire [3:0]	      o_mtxd_pad,
   output wire 		      o_mtxen_pad,
   output wire 		      o_mtxerr_pad,
   // MII RX
   input wire 		      i_mrx_clk_pad,
   input wire [3:0]	      i_mrxd_pad,
   input wire 		      i_mrxdv_pad,
   input wire 		      i_mrxerr_pad,
   // MII Common
   input wire 		      i_mcoll_pad,
   input wire 		      i_mcrs_pad,
   // MII Management Interface
   output wire 		      o_mdc_pad,
   input wire 		      i_md_pad,
   output wire 		      o_md_pad,
   output wire 		      o_md_padoe,
   // Misc
   output wire 		      o_int
);

   wire [31:0] 		      wbm_ethmac_adr;
   wire [31:0] 		      wbm_ethmac_dat;
   wire [3:0] 		      wbm_ethmac_sel;
   wire 		      wbm_ethmac_we;
   wire 		      wbm_ethmac_cyc;
   wire 		      wbm_ethmac_stb;
   wire [31:0] 		      wbm_ethmac_rdt;
   wire 		      wbm_ethmac_ack;

   // Signals from ethmac that is not supported in wb2axi
   wire 		      wbm_ethmac_err;

   assign wbm_ethmac_err = 1'b0;

   always @(posedge clk)
     if (i_awvalid & o_awready)
       o_bid <= i_awid;

   always @(posedge clk)
     if (i_arvalid & o_arready)
       o_rid <= i_arid;


   wb2axi dmabridge
     (
      .i_clk (clk),
      .i_rst (~rst_n),
      .i_wb_adr     (wbm_ethmac_adr),
      .i_wb_dat     (wbm_ethmac_dat),
      .i_wb_sel     (wbm_ethmac_sel),
      .i_wb_we      (wbm_ethmac_we),
      .i_wb_cyc     (wbm_ethmac_cyc),
      .i_wb_stb     (wbm_ethmac_stb),
      .o_wb_rdt     (wbm_ethmac_rdt),
      .o_wb_ack     (wbm_ethmac_ack),

      .o_awaddr     (o_dma_awaddr),
      .o_awvalid    (o_dma_awvalid),
      .i_awready    (i_dma_awready),

      .o_araddr     (o_dma_araddr),
      .o_arvalid    (o_dma_arvalid),
      .i_arready    (i_dma_arready),

      .o_wdata     (o_dma_wdata),
      .o_wstrb     (o_dma_wstrb),
      .o_wvalid    (o_dma_wvalid),
      .i_wready    (i_dma_wready),

      .i_bvalid    (i_dma_bvalid),
      .o_bready    (o_dma_bready),

      .i_rdata     (i_dma_rdata),
      .i_rvalid    (i_dma_rvalid),
      .o_rready    (o_dma_rready)
      );

   wire [11:2] 		      wbs_ethmac_adr;
   wire [31:0] 		      wbs_ethmac_dat;
   wire [3:0] 		      wbs_ethmac_sel;
   wire 		      wbs_ethmac_we;
   wire 		      wbs_ethmac_cyc;
   wire 		      wbs_ethmac_stb;
   wire [31:0] 		      wbs_ethmac_rdt;
   wire 		      wbs_ethmac_ack;
   wire 		      wbs_ethmac_err;

    axi2wb csrbridge
     (
      .i_clk (clk),
      .i_rst (~rst_n),
      .o_wb_adr     (wbs_ethmac_adr),
      .o_wb_dat     (wbs_ethmac_dat),
      .o_wb_sel     (wbs_ethmac_sel),
      .o_wb_we      (wbs_ethmac_we),
      .o_wb_cyc     (wbs_ethmac_cyc),
      .o_wb_stb     (wbs_ethmac_stb),
      .i_wb_rdt     (wbs_ethmac_rdt),
      .i_wb_ack     (wbs_ethmac_ack),
      .i_wb_err     (wbs_ethmac_err),

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

   ethmac
 ethmac_i
     (
      .wb_clk_i (clk),
      .wb_rst_i (~rst_n),

      .wb_dat_i (wbs_ethmac_dat),
      .wb_dat_o (wbs_ethmac_rdt),
      .wb_err_o (wbs_ethmac_err),

      .wb_adr_i (wbs_ethmac_adr),
      .wb_sel_i (wbs_ethmac_sel),
      .wb_we_i  (wbs_ethmac_we),
      .wb_cyc_i (wbs_ethmac_cyc),
      .wb_stb_i (wbs_ethmac_stb),
      .wb_ack_o (wbs_ethmac_ack),

      .m_wb_adr_o (wbm_ethmac_adr),
      .m_wb_sel_o (wbm_ethmac_sel),
      .m_wb_we_o (wbm_ethmac_we),
      .m_wb_dat_i (wbm_ethmac_rdt),
      .m_wb_dat_o (wbm_ethmac_dat),
      .m_wb_cyc_o (wbm_ethmac_cyc),
      .m_wb_stb_o (wbm_ethmac_stb),
      .m_wb_ack_i (wbm_ethmac_ack),
      .m_wb_err_i (wbm_ethmac_err),

      .m_wb_cti_o (),
      .m_wb_bte_o (),

      .mtx_clk_pad_i (i_mtx_clk_pad),
      .mtxd_pad_o (o_mtxd_pad),
      .mtxen_pad_o (o_mtxen_pad),
      .mtxerr_pad_o (o_mtxerr_pad),

      .mrx_clk_pad_i (i_mrx_clk_pad),
      .mrxd_pad_i (i_mrxd_pad),
      .mrxdv_pad_i (i_mrxdv_pad),
      .mrxerr_pad_i (i_mrxerr_pad),

      .mcoll_pad_i (i_mcoll_pad),
      .mcrs_pad_i (i_mcrs_pad),

      .md_pad_i (i_md_pad),
      .mdc_pad_o (o_mdc_pad),
      .md_pad_o (o_md_pad),
      .md_padoe_o (o_md_padoe),

      .int_o (o_int)
      );

endmodule
