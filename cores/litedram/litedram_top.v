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
`default_nettype none

module litedram_top
  #(parameter ID_WIDTH = 0)
   (
    output reg 		       serial_tx,
    input wire 		       serial_rx,
    input wire 		       clk100,
    input wire 		       rst_n,
    output wire 	       pll_locked,
    output wire 	       user_clk,
    output wire 	       user_rst,
    output wire [12:0] 	       ddram_a,
    output wire [2:0] 	       ddram_ba,
    output wire 	       ddram_ras_n,
    output wire 	       ddram_cas_n,
    output wire 	       ddram_we_n,
    output wire 	       ddram_cs_n,
    output wire [1:0] 	       ddram_dm,
    inout wire [15:0] 	       ddram_dq,
    output wire [1:0] 	       ddram_dqs_p,
    output wire [1:0] 	       ddram_dqs_n,
    output wire 	       ddram_clk_p,
    output wire 	       ddram_clk_n,
    output wire 	       ddram_cke,
    output wire 	       ddram_odt,

    output reg 		       init_done,
    output reg 		       init_error,
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

   reg 			       serial_rx_int;
   wire 		       serial_tx_int;

   wire 		       init_done_int;
   wire 		       init_error_int;
   reg 			       init_done_int_r;
   reg 			       init_error_int_r;

   always @(posedge user_clk) begin
      serial_rx_int <= serial_rx;
      serial_tx <= serial_tx_int;
      init_done_int_r <= init_done_int;
      init_done <= init_done_int_r;
      init_error_int_r <= init_error_int;
      init_error <= init_error_int_r;
   end

litedram_core ldc
  (
   .serial_tx   (serial_tx_int),
   .serial_rx   (serial_rx_int),
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
   .init_done  (init_done_int),
   .init_error (init_error_int),
   .user_clk   (user_clk),
   .user_rst   (user_rst),
   .user_port_axi_0_awaddr  (i_awaddr),
   .user_port_axi_0_awburst (i_awburst),
   .user_port_axi_0_awlen   (i_awlen),
   .user_port_axi_0_awsize  (i_awsize),
   .user_port_axi_0_awid    (i_awid),
   .user_port_axi_0_awvalid (i_awvalid),
   .user_port_axi_0_awready (o_awready),
   .user_port_axi_0_wdata   (i_wdata),
   .user_port_axi_0_wstrb   (i_wstrb),
   .user_port_axi_0_wlast   (i_wlast),
   .user_port_axi_0_wvalid  (i_wvalid),
   .user_port_axi_0_wready  (o_wready),
   .user_port_axi_0_bresp   (o_bresp),
   .user_port_axi_0_bid     (o_bid),
   .user_port_axi_0_bvalid  (o_bvalid),
   .user_port_axi_0_bready  (i_bready),
   .user_port_axi_0_araddr  (i_araddr),
   .user_port_axi_0_arburst (i_arburst),
   .user_port_axi_0_arlen   (i_arlen),
   .user_port_axi_0_arsize  (i_arsize),
   .user_port_axi_0_arid    (i_arid),
   .user_port_axi_0_arvalid (i_arvalid),
   .user_port_axi_0_arready (o_arready),
   .user_port_axi_0_rdata   (o_rdata),
   .user_port_axi_0_rresp   (o_rresp),
   .user_port_axi_0_rlast   (o_rlast),
   .user_port_axi_0_rid     (o_rid),
   .user_port_axi_0_rvalid  (o_rvalid),
   .user_port_axi_0_rready  (i_rready));

endmodule
`default_nettype wire
