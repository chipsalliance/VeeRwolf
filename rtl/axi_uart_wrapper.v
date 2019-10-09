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
// Function: Wrapper for UART instantiation
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_uart_wrapper
  #(parameter ID_WIDTH = 0,
    parameter INIT_FILE = "")
  (input wire 		      clk,
   input wire 		      rst_n,

   input wire 		      i_uart_rx,
   output wire 		      o_uart_tx,
   output wire 		      o_uart_irq,
   input wire [ID_WIDTH-1:0]  i_awid,
   input wire [11:0] 	      i_awaddr,
   input wire [7:0] 	      i_awlen,
   input wire [2:0] 	      i_awsize,
   input wire [1:0] 	      i_awburst,
   input wire 		      i_awvalid,
   output wire 		      o_awready,

   input wire [ID_WIDTH-1:0]  i_arid,
   input wire [11:0] 	      i_araddr,
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

   wire [11:0] 		      paddr;
   wire [31:0] 		      pwdata;
   wire 		      pwrite;
   wire 		      psel;
   wire 		      penable;
   wire 		      pready;
   wire 		      pslverr;

   wire [7:0] 		      wb_rdt;

   axi2apb_64_32
     #(
       .AXI4_ADDRESS_WIDTH (12),
       .AXI4_ID_WIDTH    (ID_WIDTH),
       .AXI4_USER_WIDTH  (1),
       .BUFF_DEPTH_SLAVE (2))
   axi2apb_i
     (
      .ACLK       (clk),
      .ARESETn    (rst_n),
      .test_en_i  (1'b0),

      .AWID_i     (i_awid        ),
      .AWADDR_i   (i_awaddr      ),
      .AWLEN_i    (i_awlen       ),
      .AWSIZE_i   (i_awsize      ),
      .AWBURST_i  (i_awburst     ),
      .AWLOCK_i   (1'd0          ),
      .AWCACHE_i  (4'd0          ),
      .AWPROT_i   (3'd0          ),
      .AWREGION_i (4'd0          ),
      .AWUSER_i   (1'd0          ),
      .AWQOS_i    (4'd0          ),
      .AWVALID_i  (i_awvalid     ),
      .AWREADY_o  (o_awready     ),

      .WDATA_i    (i_wdata       ),
      .WSTRB_i    (i_wstrb       ),
      .WLAST_i    (i_wlast       ),
      .WUSER_i    (1'd0          ),
      .WVALID_i   (i_wvalid      ),
      .WREADY_o   (o_wready      ),

      .BID_o      (o_bid         ),
      .BRESP_o    (o_bresp       ),
      .BVALID_o   (o_bvalid      ),
      .BUSER_o    (              ),
      .BREADY_i   (i_bready      ),

      .ARID_i     (i_arid        ),
      .ARADDR_i   (i_araddr      ),
      .ARLEN_i    (i_arlen       ),
      .ARSIZE_i   (i_arsize      ),
      .ARBURST_i  (i_arburst     ),
      .ARLOCK_i   (1'd0          ),
      .ARCACHE_i  (4'd0          ),
      .ARPROT_i   (3'd0          ),
      .ARREGION_i (4'd0          ),
      .ARUSER_i   (1'd0          ),
      .ARQOS_i    (4'd0          ),
      .ARVALID_i  (i_arvalid     ),
      .ARREADY_o  (o_arready     ),

      .RID_o      (o_rid         ),
      .RDATA_o    (o_rdata       ),
      .RRESP_o    (o_rresp       ),
      .RLAST_o    (o_rlast       ),
      .RUSER_o    (              ),
      .RVALID_o   (o_rvalid      ),
      .RREADY_i   (i_rready      ),

      .PENABLE    (penable     ),
      .PWRITE     (pwrite      ),
      .PADDR      (paddr       ),
      .PSEL       (psel        ),
      .PWDATA     (pwdata      ),
      .PRDATA     ({24'd0,wb_rdt}),
      .PREADY     (pready      ),
      .PSLVERR    (pslverr     ));

   wire 		      wb_ack;
   assign pready = !penable | wb_ack;

   uart_top uart16550_0
     (
      // Wishbone slave interface
      .wb_clk_i	(clk),
      .wb_rst_i	(~rst_n),
      .wb_adr_i	(paddr[4:2]),
      .wb_dat_i	(pwdata[7:0]),
      .wb_we_i	(pwrite),
      .wb_cyc_i	(psel),
      .wb_stb_i	(penable),
      .wb_sel_i	(4'b0), // Not used in 8-bit mode
      .wb_dat_o	(wb_rdt),
      .wb_ack_o	(wb_ack),

      // Outputs
      .int_o     (o_uart_irq),
      .stx_pad_o (o_uart_tx),
      .rts_pad_o (),
      .dtr_pad_o (),

      // Inputs
      .srx_pad_i (i_uart_rx),
      .cts_pad_i (1'b0),
      .dsr_pad_i (1'b0),
      .ri_pad_i  (1'b0),
      .dcd_pad_i (1'b0));

endmodule
