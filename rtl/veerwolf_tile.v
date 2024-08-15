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
// Function: VeeRwolf processor core with memory board
// Comments:
//
//********************************************************************************

`default_nettype none
module veerwolf_tile
  #(parameter bootrom_file = "bootloader.vh",
    parameter cpu_type = "EH1")
   (input wire 	       clk_core,
    input wire         rst_core,
    input wire 	       i_uart_rx,
    output wire        o_uart_tx,
    input wire [15:0]  i_sw,
    output reg [15:0]  o_led);

   wire [63:0] 	       gpio_out;
   reg [15:0] 	       led_int_r;

   reg [15:0] 	       sw_r;
   reg [15:0] 	       sw_2r;

   localparam RAM_SIZE     = 32'h10000;

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

   axi_ram
     #(.DATA_WIDTH (64),
       .ADDR_WIDTH ($clog2(RAM_SIZE)),
       .ID_WIDTH  (`RV_LSU_BUS_TAG+3))
   ram
     (.clk       (clk_core),
      .rst       (rst_core),
      .s_axi_awid    (ram_awid),
      .s_axi_awaddr  (ram_awaddr[$clog2(RAM_SIZE)-1:0]),
      .s_axi_awlen   (ram_awlen),
      .s_axi_awsize  (ram_awsize),
      .s_axi_awburst (ram_awburst),
      .s_axi_awlock  (1'd0),
      .s_axi_awcache (4'd0),
      .s_axi_awprot  (3'd0),
      .s_axi_awvalid (ram_awvalid),
      .s_axi_awready (ram_awready),

      .s_axi_arid    (ram_arid),
      .s_axi_araddr  (ram_araddr[$clog2(RAM_SIZE)-1:0]),
      .s_axi_arlen   (ram_arlen),
      .s_axi_arsize  (ram_arsize),
      .s_axi_arburst (ram_arburst),
      .s_axi_arlock  (1'd0),
      .s_axi_arcache (4'd0),
      .s_axi_arprot  (3'd0),
      .s_axi_arvalid (ram_arvalid),
      .s_axi_arready (ram_arready),

      .s_axi_wdata  (ram_wdata),
      .s_axi_wstrb  (ram_wstrb),
      .s_axi_wlast  (ram_wlast),
      .s_axi_wvalid (ram_wvalid),
      .s_axi_wready (ram_wready),

      .s_axi_bid    (ram_bid),
      .s_axi_bresp  (ram_bresp),
      .s_axi_bvalid (ram_bvalid),
      .s_axi_bready (ram_bready),

      .s_axi_rid    (ram_rid),
      .s_axi_rdata  (ram_rdata),
      .s_axi_rresp  (ram_rresp),
      .s_axi_rlast  (ram_rlast),
      .s_axi_rvalid (ram_rvalid),
      .s_axi_rready (ram_rready));

   veerwolf_nospi
     #(.bootrom_file (bootrom_file),
       .clk_freq_hz  ((cpu_type == "EL2") ? 32'd25_000_000 : 32'd50_000_000))
   veerwolf
     (.clk  (clk_core),
      .rstn (~rst_core),
      .dmi_reg_rdata       (),
      .dmi_reg_wdata       (32'd0),
      .dmi_reg_addr        (7'd0),
      .dmi_reg_en          (1'b0),
      .dmi_reg_wr_en       (1'b0),
      .dmi_hard_reset      (1'b0),
      .i_uart_rx           (i_uart_rx),
      .o_uart_tx           (o_uart_tx),
      .o_ram_awid          (ram_awid),
      .o_ram_awaddr        (ram_awaddr),
      .o_ram_awlen         (ram_awlen),
      .o_ram_awsize        (ram_awsize),
      .o_ram_awburst       (ram_awburst),
      .o_ram_awlock        (ram_awlock),
      .o_ram_awcache       (ram_awcache),
      .o_ram_awprot        (ram_awprot),
      .o_ram_awregion      (ram_awregion),
      .o_ram_awqos         (ram_awqos),
      .o_ram_awvalid       (ram_awvalid),
      .i_ram_awready       (ram_awready),
      .o_ram_arid          (ram_arid),
      .o_ram_araddr        (ram_araddr),
      .o_ram_arlen         (ram_arlen),
      .o_ram_arsize        (ram_arsize),
      .o_ram_arburst       (ram_arburst),
      .o_ram_arlock        (ram_arlock),
      .o_ram_arcache       (ram_arcache),
      .o_ram_arprot        (ram_arprot),
      .o_ram_arregion      (ram_arregion),
      .o_ram_arqos         (ram_arqos),
      .o_ram_arvalid       (ram_arvalid),
      .i_ram_arready       (ram_arready),
      .o_ram_wdata         (ram_wdata),
      .o_ram_wstrb         (ram_wstrb),
      .o_ram_wlast         (ram_wlast),
      .o_ram_wvalid        (ram_wvalid),
      .i_ram_wready        (ram_wready),
      .i_ram_bid           (ram_bid),
      .i_ram_bresp         (ram_bresp),
      .i_ram_bvalid        (ram_bvalid),
      .o_ram_bready        (ram_bready),
      .i_ram_rid           (ram_rid),
      .i_ram_rdata         (ram_rdata),
      .i_ram_rresp         (ram_rresp),
      .i_ram_rlast         (ram_rlast),
      .i_ram_rvalid        (ram_rvalid),
      .o_ram_rready        (ram_rready),
      .i_ram_init_done     (1'b1),
      .i_ram_init_error    (1'b0),
      .i_gpio              ({32'd0,16'd0,sw_2r}),
      .o_gpio              (gpio_out));

   always @(posedge clk_core) begin
      o_led <= led_int_r;
      led_int_r <= gpio_out[31:16];
      sw_r <= i_sw;
      sw_2r <= sw_r;
   end

endmodule
