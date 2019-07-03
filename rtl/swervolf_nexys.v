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
    input wire 	rstn,
    input wire 	i_uart_rx,
    output wire o_uart_tx,
    output wire led0);

   localparam RAM_SIZE     = 32'h10000;

   wire 	 clk25;
   wire 	 rst25;

   clk_gen_nexys clk_gen
     (.i_clk (clk),
      .i_rst (~rstn),
      .o_clk25 (clk25),
      .o_rst25 (rst25));

   wire [5:0]  ram_awid;
   wire [31:0] ram_awaddr;
   wire [7:0]  ram_awlen;
   wire [2:0]  ram_awsize;
   wire [1:0]  ram_awburst;
   wire        ram_awlock;
   wire [3:0]  ram_awcache;
   wire [2:0]  ram_awprot;
   wire [3:0]  ram_awregion;
   wire [3:0]  ram_awqos;
   wire        ram_awvalid;
   wire        ram_awready;
   wire [5:0]  ram_arid;
   wire [31:0] ram_araddr;
   wire [7:0]  ram_arlen;
   wire [2:0]  ram_arsize;
   wire [1:0]  ram_arburst;
   wire        ram_arlock;
   wire [3:0]  ram_arcache;
   wire [2:0]  ram_arprot;
   wire [3:0]  ram_arregion;
   wire [3:0]  ram_arqos;
   wire        ram_arvalid;
   wire        ram_arready;
   wire [63:0] ram_wdata;
   wire [7:0]  ram_wstrb;
   wire        ram_wlast;
   wire        ram_wvalid;
   wire        ram_wready;
   wire [5:0]  ram_bid;
   wire [1:0]  ram_bresp;
   wire        ram_bvalid;
   wire        ram_bready;
   wire [5:0]  ram_rid;
   wire [63:0] ram_rdata;
   wire [1:0]  ram_rresp;
   wire        ram_rlast;
   wire        ram_rvalid;
   wire        ram_rready;

   wire        dmi_reg_en;
   wire [6:0]  dmi_reg_addr;
   wire        dmi_reg_wr_en;
   wire [31:0] dmi_reg_wdata;
   wire [31:0] dmi_reg_rdata;
   wire        dmi_hard_reset;

   axi_mem_wrapper
     #(.ID_WIDTH  (`RV_LSU_BUS_TAG+2),
       .MEM_SIZE  (RAM_SIZE),
       .INIT_FILE (ram_init_file))
   ram
     (.clk       (clk25),
      .rst_n     (~rst25),
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

   bscan_tap tap
     (.clk            (clk25),
      .rst            (rst25),
      .jtag_id        (31'd0),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_reg_en     (dmi_reg_en),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_hard_reset (dmi_hard_reset),
      .rd_status      (2'd0),
      .idle           (3'd0),
      .dmi_stat       (2'd0),
      .version        (4'd1));

   swervolf_core
     #(.bootrom_file (bootrom_file))
   swervolf
     (.clk  (clk25),
      .rstn (~rst25),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr ),
      .dmi_reg_en     (dmi_reg_en   ),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_hard_reset (dmi_hard_reset),
      .i_uart_rx      (i_uart_rx),
      .o_uart_tx      (o_uart_tx),
      .o_ram_awid     (ram_awid),
      .o_ram_awaddr   (ram_awaddr),
      .o_ram_awlen    (ram_awlen),
      .o_ram_awsize   (ram_awsize),
      .o_ram_awburst  (ram_awburst),
      .o_ram_awlock   (ram_awlock),
      .o_ram_awcache  (ram_awcache),
      .o_ram_awprot   (ram_awprot),
      .o_ram_awregion (ram_awregion),
      .o_ram_awqos    (ram_awqos),
      .o_ram_awvalid  (ram_awvalid),
      .i_ram_awready  (ram_awready),
      .o_ram_arid     (ram_arid),
      .o_ram_araddr   (ram_araddr),
      .o_ram_arlen    (ram_arlen),
      .o_ram_arsize   (ram_arsize),
      .o_ram_arburst  (ram_arburst),
      .o_ram_arlock   (ram_arlock),
      .o_ram_arcache  (ram_arcache),
      .o_ram_arprot   (ram_arprot),
      .o_ram_arregion (ram_arregion),
      .o_ram_arqos    (ram_arqos),
      .o_ram_arvalid  (ram_arvalid),
      .i_ram_arready  (ram_arready),
      .o_ram_wdata    (ram_wdata),
      .o_ram_wstrb    (ram_wstrb),
      .o_ram_wlast    (ram_wlast),
      .o_ram_wvalid   (ram_wvalid),
      .i_ram_wready   (ram_wready),
      .i_ram_bid      (ram_bid),
      .i_ram_bresp    (ram_bresp),
      .i_ram_bvalid   (ram_bvalid),
      .o_ram_bready   (ram_bready),
      .i_ram_rid      (ram_rid),
      .i_ram_rdata    (ram_rdata),
      .i_ram_rresp    (ram_rresp),
      .i_ram_rlast    (ram_rlast),
      .i_ram_rvalid   (ram_rvalid),
      .o_ram_rready   (ram_rready),
      .o_gpio (led0));

endmodule
