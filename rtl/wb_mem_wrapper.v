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
// Function: Wrapper for on-chip memory instantiations
// Comments:
//
//********************************************************************************

`default_nettype none
module wb_mem_wrapper
  #(parameter MEM_SIZE = 0,
    parameter mem_clear = 0,
    parameter INIT_FILE = "")
  (
   input wire 			     i_clk,
   input wire 			     i_rst,
   input wire [$clog2(MEM_SIZE)-1:2] i_wb_adr,
   input wire [31:0] 		     i_wb_dat,
   input wire [3:0] 		     i_wb_sel,
   input wire 			     i_wb_we ,
   input wire 			     i_wb_cyc,
   input wire 			     i_wb_stb,
   output reg 			     o_wb_ack,
   output wire [31:0] 		     o_wb_rdt);

   wire [31:0] 	 mem_addr;
   wire [63:0] 	 mem_wdata;
   wire [63:0] 	 mem_rdata;

   wire [7:0] 	 mem_we;

   assign mem_we[3:0] = (i_wb_cyc & i_wb_stb & i_wb_we & !i_wb_adr[2]) ? i_wb_sel : 4'd0;
   assign mem_we[7:4] = (i_wb_cyc & i_wb_stb & i_wb_we &  i_wb_adr[2]) ? i_wb_sel : 4'd0;

   assign mem_wdata = {i_wb_dat, i_wb_dat};

   assign o_wb_rdt = i_wb_adr[2] ? mem_rdata[63:32] : mem_rdata[31:0];

   always @(posedge i_clk) begin
      o_wb_ack <= i_wb_cyc & i_wb_stb & !o_wb_ack;
      if (i_rst)
	o_wb_ack <= 1'b0;
   end

   dpram64
     #(.SIZE (MEM_SIZE),
       .mem_clear (mem_clear),
       .memfile (INIT_FILE))
   ram
     (.clk   (i_clk),
      .we    (mem_we),
      .din   (mem_wdata),
      .waddr ({i_wb_adr[$clog2(MEM_SIZE)-1:3],3'b000}),
      .raddr ({i_wb_adr[$clog2(MEM_SIZE)-1:3],3'b000}),
      .dout  (mem_rdata));

endmodule
