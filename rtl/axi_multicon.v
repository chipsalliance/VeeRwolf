// SPDX-License-Identifier: Apache-2.0
// Copyright 2019-2020 Western Digital Corporation or its affiliates.
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
// Function: SweRVolf SoC-level controller
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_multicon
  #(parameter ID_WIDTH = 0)
   (input wire		  clk,
    input wire 		       rst_n,
    input wire [63:0] 	       i_gpio,
    output reg [63:0] 	       o_gpio,
    output wire 	       o_sclk,
    output wire 	       o_cs_n,
    output wire 	       o_mosi,
    input wire 		       i_miso,
    output wire 	       o_spi0_irq,
    output reg 		       o_timer_irq,
    output wire 	       o_sw_irq3,
    output wire 	       o_sw_irq4,
    input wire 		       i_ram_init_done,
    input wire 		       i_ram_init_error,
    input wire [ID_WIDTH-1:0]  i_awid,
    input wire [31:0] 	       i_awaddr,
    input wire [7:0] 	       i_awlen,
    input wire [2:0] 	       i_awsize,
    input wire [1:0] 	       i_awburst,
    input wire 		       i_awvalid,
    output wire 	       o_awready,

    input wire [ID_WIDTH-1:0]  i_arid,
    input wire [31:0] 	       i_araddr,
    input wire [7:0] 	       i_arlen,
    input wire [2:0] 	       i_arsize,
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

   wire 	 reg_we;
   wire [31:0] 	 reg_addr;
   wire 	 reg_req;
   wire [7:0] 	 reg_be;
   wire [63:0] 	 reg_wdata;
   reg [63:0] 	 reg_rdata;
   wire [63:0] 	 rdata;
   wire [7:0] 	 spi_rdt;

   wire [2:0] 	 wb_spi_adr;
   wire [7:0] 	 wb_spi_dat;
   wire 	 wb_spi_cyc;

   wire [2:0] 	 spi_adr;
   reg [2:0] 	 spi_adr_r;
   reg [7:0] 	 wb_spi_dat_r;
   reg 		 reg_we_r;
   reg 		 wb_spi_cyc_r;

   reg 		 sw_irq3;
   reg 		 sw_irq3_edge;
   reg 		 sw_irq3_pol;
   reg 		 sw_irq4;
   reg 		 sw_irq4_edge;
   reg 		 sw_irq4_pol;

   AXI_BUS #(32, 64, ID_WIDTH, 1) slave();

   assign slave.aw_id    = i_awid   ;
   assign slave.aw_addr  = i_awaddr ;
   assign slave.aw_len   = i_awlen  ;
   assign slave.aw_size  = i_awsize ;
   assign slave.aw_burst = i_awburst;
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

   axi2mem
     #(.AXI_ID_WIDTH   (ID_WIDTH),
       .AXI_ADDR_WIDTH (32),
       .AXI_DATA_WIDTH (64),
       .AXI_USER_WIDTH (0))
   ram_axi2mem
     (.clk_i  (clk),
      .rst_ni (rst_n),
      .slave  (slave),
      .req_o  (reg_req),
      .we_o   (reg_we),
      .addr_o (reg_addr),
      .be_o   (reg_be),
      .data_o (reg_wdata),
      .data_i (rdata));

   reg [63:0] 	 mtime;
   reg [63:0] 	 mtimecmp;
`ifdef SIMPRINT
   reg [1023:0]  signature_file;
   integer 	f = 0;
   initial begin
      if ($value$plusargs("signature=%s", signature_file)) begin
	 $display("Writing signature to %0s", signature_file);
	 f = $fopen(signature_file, "w");
      end
   end
`endif

`ifndef VERSION_DIRTY
 `define VERSION_DIRTY 1
`endif
`ifndef VERSION_MAJOR
 `define VERSION_MAJOR 255
`endif
`ifndef VERSION_MINOR
 `define VERSION_MINOR 255
`endif
`ifndef VERSION_REV
 `define VERSION_REV 255
`endif
`ifndef VERSION_SHA
 `define VERSION_SHA deadbeef
`endif

   wire [31:0] version;

   assign version[31]    = `VERSION_DIRTY;
   assign version[30:24] = 7'd0;
   assign version[23:16] = `VERSION_MAJOR;
   assign version[15: 8] = `VERSION_MINOR;
   assign version[ 7: 0] = `VERSION_REV;

   assign o_sw_irq4 = sw_irq4^sw_irq4_pol;
   assign o_sw_irq3 = sw_irq3^sw_irq3_pol;

   //00 = ver
   //04 = sha
   //08 = simprint
   //09 = simexit
   //0A = RAM status
   //0B = sw_irq
   //10 = gpio
   //20 = timer/timecmp
   //40 = SPI
   always @(posedge clk) begin
      if (sw_irq3_edge)
	sw_irq3 <= 1'b0;
      if (sw_irq4_edge)
	sw_irq4 <= 1'b0;

      if (reg_we & !reg_addr[6])
	case (reg_addr[5:3])
	  1: begin
`ifdef SIMPRINT
	     if (reg_be[0]) begin
		$fwrite(f, "%c", reg_wdata[7:0]);
		$write("%c", reg_wdata[7:0]);
	     end
	     if (reg_be[1]) begin
		$display("\nFinito");
		$finish;
	     end
