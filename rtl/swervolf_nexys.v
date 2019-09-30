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
  #(parameter bootrom_file = "spi_uimage_loader.vh")
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
    input wire 	       sw0,
    output wire        o_flash_cs_n,
    output wire        o_flash_mosi,
    input wire 	       i_flash_miso,
    output wire        o_sd_sclk,
    output wire        o_sd_cs_n,
    output wire        o_sd_mosi,
    input wire 	       i_sd_miso,
    input wire 	       i_uart_rx,
    output wire        o_uart_tx,
    output wire        o_phy_clk,
    output wire	       o_phy_rstn, 
    inout wire 	       io_ethmac_md,
    output wire        o_ethmac_mdc,
    input wire [1:0]   i_rmii_rxd,
    input wire 	       i_rmii_rxerr,
    output wire [1:0]  o_rmii_txd,
    output wire        o_rmii_txen,
    input wire 	       i_rmii_crsdv,
    output wire        led0);

   wire [3:0]	       ethmac_mtxd;
   wire 	       ethmac_mtxen;
   wire 	       ethmac_mtxerr;
   wire 	       ethmac_mrx_clk;
   wire 	       ethmac_mtx_clk;
   wire [3:0]	       ethmac_mrxd;
   wire 	       ethmac_mrxdv;
   wire 	       ethmac_mrxerr;
   wire 	       ethmac_mcoll;
   wire 	       ethmac_mcrs;

   wire                ethmac_mdi;
   wire                ethmac_mdo;
   wire                ethmac_mdoe;

   assign io_ethmac_md = ethmac_mdoe ? ethmac_mdo : 1'bz;
   assign ethmac_mdi = io_ethmac_md;


   wire 	       cpu_tx,litedram_tx;

   wire 	       litedram_init_done;
   wire 	       litedram_init_error;

   localparam RAM_SIZE     = 32'h10000;

   wire 	 clk_core;
   wire 	 rst_core;
   wire 	 clk50;
   wire 	 rst50;
   wire 	 user_clk;
   wire 	 user_rst;

   assign o_phy_clk = clk50;
   assign o_phy_rstn = ~rst50;   
   
   clk_gen_nexys clk_gen
     (.i_clk (user_clk),
      .i_rst (user_rst),
      .o_clk_core (clk_core),
      .o_rst_core (rst_core),
      .o_clk50 (clk50),
      .o_rst50 (rst50));

   AXI_BUS #(32, 64, 6, 1) mem();
   AXI_BUS #(32, 64, 6, 1) cpu();

   assign cpu.aw_atop = 6'd0;
   assign cpu.aw_user = 1'b0;
   assign cpu.ar_user = 1'b0;
   assign cpu.w_user = 1'b0;
   assign cpu.b_user = 1'b0;
   assign cpu.r_user = 1'b0;

   axi_cdc
     #(.AXI_USER_WIDTH (1),
       .AXI_ID_WIDTH   (6))
   cdc
     (
      .clk_slave_i   (clk_core),
      .rst_slave_ni  (~rst_core),
      .axi_slave     (cpu),
      .isolate_slave_i    (1'b0),
      .test_cgbypass_i    (1'b0),

      .clk_master_i   (user_clk),
      .rst_master_ni  (~user_rst),
      .axi_master     (mem),
      .isolate_master_i     (1'b0),
      .clock_down_master_i  (1'b0));

   litedram_top
     #(.ID_WIDTH (6))
   ddr2
     (.serial_tx   (litedram_tx),
      .serial_rx   (i_uart_rx),
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
      .init_done  (litedram_init_done),
      .init_error (litedram_init_error),
      .i_awid    (mem.aw_id   ),
      .i_awaddr  (mem.aw_addr[26:0] ),
      .i_awlen   (mem.aw_len  ),
      .i_awsize  ({1'b0,mem.aw_size} ),
      .i_awburst (mem.aw_burst),
      .i_awvalid (mem.aw_valid),
      .o_awready (mem.aw_ready),
      .i_arid    (mem.ar_id   ),
      .i_araddr  (mem.ar_addr[26:0] ),
      .i_arlen   (mem.ar_len  ),
      .i_arsize  ({1'b0,mem.ar_size} ),
      .i_arburst (mem.ar_burst),
      .i_arvalid (mem.ar_valid),
      .o_arready (mem.ar_ready),
      .i_wdata   (mem.w_data  ),
      .i_wstrb   (mem.w_strb  ),
      .i_wlast   (mem.w_last  ),
      .i_wvalid  (mem.w_valid ),
      .o_wready  (mem.w_ready ),
      .o_bid     (mem.b_id    ),
      .o_bresp   (mem.b_resp  ),
      .o_bvalid  (mem.b_valid ),
      .i_bready  (mem.b_ready ),
      .o_rid     (mem.r_id    ),
      .o_rdata   (mem.r_data  ),
      .o_rresp   (mem.r_resp  ),
      .o_rlast   (mem.r_last  ),
      .o_rvalid  (mem.r_valid ),
      .i_rready  (mem.r_ready ));

   wire        dmi_reg_en;
   wire [6:0]  dmi_reg_addr;
   wire        dmi_reg_wr_en;
   wire [31:0] dmi_reg_wdata;
   wire [31:0] dmi_reg_rdata;
   wire        dmi_hard_reset;

   wire        flash_sclk;

   STARTUPE2 STARTUPE2
     (
      .CFGCLK    (),
      .CFGMCLK   (),
      .EOS       (),
      .PREQ      (),
      .CLK       (1'b0),
      .GSR       (1'b0),
      .GTS       (1'b0),
      .KEYCLEARB (1'b1),
      .PACK      (1'b0),
      .USRCCLKO  (flash_sclk),
      .USRCCLKTS (1'b0),
      .USRDONEO  (1'b1),
      .USRDONETS (1'b0));

   bscan_tap tap
     (.clk            (clk_core),
      .rst            (rst_core),
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


   mii_to_rmii_0
     mii_to_rmii_0_inst
       (	
        .rst_n (~rst50),
	.ref_clk (clk50), 
	.mac2rmii_tx_en (ethmac_mtxen),   
	.mac2rmii_txd   (ethmac_mtxd),  
	.mac2rmii_tx_er  (ethmac_mtxerr),
	.rmii2mac_tx_clk (ethmac_mtx_clk),		
	.rmii2mac_rx_clk (ethmac_mrx_clk),   
	.rmii2mac_col  (ethmac_mcoll),  
	.rmii2mac_crs (ethmac_mcrs),       
	.rmii2mac_rx_dv (ethmac_mrxdv), 
	.rmii2mac_rx_er (ethmac_mrxerr),  
	.rmii2mac_rxd (ethmac_mrxd),
        .phy2rmii_crs_dv (i_rmii_crsdv), 
	.phy2rmii_rx_er (i_rmii_rxerr), 
	.phy2rmii_rxd (i_rmii_rxd),     
	.rmii2phy_txd (o_rmii_txd),     
	.rmii2phy_tx_en (o_rmii_txen)    
	);

      
   swervolf_core
     #(.bootrom_file (bootrom_file))
   swervolf
     (.clk  (clk_core),
      .rstn (~rst_core),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr ),
      .dmi_reg_en     (dmi_reg_en   ),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_hard_reset (dmi_hard_reset),
      .o_flash_sclk   (flash_sclk),
      .o_flash_cs_n   (o_flash_cs_n),
      .o_flash_mosi   (o_flash_mosi),
      .i_flash_miso   (i_flash_miso),
      .o_sd_sclk      (o_sd_sclk),
      .o_sd_cs_n      (o_sd_cs_n),
      .o_sd_mosi      (o_sd_mosi),
      .i_sd_miso      (i_sd_miso),
      .i_uart_rx      (i_uart_rx),
      .o_uart_tx      (cpu_tx),
      .i_ethmac_mtx_clk (ethmac_mtx_clk),
      .o_ethmac_mtxd    (ethmac_mtxd),
      .o_ethmac_mtxen   (ethmac_mtxen),
      .o_ethmac_mtxerr  (ethmac_mtxerr),
      .i_ethmac_mrx_clk (ethmac_mrx_clk),
      .i_ethmac_mrxd    (ethmac_mrxd),
      .i_ethmac_mrxdv   (ethmac_mrxdv),
      .i_ethmac_mrxerr  (ethmac_mrxerr),
      .i_ethmac_mcoll   (ethmac_mcoll),
      .i_ethmac_mcrs    (ethmac_mcrs),
      .o_ethmac_mdc     (o_ethmac_mdc),
      .i_ethmac_md      (ethmac_mdi), 
      .o_ethmac_md      (ethmac_mdo), 
      .o_ethmac_mdoe    (ethmac_mdoe),
      .o_ram_awid     (cpu.aw_id),
      .o_ram_awaddr   (cpu.aw_addr),
      .o_ram_awlen    (cpu.aw_len),
      .o_ram_awsize   (cpu.aw_size),
      .o_ram_awburst  (cpu.aw_burst),
      .o_ram_awlock   (cpu.aw_lock),
      .o_ram_awcache  (cpu.aw_cache),
      .o_ram_awprot   (cpu.aw_prot),
      .o_ram_awregion (cpu.aw_region),
      .o_ram_awqos    (cpu.aw_qos),
      .o_ram_awvalid  (cpu.aw_valid),
      .i_ram_awready  (cpu.aw_ready),
      .o_ram_arid     (cpu.ar_id),
      .o_ram_araddr   (cpu.ar_addr),
      .o_ram_arlen    (cpu.ar_len),
      .o_ram_arsize   (cpu.ar_size),
      .o_ram_arburst  (cpu.ar_burst),
      .o_ram_arlock   (cpu.ar_lock),
      .o_ram_arcache  (cpu.ar_cache),
      .o_ram_arprot   (cpu.ar_prot),
      .o_ram_arregion (cpu.ar_region),
      .o_ram_arqos    (cpu.ar_qos),
      .o_ram_arvalid  (cpu.ar_valid),
      .i_ram_arready  (cpu.ar_ready),
      .o_ram_wdata    (cpu.w_data),
      .o_ram_wstrb    (cpu.w_strb),
      .o_ram_wlast    (cpu.w_last),
      .o_ram_wvalid   (cpu.w_valid),
      .i_ram_wready   (cpu.w_ready),
      .i_ram_bid      (cpu.b_id),
      .i_ram_bresp    (cpu.b_resp),
      .i_ram_bvalid   (cpu.b_valid),
      .o_ram_bready   (cpu.b_ready),
      .i_ram_rid      (cpu.r_id),
      .i_ram_rdata    (cpu.r_data),
      .i_ram_rresp    (cpu.r_resp),
      .i_ram_rlast    (cpu.r_last),
      .i_ram_rvalid   (cpu.r_valid),
      .o_ram_rready   (cpu.r_ready),
      .i_ram_init_done  (litedram_init_done),
      .i_ram_init_error (litedram_init_error),
      .o_gpio           (led0_int));

   always @(posedge clk_core) begin
      led0 <= led0_int_r;
      led0_int_r <= led0_int;
   end

   assign o_uart_tx = sw0 ? litedram_tx : cpu_tx;

endmodule
