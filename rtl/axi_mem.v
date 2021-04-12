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

`default_nettype wire
module axi_mem
  #(parameter ID_WIDTH = 0,
    parameter MEM_SIZE = 0,
    parameter mem_clear = 0,
    parameter INIT_FILE = "")
  (input wire 		      clk,
   input wire 		      rst_n,

   input wire [ID_WIDTH-1:0]  i_awid,
   input wire [31:0] 	      i_awaddr,
   input wire [7:0] 	      i_awlen,
   input wire [2:0] 	      i_awsize,
   input wire [1:0] 	      i_awburst,
   input wire 		      i_awvalid,
   output wire 		      o_awready,

   input wire [ID_WIDTH-1:0]  i_arid,
   input wire [31:0] 	      i_araddr,
   input wire [7:0] 	      i_arlen,
   input wire [2:0] 	      i_arsize,
   input wire [1:0] 	      i_arburst,
   input wire 		      i_arvalid,
   output wire 		      o_arready,

   input wire [63:0] 	      i_wdata,
   input wire [7:0] 	      i_wstrb,
   input wire 		      i_wlast,
   input wire 		      i_wvalid,
   output wire 		      o_wready,

   output wire [ID_WIDTH-1:0] o_bid,
   output wire [1:0] 	      o_bresp,
   output wire 		      o_bvalid,
   input wire 		      i_bready,

   output wire [ID_WIDTH-1:0] o_rid,
   output wire [63:0] 	      o_rdata,
   output wire [1:0] 	      o_rresp,
   output wire 		      o_rlast,
   output wire 		      o_rvalid,
   input wire 		      i_rready);

   wire 	 mem_we;
   wire [31:0] 	 mem_addr;
   wire [7:0] 	 mem_be;
   wire [63:0] 	 mem_wdata;
   wire [63:0] 	 mem_rdata;
/*
   assign slave.aw_lock  = 1'd0;
   assign slave.aw_cache = 4'd0;
   assign slave.aw_prot  = 3'd0;
   assign slave.aw_qos   = 4'd0;
   assign slave.aw_region = 4'd0;
   assign slave.aw_atop  = 6'd0;
   assign slave.aw_user  = 1'd0;
   assign slave.aw_valid = i_awvalid;
   assign o_awready = slave.aw_ready;

   assign slave.ar_id    = i_arid   ;
   assign slave.ar_addr  = i_araddr ;
   assign slave.ar_len   = i_arlen  ;
   assign slave.ar_size  = i_arsize ;
   assign slave.ar_burst = i_arburst;
   assign slave.ar_lock  = 1'd0;
   assign slave.ar_cache = 4'd0;
   assign slave.ar_prot  = 3'd0;
   assign slave.ar_qos   = 4'd0;
   assign slave.ar_region = 4'd0;
   assign slave.ar_user  = 1'd0;
   assign slave.ar_valid = i_arvalid;
   assign o_arready = slave.ar_ready;

   assign slave.w_data  = i_wdata ;
   assign slave.w_strb  = i_wstrb ;
   assign slave.w_last  = i_wlast ;
   assign slave.w_user  = 1'd0;
   assign slave.w_valid = i_wvalid;
   assign o_wready = slave.w_ready;

   assign o_bid    = slave.b_id   ;
   assign o_bresp  = slave.b_resp ;
   assign o_bvalid = slave.b_valid;
   assign slave.b_ready = i_bready;

   assign o_rid    = slave.r_id   ;
   assign o_rdata  = slave.r_data ;
   assign o_rresp  = slave.r_resp ;
   assign o_rlast  = slave.r_last ;
   assign o_rvalid = slave.r_valid;
   assign slave.r_ready = i_rready;
*/
   axi2mem
     #(.ID_WIDTH   (ID_WIDTH),
       .AXI_ADDR_WIDTH (32),
       .AXI_DATA_WIDTH (64),
       .AXI_USER_WIDTH (0))
   ram_axi2mem
     (.clk_i  (clk),
      .rst_ni (rst_n),
      .slave_aw_id    (i_awid   ),
      .slave_aw_addr  (i_awaddr ),
      .slave_aw_len   (i_awlen  ),
      .slave_aw_size  (i_awsize ),
      .slave_aw_burst (i_awburst),
      .slave_aw_valid (i_awvalid),
      .slave_aw_ready (o_awready),
      .slave_ar_id    (i_arid   ),
      .slave_ar_addr  (i_araddr ),
      .slave_ar_len   (i_arlen  ),
      .slave_ar_size  (i_arsize ),
      .slave_ar_burst (i_arburst),
      .slave_ar_valid (i_arvalid),
      .slave_ar_ready (o_arready),

      .slave_w_data  (i_wdata ),
      .slave_w_strb  (i_wstrb ),
      .slave_w_last  (i_wlast ),
      .slave_w_valid (i_wvalid),
      .slave_w_ready (o_wready),
      .slave_b_id    (o_bid   ),
      .slave_b_resp  (o_bresp ),
      .slave_b_valid (o_bvalid),
      .slave_b_ready (i_bready),
      .slave_r_id    (o_rid   ),
      .slave_r_data  (o_rdata ),
      .slave_r_resp  (o_rresp ),
      .slave_r_last  (o_rlast ),
      .slave_r_valid (o_rvalid),
      .slave_r_ready (i_rready),
      .req_o  (),
      .we_o   (mem_we),
      .addr_o (mem_addr),
      .be_o   (mem_be),
      .data_o (mem_wdata),
      .data_i (mem_rdata));

   dpram64
     #(.SIZE (MEM_SIZE),
       .mem_clear (mem_clear),
       .memfile (INIT_FILE))
   ram
     (.clk   (clk),
      .we    ({8{mem_we}} & mem_be),
      .din   (mem_wdata),
      .waddr ({mem_addr[$clog2(MEM_SIZE)-1:3],3'b000}),
      .raddr ({mem_addr[$clog2(MEM_SIZE)-1:3],3'b000}),
      .dout  (mem_rdata));

endmodule
`default_nettype wire