`endif
	     if (reg_be[3]) begin
		sw_irq4      <= reg_wdata[31];
		sw_irq4_edge <= reg_wdata[30];
		sw_irq4_pol  <= reg_wdata[29];
		sw_irq3      <= reg_wdata[27];
		sw_irq3_edge <= reg_wdata[26];
		sw_irq3_pol  <= reg_wdata[25];
	     end
	  end
	  2 : begin //0x10-0x17
	     if (reg_be[0]) o_gpio[7:0]   <= reg_wdata[7:0]  ;
	     if (reg_be[1]) o_gpio[15:8]  <= reg_wdata[15:8] ;
	     if (reg_be[2]) o_gpio[23:16] <= reg_wdata[23:16];
	     if (reg_be[3]) o_gpio[31:24] <= reg_wdata[31:24];
	     if (reg_be[4]) o_gpio[39:32] <= reg_wdata[39:32];
	     if (reg_be[5]) o_gpio[47:40] <= reg_wdata[47:40];
	     if (reg_be[6]) o_gpio[55:48] <= reg_wdata[55:48];
	     if (reg_be[7]) o_gpio[63:56] <= reg_wdata[63:56];
	  end
	  5 : begin //0x28-0x2f
	     if (reg_be[0]) mtimecmp[7:0]   <= reg_wdata[7:0]  ;
	     if (reg_be[1]) mtimecmp[15:8]  <= reg_wdata[15:8] ;
	     if (reg_be[2]) mtimecmp[23:16] <= reg_wdata[23:16];
	     if (reg_be[3]) mtimecmp[31:24] <= reg_wdata[31:24];
	     if (reg_be[4]) mtimecmp[39:32] <= reg_wdata[39:32];
	     if (reg_be[5]) mtimecmp[47:40] <= reg_wdata[47:40];
	     if (reg_be[6]) mtimecmp[55:48] <= reg_wdata[55:48];
	     if (reg_be[7]) mtimecmp[63:56] <= reg_wdata[63:56];
	  end
	endcase

      case (reg_addr[5:3])
	//0x00-0x07
	0 : reg_rdata <= {32'h`VERSION_SHA, version};
	//0x08-0x0F
	1 : begin
	   reg_rdata <= 64'd0;
	   //0xB
	   reg_rdata[31:29] <= {sw_irq4, sw_irq4_edge, sw_irq4_pol};
	   reg_rdata[27:25] <= {sw_irq3, sw_irq3_edge, sw_irq3_pol};
	   //0xA
	   reg_rdata[17:16] <= {i_ram_init_error, i_ram_init_done};
	end
	//0x10-0x17
	2 : reg_rdata <= i_gpio;
	//0x20-0x27
	4 : reg_rdata <= mtime;
	//0x28-0x2F
	5 : reg_rdata <= mtimecmp;
      endcase

      mtime <= mtime + 64'd1;
      o_timer_irq <= (mtime >= mtimecmp);
      spi_adr_r <= spi_adr;
      wb_spi_dat_r <= wb_spi_dat;
      reg_we_r <= reg_we;
      wb_spi_cyc_r <= wb_spi_cyc;

      if (!rst_n) begin
	 mtime <= 64'd0;
	 mtimecmp <= 64'd0;
      end
   end

   wire [7:0] wb_spi_rdt;

   assign rdata = reg_addr[6] ? {8{wb_spi_rdt}} : reg_rdata;

   assign spi_adr = reg_addr[5:3];

   assign wb_spi_adr = reg_req ? spi_adr : spi_adr_r;
   assign wb_spi_dat = !reg_req ? wb_spi_dat_r : reg_wdata[7:0];

   assign wb_spi_cyc = reg_req & reg_addr[6];

   simple_spi spi
     (// Wishbone slave interface
      .clk_i  (clk),
      .rst_i  (~rst_n),
      .adr_i  (wb_spi_adr),
      .dat_i  (wb_spi_dat),
      .we_i   (reg_we | reg_we_r),
      .cyc_i  (wb_spi_cyc | wb_spi_cyc_r),
      .stb_i  (wb_spi_cyc | wb_spi_cyc_r),
      .dat_o  (wb_spi_rdt),
      .ack_o  (),
      .inta_o (o_spi0_irq),
      // SPI interface
      .sck_o  (o_sclk),
      .ss_o   (o_cs_n),
      .mosi_o (o_mosi),
      .miso_i (i_miso));

endmodule
