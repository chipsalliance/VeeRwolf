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
// Function: SweRVolf tech-agnostic toplevel
// Comments:
//
//********************************************************************************

`default_nettype none
module swervolf_core
  #(parameter bootrom_file  = "")
   (input wire 	clk,
    input wire 	rstn,
    output wire  [3:0] o_ram_awid,
    output wire [31:0] o_ram_awaddr,
    output wire  [7:0] o_ram_awlen,
    output wire  [2:0] o_ram_awsize,
    output wire  [1:0] o_ram_awburst,
    output wire        o_ram_awlock,
    output wire  [3:0] o_ram_awcache,
    output wire  [2:0] o_ram_awprot,
    output wire  [3:0] o_ram_awregion,
    output wire  [0:0] o_ram_awuser,
    output wire  [3:0] o_ram_awqos,
    output wire        o_ram_awvalid,
    input  wire        i_ram_awready,
    output wire  [3:0] o_ram_arid,
    output wire [31:0] o_ram_araddr,
    output wire  [7:0] o_ram_arlen,
    output wire  [2:0] o_ram_arsize,
    output wire  [1:0] o_ram_arburst,
    output wire        o_ram_arlock,
    output wire  [3:0] o_ram_arcache,
    output wire  [2:0] o_ram_arprot,
    output wire  [3:0] o_ram_arregion,
    output wire  [0:0] o_ram_aruser,
    output wire  [3:0] o_ram_arqos,
    output wire        o_ram_arvalid,
    input  wire        i_ram_arready,
    output wire [63:0] o_ram_wdata,
    output wire  [7:0] o_ram_wstrb,
    output wire        o_ram_wlast,
    output wire  [0:0] o_ram_wuser,
    output wire        o_ram_wvalid,
    input  wire        i_ram_wready,
    input  wire  [3:0] i_ram_bid,
    input  wire  [1:0] i_ram_bresp,
    input  wire        i_ram_bvalid,
    input  wire  [0:0] i_ram_buser,
    output wire        o_ram_bready,
    input  wire  [3:0] i_ram_rid,
    input  wire [63:0] i_ram_rdata,
    input  wire  [1:0] i_ram_rresp,
    input  wire        i_ram_rlast,
    input  wire  [0:0] i_ram_ruser,
    input  wire        i_ram_rvalid,
    output wire        o_ram_rready,
    output wire o_gpio);

   localparam BOOTROM_SIZE = 32'h1000;

   wire        rst_n = rstn;
   wire        timer_irq;

`include "axi_intercon.vh"

   assign o_ram_awid     = ram_awid;
   assign o_ram_awaddr   = ram_awaddr;
   assign o_ram_awlen    = ram_awlen;
   assign o_ram_awsize   = ram_awsize;
   assign o_ram_awburst  = ram_awburst;
   assign o_ram_awlock   = ram_awlock;
   assign o_ram_awcache  = ram_awcache;
   assign o_ram_awprot   = ram_awprot;
   assign o_ram_awregion = ram_awregion;
   assign o_ram_awuser   = ram_awuser;
   assign o_ram_awqos    = ram_awqos;
   assign o_ram_awvalid  = ram_awvalid;
   assign ram_awready    = i_ram_awready;
   assign o_ram_arid     = ram_arid;
   assign o_ram_araddr   = ram_araddr;
   assign o_ram_arlen    = ram_arlen;
   assign o_ram_arsize   = ram_arsize;
   assign o_ram_arburst  = ram_arburst;
   assign o_ram_arlock   = ram_arlock;
   assign o_ram_arcache  = ram_arcache;
   assign o_ram_arprot   = ram_arprot;
   assign o_ram_arregion = ram_arregion;
   assign o_ram_aruser   = ram_aruser;
   assign o_ram_arqos    = ram_arqos;
   assign o_ram_arvalid  = ram_arvalid;
   assign ram_arready    = i_ram_arready;
   assign o_ram_wdata    = ram_wdata;
   assign o_ram_wstrb    = ram_wstrb;
   assign o_ram_wlast    = ram_wlast;
   assign o_ram_wuser    = ram_wuser;
   assign o_ram_wvalid   = ram_wvalid;
   assign ram_wready     = i_ram_wready;
   assign ram_bid        = i_ram_bid;
   assign ram_bresp      = i_ram_bresp;
   assign ram_bvalid     = i_ram_bvalid;
   assign ram_buser      = i_ram_buser;
   assign o_ram_bready   = ram_bready;
   assign ram_rid        = i_ram_rid;
   assign ram_rdata      = i_ram_rdata;
   assign ram_rresp      = i_ram_rresp;
   assign ram_rlast      = i_ram_rlast;
   assign ram_ruser      = i_ram_ruser;
   assign ram_rvalid     = i_ram_rvalid;
   assign o_ram_rready   = ram_rready;

   axi_mem_wrapper
     #(.ID_WIDTH  (`RV_IFU_BUS_TAG+1),
       .MEM_SIZE  (BOOTROM_SIZE),
       .INIT_FILE (bootrom_file))
   bootrom
     (.clk      (clk),
      .rst_n    (rst_n),
      .i_awid    (rom_awid),
      .i_awaddr  (rom_awaddr),
      .i_awlen   (rom_awlen),
      .i_awsize  (rom_awsize),
      .i_awburst (rom_awburst),
      .i_awvalid (rom_awvalid),
      .o_awready (rom_awready),

      .i_arid    (rom_arid),
      .i_araddr  (rom_araddr),
      .i_arlen   (rom_arlen),
      .i_arsize  (rom_arsize),
      .i_arburst (rom_arburst),
      .i_arvalid (rom_arvalid),
      .o_arready (rom_arready),

      .i_wdata  (rom_wdata),
      .i_wstrb  (rom_wstrb),
      .i_wlast  (rom_wlast),
      .i_wvalid (rom_wvalid),
      .o_wready (rom_wready),

      .o_bid    (rom_bid),
      .o_bresp  (rom_bresp),
      .o_bvalid (rom_bvalid),
      .i_bready (rom_bready),

      .o_rid    (rom_rid),
      .o_rdata  (rom_rdata),
      .o_rresp  (rom_rresp),
      .o_rlast  (rom_rlast),
      .o_rvalid (rom_rvalid),
      .i_rready (rom_rready));

   axi_multicon
     #(.ID_WIDTH  (`RV_IFU_BUS_TAG+1))
   multicon
     (.clk       (clk),
      .rst_n     (rst_n),
      .o_gpio    (o_gpio),
      .o_timer_irq (timer_irq),
      .i_awid    (multicon_awid),
      .i_awaddr  (multicon_awaddr),
      .i_awlen   (multicon_awlen),
      .i_awsize  (multicon_awsize),
      .i_awburst (multicon_awburst),
      .i_awvalid (multicon_awvalid),
      .o_awready (multicon_awready),
      .i_arid    (multicon_arid),
      .i_araddr  (multicon_araddr),
      .i_arlen   (multicon_arlen),
      .i_arsize  (multicon_arsize),
      .i_arburst (multicon_arburst),
      .i_arvalid (multicon_arvalid),
      .o_arready (multicon_arready),
      .i_wdata   (multicon_wdata),
      .i_wstrb   (multicon_wstrb),
      .i_wlast   (multicon_wlast),
      .i_wvalid  (multicon_wvalid),
      .o_wready  (multicon_wready),
      .o_bid     (multicon_bid),
      .o_bresp   (multicon_bresp),
      .o_bvalid  (multicon_bvalid),
      .i_bready  (multicon_bready),
      .o_rid     (multicon_rid),
      .o_rdata   (multicon_rdata),
      .o_rresp   (multicon_rresp),
      .o_rlast   (multicon_rlast),
      .o_rvalid  (multicon_rvalid),
      .i_rready  (multicon_rready));

   swerv_wrapper rvtop
     (
      .clk     (clk),
      .rst_l   (rstn),
      .rst_vec (31'h40000000),
      .nmi_int (1'b0),
      .nmi_vec (31'h8880000),
      .jtag_id (31'd0),

      .trace_rv_i_insn_ip      (),
      .trace_rv_i_address_ip   (),
      .trace_rv_i_valid_ip     (),
      .trace_rv_i_exception_ip (),
      .trace_rv_i_ecause_ip    (),
      .trace_rv_i_interrupt_ip (),
      .trace_rv_i_tval_ip      (),

      // Bus signals
      //-------------------------- LSU AXI signals--------------------------
      .lsu_axi_awvalid  (lsu_awvalid),
      .lsu_axi_awready  (lsu_awready),
      .lsu_axi_awid     (lsu_awid   ),
      .lsu_axi_awaddr   (lsu_awaddr ),
      .lsu_axi_awregion (lsu_awregion),
      .lsu_axi_awlen    (lsu_awlen  ),
      .lsu_axi_awsize   (lsu_awsize ),
      .lsu_axi_awburst  (lsu_awburst),
      .lsu_axi_awlock   (lsu_awlock ),
      .lsu_axi_awcache  (lsu_awcache),
      .lsu_axi_awprot   (lsu_awprot ),
      .lsu_axi_awqos    (lsu_awqos  ),

      .lsu_axi_wvalid   (lsu_wvalid),
      .lsu_axi_wready   (lsu_wready),
      .lsu_axi_wdata    (lsu_wdata),
      .lsu_axi_wstrb    (lsu_wstrb),
      .lsu_axi_wlast    (lsu_wlast),

      .lsu_axi_bvalid   (lsu_bvalid),
      .lsu_axi_bready   (lsu_bready),
      .lsu_axi_bresp    (lsu_bresp),
      .lsu_axi_bid      ({1'b0,lsu_bid}),

      .lsu_axi_arvalid  (lsu_arvalid ),
      .lsu_axi_arready  (lsu_arready ),
      .lsu_axi_arid     (lsu_arid    ),
      .lsu_axi_araddr   (lsu_araddr  ),
      .lsu_axi_arregion (lsu_arregion),
      .lsu_axi_arlen    (lsu_arlen   ),
      .lsu_axi_arsize   (lsu_arsize  ),
      .lsu_axi_arburst  (lsu_arburst ),
      .lsu_axi_arlock   (lsu_arlock  ),
      .lsu_axi_arcache  (lsu_arcache ),
      .lsu_axi_arprot   (lsu_arprot  ),
      .lsu_axi_arqos    (lsu_arqos   ),

      .lsu_axi_rvalid   (lsu_rvalid),
      .lsu_axi_rready   (lsu_rready),
      .lsu_axi_rid      ({1'b0,lsu_rid}   ),
      .lsu_axi_rdata    (lsu_rdata ),
      .lsu_axi_rresp    (lsu_rresp ),
      .lsu_axi_rlast    (lsu_rlast ),

      //-------------------------- IFU AXI signals--------------------------
      .ifu_axi_awvalid  (),
      .ifu_axi_awready  (1'b0),
      .ifu_axi_awid     (),
      .ifu_axi_awaddr   (),
      .ifu_axi_awregion (),
      .ifu_axi_awlen    (),
      .ifu_axi_awsize   (),
      .ifu_axi_awburst  (),
      .ifu_axi_awlock   (),
      .ifu_axi_awcache  (),
      .ifu_axi_awprot   (),
      .ifu_axi_awqos    (),

      .ifu_axi_wvalid   (),
      .ifu_axi_wready   (1'b0),
      .ifu_axi_wdata    (),
      .ifu_axi_wstrb    (),
      .ifu_axi_wlast    (),

      .ifu_axi_bvalid   (1'b0),
      .ifu_axi_bready   (),
      .ifu_axi_bresp    (2'b00),
      .ifu_axi_bid      (3'd0),

      .ifu_axi_arvalid  (ifu_arvalid ),
      .ifu_axi_arready  (ifu_arready ),
      .ifu_axi_arid     (ifu_arid    ),
      .ifu_axi_araddr   (ifu_araddr  ),
      .ifu_axi_arregion (ifu_arregion),
      .ifu_axi_arlen    (ifu_arlen   ),
      .ifu_axi_arsize   (ifu_arsize  ),
      .ifu_axi_arburst  (ifu_arburst ),
      .ifu_axi_arlock   (ifu_arlock  ),
      .ifu_axi_arcache  (ifu_arcache ),
      .ifu_axi_arprot   (ifu_arprot  ),
      .ifu_axi_arqos    (ifu_arqos   ),

      .ifu_axi_rvalid   (ifu_rvalid),
      .ifu_axi_rready   (ifu_rready),
      .ifu_axi_rid      (ifu_rid   ),
      .ifu_axi_rdata    (ifu_rdata ),
      .ifu_axi_rresp    (ifu_rresp ),
      .ifu_axi_rlast    (ifu_rlast ),

      //-------------------------- SB AXI signals-------------------------
      .sb_axi_awvalid  (),
      .sb_axi_awready  (1'b0),
      .sb_axi_awid     (),
      .sb_axi_awaddr   (),
      .sb_axi_awregion (),
      .sb_axi_awlen    (),
      .sb_axi_awsize   (),
      .sb_axi_awburst  (),
      .sb_axi_awlock   (),
      .sb_axi_awcache  (),
      .sb_axi_awprot   (),
      .sb_axi_awqos    (),

      .sb_axi_wvalid   (),
      .sb_axi_wready   (1'b0),
      .sb_axi_wdata    (),
      .sb_axi_wstrb    (),
      .sb_axi_wlast    (),

      .sb_axi_bvalid   (1'b0),
      .sb_axi_bready   (),
      .sb_axi_bresp    (2'b00),
      .sb_axi_bid      (`RV_SB_BUS_TAG'd0),

      .sb_axi_arvalid  (),
      .sb_axi_arready  (1'b0),
      .sb_axi_arid     (),
      .sb_axi_araddr   (),
      .sb_axi_arregion (),
      .sb_axi_arlen    (),
      .sb_axi_arsize   (),
      .sb_axi_arburst  (),
      .sb_axi_arlock   (),
      .sb_axi_arcache  (),
      .sb_axi_arprot   (),
      .sb_axi_arqos    (),

      .sb_axi_rvalid   (1'b0),
      .sb_axi_rready   (),
      .sb_axi_rid      (`RV_SB_BUS_TAG'd0),
      .sb_axi_rdata    (64'd0),
      .sb_axi_rresp    (2'b00),
      .sb_axi_rlast    (1'b0),

      //-------------------------- DMA AXI signals--------------------------
      .dma_axi_awvalid  (1'b0),
      .dma_axi_awready  (),
      .dma_axi_awid     (`RV_DMA_BUS_TAG'd0),
      .dma_axi_awaddr   (32'd0),
      .dma_axi_awsize   (3'd0),
      .dma_axi_awprot   (3'd0),
      .dma_axi_awlen    (8'd0),
      .dma_axi_awburst  (2'd0),

      .dma_axi_wvalid   (1'b0),
      .dma_axi_wready   (),
      .dma_axi_wdata    (64'd0),
      .dma_axi_wstrb    (8'd0),
      .dma_axi_wlast    (1'b0),

      .dma_axi_bvalid   (),
      .dma_axi_bready   (1'b0),
      .dma_axi_bresp    (),
      .dma_axi_bid      (),

      .dma_axi_arvalid  (1'b0),
      .dma_axi_arready  (),
      .dma_axi_arid     (`RV_DMA_BUS_TAG'd0),
      .dma_axi_araddr   (32'd0),
      .dma_axi_arsize   (3'd0),
      .dma_axi_arprot   (3'd0),
      .dma_axi_arlen    (8'd0),
      .dma_axi_arburst  (2'd0),

      .dma_axi_rvalid   (),
      .dma_axi_rready   (1'b0),
      .dma_axi_rid      (),
      .dma_axi_rdata    (),
      .dma_axi_rresp    (),
      .dma_axi_rlast    (),

      // clk ratio signals
      .lsu_bus_clk_en (1'b1),
      .ifu_bus_clk_en (1'b1),
      .dbg_bus_clk_en (1'b1),
      .dma_bus_clk_en (1'b1),

      .timer_int (timer_irq),
      .extintsrc_req ('0),

      .dec_tlu_perfcnt0 (),
      .dec_tlu_perfcnt1 (),
      .dec_tlu_perfcnt2 (),
      .dec_tlu_perfcnt3 (),

      .jtag_tck    (1'b0),
      .jtag_tms    (1'b0),
      .jtag_tdi    (1'b0),
      .jtag_trst_n (1'b0),
      .jtag_tdo    (),

      .mpc_debug_halt_req (1'b0),
      .mpc_debug_run_req  (1'b0),
      .mpc_reset_run_req  (1'b1),
      .mpc_debug_halt_ack (),
      .mpc_debug_run_ack  (),
      .debug_brkpt_status (),

      .i_cpu_halt_req      (1'b0),
      .o_cpu_halt_ack      (),
      .o_cpu_halt_status   (),
      .o_debug_mode_status (),
      .i_cpu_run_req       (1'b0),
      .o_cpu_run_ack       (),

      .scan_mode  (1'b0),
      .mbist_mode (1'b0));

endmodule
