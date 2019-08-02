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
// Function: Wrapper for LiteDRAM DDR2 controller
// Comments:
//
//********************************************************************************

`timescale 1ps / 1ps
module litedram_top
  #(parameter ID_WIDTH = 0)
   (
    output 		       serial_tx,
    input 		       serial_rx,
    input 		       clk100,
    input 		       rst_n,
    output 		       pll_locked,
    output 		       user_clk,
    output 		       user_rst,
    output [12:0] 	       ddram_a,
    output [2:0] 	       ddram_ba,
    output 		       ddram_ras_n,
    output 		       ddram_cas_n,
    output 		       ddram_we_n,
    output 		       ddram_cs_n,
    output [1:0] 	       ddram_dm,
    inout [15:0] 	       ddram_dq,
    output [1:0] 	       ddram_dqs_p,
    output [1:0] 	       ddram_dqs_n,
    output 		       ddram_clk_p,
    output 		       ddram_clk_n,
    output 		       ddram_cke,
    output 		       ddram_odt,

    output 		       init_done,
    output 		       init_error,
    input wire [ID_WIDTH-1:0]  i_awid,
    input wire [26:0] 	       i_awaddr,
    input wire [7:0] 	       i_awlen,
    input wire [3:0] 	       i_awsize,
    input wire [1:0] 	       i_awburst,
    input wire 		       i_awvalid,
    output wire 	       o_awready,

    input wire [ID_WIDTH-1:0]  i_arid,
    input wire [26:0] 	       i_araddr,
    input wire [7:0] 	       i_arlen,
    input wire [3:0] 	       i_arsize,
    input wire [1:0] 	       i_arburst,
    input wire 		       i_arvalid,
    output wire 	       o_arready,

    input wire [63:0] 	       i_wdata,
    input wire [7:0] 	       i_wstrb,
    input wire 		       i_wlast,
    input wire 		       i_wvalid,
    output wire 	       o_wready,

    output wire [ID_WIDTH-1:0] o_bid,
    output wire [1:0] 	       o_bresp,
    output wire 	       o_bvalid,
    input wire 		       i_bready,

    output wire [ID_WIDTH-1:0] o_rid,
    output wire [63:0] 	       o_rdata,
    output wire [1:0] 	       o_rresp,
    output wire 	       o_rlast,
    output wire 	       o_rvalid,
    input wire 		       i_rready);


litedram_core ldc
  (
   .serial_tx   (serial_tx),
   .serial_rx   (serial_rx),
   .clk         (clk100),
   .rst         (!rst_n),
   .pll_locked  (pll_locked),
   .ddram_a     (ddram_a),
   .ddram_ba    (ddram_ba),
   .ddram_ras_n (ddram_ras_n),
   .ddram_cas_n (ddram_cas_n),
   .ddram_we_n  (ddram_we_n),
   .ddram_cs_n  (ddram_cs_n),
   .ddram_dm    (ddram_dm   ),
   .ddram_dq    (ddram_dq   ),
   .ddram_dqs_p (ddram_dqs_p),
   .ddram_dqs_n (ddram_dqs_n),
   .ddram_clk_p (ddram_clk_p),
   .ddram_clk_n (ddram_clk_n),
   .ddram_cke   (ddram_cke  ),
   .ddram_odt   (ddram_odt  ),
   .ddram_reset_n (),
   .init_done  (init_done),
   .init_error (init_error),
   .user_clk   (user_clk),
   .user_rst   (user_rst),
   .user_port0_aw_addr  (i_awaddr),
   .user_port0_aw_burst (i_awburst),
   .user_port0_aw_len   (i_awlen),
   .user_port0_aw_size  (i_awsize),
   .user_port0_aw_id    (i_awid),
   .user_port0_aw_valid (i_awvalid),
   .user_port0_aw_ready (o_awready),
   .user_port0_w_data   (i_wdata),
   .user_port0_w_strb   (i_wstrb),
   .user_port0_w_last   (i_wlast),
   .user_port0_w_valid  (i_wvalid),
   .user_port0_w_ready  (o_wready),
   .user_port0_b_resp   (o_bresp),
   .user_port0_b_id     (o_bid),
   .user_port0_b_valid  (o_bvalid),
   .user_port0_b_ready  (i_bready),
   .user_port0_ar_addr  (i_araddr),
   .user_port0_ar_burst (i_arburst),
   .user_port0_ar_len   (i_arlen),
   .user_port0_ar_size  (i_arsize),
   .user_port0_ar_id    (i_arid),
   .user_port0_ar_valid (i_arvalid),
   .user_port0_ar_ready (o_arready),
   .user_port0_r_data   (o_rdata),
   .user_port0_r_resp   (o_rresp),
   .user_port0_r_last   (o_rlast),
   .user_port0_r_id     (o_rid),
   .user_port0_r_valid  (o_rvalid),
   .user_port0_r_ready  (i_rready));

endmodule   
