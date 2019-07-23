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
// Function: SweRVolf SoC-level controller
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_multicon
  #(parameter ID_WIDTH = 0)
   (input wire		  clk,
    input wire 		       rst_n,
    output reg 		       o_gpio,
    output reg 		       o_timer_irq,
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
   wire [7:0] 	 reg_be;
   wire [63:0] 	 reg_wdata;
   reg [63:0] 	 reg_rdata;

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
      .req_o  (),
      .we_o   (reg_we),
      .addr_o (reg_addr),
      .be_o   (reg_be),
      .data_o (reg_wdata),
      .data_i (reg_rdata));

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

`ifndef SWERVOLF_FPGA_VERSION_DIRTY
 `define SWERVOLF_FPGA_VERSION_DIRTY 1
`endif
`ifndef SWERVOLF_FPGA_VERSION_MAJOR
 `define SWERVOLF_FPGA_VERSION_MAJOR 255
`endif
`ifndef SWERVOLF_FPGA_VERSION_MINOR
 `define SWERVOLF_FPGA_VERSION_MINOR 255
`endif
`ifndef SWERVOLF_FPGA_VERSION_REV
 `define SWERVOLF_FPGA_VERSION_REV 255
`endif
`ifndef SWERVOLF_SHA
 `define SWERVOLF_SHA 32'hdeadbeef
`endif

   wire [31:0] version;

   assign version[31]    = `SWERVOLF_FPGA_VERSION_DIRTY;
   assign version[30:24] = 7'd0;
   assign version[23:16] = `SWERVOLF_FPGA_VERSION_MAJOR;
   assign version[15: 8] = `SWERVOLF_FPGA_VERSION_MINOR;
   assign version[ 7: 0] = `SWERVOLF_FPGA_VERSION_REV;

   localparam [2:0]
     REG_VERSION  = 3'd0,
     REG_SHA      = 3'd1,
     REG_SIMPRINT = 3'd4,
     REG_SIMEXIT  = 3'd5;
//0 = ver
   //4 = sha
   //8 = simprint
   //9 = simexit
   //10 = gpio
   //18 = timer/timecmp
   always @(posedge clk) begin
      if (reg_we)
	case (reg_addr[5:3])
`ifdef SIMPRINT
	  1: begin
	     if (reg_be[0]) begin
		$fwrite(f, "%c", reg_wdata[7:0]);
		$write("%c", reg_wdata[7:0]);
	     end
	     if (reg_be[1]) begin
		$display("Finito");
		$finish;
	     end
	  end
`endif
	  2 : o_gpio <= reg_wdata[0];
	  5 : begin
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
	0 : reg_rdata <= {`SWERVOLF_SHA, version};
	4 : reg_rdata <= mtime;
      endcase

      mtime <= mtime + 64'd1;
      o_timer_irq <= (mtime >= mtimecmp);
      if (!rst_n) begin
	 mtime <= 64'd0;
	 mtimecmp <= 64'd0;
      end
   end
endmodule
