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
// Function: SweRVolf toplevel for Nexys A7 board
// Comments:
//
//********************************************************************************

`default_nettype none
module swervolf_nexys_a7
  #(parameter bootrom_file = "jumptoram.vh",
    parameter ram_init_file = "zephyr_blinky.vh")
   (input wire 	       clk,
    input wire 	       rstn,
    output wire [12:0] ddram_a,
    output wire [2:0]  ddram_ba,
    output wire        ddram_ras_n,
    output wire        ddram_cas_n,
    output wire        ddram_we_n,
    output wire        ddram_cs_n,
    output wire [1:0]  ddram_dm,
    inout wire [15:0]  ddram_dq,
    output wire [1:0]  ddram_dqs_p,
    output wire [1:0]  ddram_dqs_n,
    output wire        ddram_clk_p,
    output wire        ddram_clk_n,
    output wire        ddram_cke,
    output wire        ddram_odt,
    output wire        o_serial_tx,
    input wire 	       i_serial_rx,
    output wire        led0);

   localparam RAM_SIZE     = 32'h10000;

   wire 	 clk25;
   wire 	 rst25;
   wire 	 user_clk;
   wire 	 user_rst;

   clk_gen_nexys clk_gen
     (.i_clk (user_clk),
      .i_rst (user_rst),
      .o_clk25 (clk25),
      .o_rst25 (rst25));

   wire [3:0]  ram_awid;
   wire [31:0] ram_awaddr;
   wire [7:0]  ram_awlen;
   wire [2:0]  ram_awsize;
   wire [1:0]  ram_awburst;
   wire        ram_awlock;
   wire [3:0]  ram_awcache;
   wire [2:0]  ram_awprot;
   wire [3:0]  ram_awregion;
   wire [0:0]  ram_awuser;
   wire [3:0]  ram_awqos;
   wire        ram_awvalid;
   wire        ram_awready;
   wire [3:0]  ram_arid;
   wire [31:0] ram_araddr;
   wire [7:0]  ram_arlen;
   wire [2:0]  ram_arsize;
   wire [1:0]  ram_arburst;
   wire        ram_arlock;
   wire [3:0]  ram_arcache;
   wire [2:0]  ram_arprot;
   wire [3:0]  ram_arregion;
   wire [0:0]  ram_aruser;
   wire [3:0]  ram_arqos;
   wire        ram_arvalid;
   wire        ram_arready;
   wire [63:0] ram_wdata;
   wire [7:0]  ram_wstrb;
   wire        ram_wlast;
   wire [0:0]  ram_wuser;
   wire        ram_wvalid;
   wire        ram_wready;
   wire [3:0]  ram_bid;
   wire [1:0]  ram_bresp;
   wire        ram_bvalid;
   wire [0:0]  ram_buser;
   wire        ram_bready;
   wire [3:0]  ram_rid;
   wire [63:0] ram_rdata;
   wire [1:0]  ram_rresp;
   wire        ram_rlast;
   wire [0:0]  ram_ruser;
   wire        ram_rvalid;
   wire        ram_rready;

   wire [3:0]  cpu_axi_awid;
   wire [31:0] cpu_axi_awaddr;
   wire [7:0]  cpu_axi_awlen;
   wire [2:0]  cpu_axi_awsize;
   wire [1:0]  cpu_axi_awburst;
   wire        cpu_axi_awlock;
   wire [3:0]  cpu_axi_awcache;
   wire [2:0]  cpu_axi_awprot;
   wire [3:0]  cpu_axi_awregion;
   wire [0:0]  cpu_axi_awuser;
   wire [3:0]  cpu_axi_awqos;
   wire        cpu_axi_awvalid;
   wire        cpu_axi_awready;
   wire [3:0]  cpu_axi_arid;
   wire [31:0] cpu_axi_araddr;
   wire [7:0]  cpu_axi_arlen;
   wire [2:0]  cpu_axi_arsize;
   wire [1:0]  cpu_axi_arburst;
   wire        cpu_axi_arlock;
   wire [3:0]  cpu_axi_arcache;
   wire [2:0]  cpu_axi_arprot;
   wire [3:0]  cpu_axi_arregion;
   wire [0:0]  cpu_axi_aruser;
   wire [3:0]  cpu_axi_arqos;
   wire        cpu_axi_arvalid;
   wire        cpu_axi_arready;
   wire [63:0] cpu_axi_wdata;
   wire [7:0]  cpu_axi_wstrb;
   wire        cpu_axi_wlast;
   wire [0:0]  cpu_axi_wuser;
   wire        cpu_axi_wvalid;
   wire        cpu_axi_wready;
   wire [3:0]  cpu_axi_bid;
   wire [1:0]  cpu_axi_bresp;
   wire        cpu_axi_bvalid;
   wire [0:0]  cpu_axi_buser;
   wire        cpu_axi_bready;
   wire [3:0]  cpu_axi_rid;
   wire [63:0] cpu_axi_rdata;
   wire [1:0]  cpu_axi_rresp;
   wire        cpu_axi_rlast;
   wire [0:0]  cpu_axi_ruser;
   wire        cpu_axi_rvalid;
   wire        cpu_axi_rready;

   axi_cdc cdc
     (
      .s_axi_aclk    (clk25),
      .s_axi_aresetn (~rst25),
      .s_axi_awid    (cpu_axi_awid),
      .s_axi_awaddr  (cpu_axi_awaddr),
      .s_axi_awlen   (cpu_axi_awlen),
      .s_axi_awsize  (cpu_axi_awsize),
      .s_axi_awburst (cpu_axi_awburst),
      .s_axi_awlock  (cpu_axi_awlock),
      .s_axi_awcache (cpu_axi_awcache),
      .s_axi_awprot  (cpu_axi_awprot),
      .s_axi_awregion(cpu_axi_awregion),
      .s_axi_awqos   (cpu_axi_awqos),
      .s_axi_awvalid (cpu_axi_awvalid),
      .s_axi_awready (cpu_axi_awready),
      .s_axi_wdata   (cpu_axi_wdata),
      .s_axi_wstrb   (cpu_axi_wstrb),
      .s_axi_wlast   (cpu_axi_wlast),
      .s_axi_wvalid  (cpu_axi_wvalid),
      .s_axi_wready  (cpu_axi_wready),
      .s_axi_bid     (cpu_axi_bid),
      .s_axi_bresp   (cpu_axi_bresp),
      .s_axi_bvalid  (cpu_axi_bvalid),
      .s_axi_bready  (cpu_axi_bready),
      .s_axi_arid    (cpu_axi_arid),
      .s_axi_araddr  (cpu_axi_araddr),
      .s_axi_arlen   (cpu_axi_arlen),
      .s_axi_arsize  (cpu_axi_arsize),
      .s_axi_arburst (cpu_axi_arburst),
      .s_axi_arlock  (cpu_axi_arlock),
      .s_axi_arcache (cpu_axi_arcache),
      .s_axi_arprot  (cpu_axi_arprot),
      .s_axi_arregion(cpu_axi_arregion),
      .s_axi_arqos   (cpu_axi_arqos),
      .s_axi_arvalid (cpu_axi_arvalid),
      .s_axi_arready (cpu_axi_arready),
      .s_axi_rid     (cpu_axi_rid),
      .s_axi_rdata   (cpu_axi_rdata),
      .s_axi_rresp   (cpu_axi_rresp),
      .s_axi_rlast   (cpu_axi_rlast),
      .s_axi_rvalid  (cpu_axi_rvalid),
      .s_axi_rready  (cpu_axi_rready),

      .m_axi_aclk     (user_clk),
      .m_axi_aresetn  (~user_rst),
      .m_axi_awid     (ram_awid),
      .m_axi_awaddr   (ram_awaddr),
      .m_axi_awlen    (ram_awlen),
      .m_axi_awsize   (ram_awsize),
      .m_axi_awburst  (ram_awburst),
      .m_axi_awlock   (ram_awlock),
      .m_axi_awcache  (ram_awcache),
      .m_axi_awprot   (ram_awprot),
      .m_axi_awregion (ram_awregion),
      .m_axi_awqos    (ram_awqos),
      .m_axi_awvalid  (ram_awvalid),
      .m_axi_awready  (ram_awready),
      .m_axi_wdata    (ram_wdata),
      .m_axi_wstrb    (ram_wstrb),
      .m_axi_wlast    (ram_wlast),
      .m_axi_wvalid   (ram_wvalid),
      .m_axi_wready   (ram_wready),
      .m_axi_bid      (ram_bid),
      .m_axi_bresp    (ram_bresp),
      .m_axi_bvalid   (ram_bvalid),
      .m_axi_bready   (ram_bready),
      .m_axi_arid     (ram_arid),
      .m_axi_araddr   (ram_araddr),
      .m_axi_arlen    (ram_arlen),
      .m_axi_arsize   (ram_arsize),
      .m_axi_arburst  (ram_arburst),
      .m_axi_arlock   (ram_arlock),
      .m_axi_arcache  (ram_arcache),
      .m_axi_arprot   (ram_arprot),
      .m_axi_arregion (ram_arregion),
      .m_axi_arqos    (ram_arqos),
      .m_axi_arvalid  (ram_arvalid),
      .m_axi_arready  (ram_arready),
      .m_axi_rid      (ram_rid),
      .m_axi_rdata    (ram_rdata),
      .m_axi_rresp    (ram_rresp),
      .m_axi_rlast    (ram_rlast),
      .m_axi_rvalid   (ram_rvalid),
      .m_axi_rready   (ram_rready));

   litedram_top
     #(.ID_WIDTH (4))
   dut
     (.serial_tx   (o_serial_tx),
      .serial_rx   (i_serial_rx),
      .clk100      (clk),
      .rst_n       (rstn),
      .pll_locked  (),
      .user_clk    (user_clk),
      .user_rst    (user_rst),
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
      .init_done  (),
      .init_error (),
      .i_awid    (ram_awid),
      .i_awaddr  (ram_awaddr),
      .i_awlen   (ram_awlen),
      .i_awsize  (ram_awsize),
      .i_awburst (ram_awburst),
      .i_awvalid (ram_awvalid),
      .o_awready (ram_awready),

      .i_arid    (ram_arid),
      .i_araddr  (ram_araddr),
      .i_arlen   (ram_arlen),
      .i_arsize  (ram_arsize),
      .i_arburst (ram_arburst),
      .i_arvalid (ram_arvalid),
      .o_arready (ram_arready),

      .i_wdata  (ram_wdata),
      .i_wstrb  (ram_wstrb),
      .i_wlast  (ram_wlast),
      .i_wvalid (ram_wvalid),
      .o_wready (ram_wready),

      .o_bid    (ram_bid),
      .o_bresp  (ram_bresp),
      .o_bvalid (ram_bvalid),
      .i_bready (ram_bready),

      .o_rid    (ram_rid),
      .o_rdata  (ram_rdata),
      .o_rresp  (ram_rresp),
      .o_rlast  (ram_rlast),
      .o_rvalid (ram_rvalid),
      .i_rready (ram_rready));

   swervolf_core
     #(.bootrom_file (bootrom_file))
   swervolf
     (.clk  (clk25),
      .rstn (~rst25),
      .o_ram_awid     (cpu_axi_awid),
      .o_ram_awaddr   (cpu_axi_awaddr),
      .o_ram_awlen    (cpu_axi_awlen),
      .o_ram_awsize   (cpu_axi_awsize),
      .o_ram_awburst  (cpu_axi_awburst),
      .o_ram_awlock   (cpu_axi_awlock),
      .o_ram_awcache  (cpu_axi_awcache),
      .o_ram_awprot   (cpu_axi_awprot),
      .o_ram_awregion (cpu_axi_awregion),
      .o_ram_awuser   (cpu_axi_awuser),
      .o_ram_awqos    (cpu_axi_awqos),
      .o_ram_awvalid  (cpu_axi_awvalid),
      .i_ram_awready  (cpu_axi_awready),
      .o_ram_arid     (cpu_axi_arid),
      .o_ram_araddr   (cpu_axi_araddr),
      .o_ram_arlen    (cpu_axi_arlen),
      .o_ram_arsize   (cpu_axi_arsize),
      .o_ram_arburst  (cpu_axi_arburst),
      .o_ram_arlock   (cpu_axi_arlock),
      .o_ram_arcache  (cpu_axi_arcache),
      .o_ram_arprot   (cpu_axi_arprot),
      .o_ram_arregion (cpu_axi_arregion),
      .o_ram_aruser   (cpu_axi_aruser),
      .o_ram_arqos    (cpu_axi_arqos),
      .o_ram_arvalid  (cpu_axi_arvalid),
      .i_ram_arready  (cpu_axi_arready),
      .o_ram_wdata    (cpu_axi_wdata),
      .o_ram_wstrb    (cpu_axi_wstrb),
      .o_ram_wlast    (cpu_axi_wlast),
      .o_ram_wuser    (cpu_axi_wuser),
      .o_ram_wvalid   (cpu_axi_wvalid),
      .i_ram_wready   (cpu_axi_wready),
      .i_ram_bid      (cpu_axi_bid),
      .i_ram_bresp    (cpu_axi_bresp),
      .i_ram_bvalid   (cpu_axi_bvalid),
      .i_ram_buser    (cpu_axi_buser),
      .o_ram_bready   (cpu_axi_bready),
      .i_ram_rid      (cpu_axi_rid),
      .i_ram_rdata    (cpu_axi_rdata),
      .i_ram_rresp    (cpu_axi_rresp),
      .i_ram_rlast    (cpu_axi_rlast),
      .i_ram_ruser    (cpu_axi_ruser),
      .i_ram_rvalid   (cpu_axi_rvalid),
      .o_ram_rready   (cpu_axi_rready),
      .o_gpio (led0));

endmodule
