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
// Function: Wrapper for simulated SD card
// Comments:
//
//********************************************************************************

`default_nettype none
module sd_card
  #(parameter sd_card_size = 0)
   (input wire 	     i_clk,
    input wire 	     i_rst,
    input wire 	     i_sd_clk,
    inout wire 	     io_sd_cmd,
    inout wire [3:0] io_sd_dat);

   localparam aw = $clog2(sd_card_size);

   wire        sd_cmd_o;
   wire        sd_cmd_t;
   wire [3:0]  sd_dat_o;
   wire [3:0]  sd_dat_t;

   wire [31:0] wb_adr;
   wire [31:0] wb_dat;
   wire [3:0]  wb_sel;
   wire        wb_we ;
   wire        wb_cyc;
   wire        wb_stb;
   reg [31:0]  wb_rdt;
   reg 	       wb_ack;

   assign io_sd_cmd = sd_cmd_t ? 1'bz : sd_cmd_o;
   assign io_sd_dat[0] = sd_dat_t[0] ? 1'bz : sd_dat_o[0];
   assign io_sd_dat[1] = sd_dat_t[1] ? 1'bz : sd_dat_o[1];
   assign io_sd_dat[2] = sd_dat_t[2] ? 1'bz : sd_dat_o[2];
   assign io_sd_dat[3] = sd_dat_t[3] ? 1'bz : sd_dat_o[3];

   sd_top
     #(
       .CSD_C_SIZE (4112)) //Minimum legal size for Zephyr FAT
   sd_device
     (
      .clk_50 (i_clk),
      .clk_100 (1'b0),
      .clk_200 (1'b0),
      .reset_n (!i_rst),
      // physical interface to SD pins
      .sd_clk   (i_sd_clk),
      .sd_cmd_i (io_sd_cmd),
      .sd_cmd_o (sd_cmd_o),
      .sd_cmd_t (sd_cmd_t),
      .sd_dat_i (io_sd_dat),
      .sd_dat_o (sd_dat_o),
      .sd_dat_t (sd_dat_t),
	  
      // wishbone interface
      .wbm_clk_o (),
      .wbm_adr_o (wb_adr),
      .wbm_dat_o (wb_dat),
      .wbm_sel_o (wb_sel),
      .wbm_we_o  (wb_we ),
      .wbm_cyc_o (wb_cyc),
      .wbm_stb_o (wb_stb),
      .wbm_cti_o (),
      .wbm_bte_o (),
      .wbm_dat_i (wb_rdt),
      .wbm_ack_i (wb_ack),
      // options
      .opt_enable_hs (1'b0));


   reg [7:0] 	       mem [0:sd_card_size-1] /* verilator public */;
   wire [aw-1:0]       addr = {wb_adr[aw-1:2],2'b00};
   wire [3:0] 	       we = {4{wb_we & wb_cyc & wb_stb}};

   always@(posedge i_clk)
     wb_ack <= wb_cyc & wb_stb & !wb_ack;

   always @(posedge i_clk) begin
      if (we[0]) mem[addr+0] <= wb_dat[7:0];
      if (we[1]) mem[addr+1] <= wb_dat[15:8];
      if (we[2]) mem[addr+2] <= wb_dat[23:16];
      if (we[3]) mem[addr+3] <= wb_dat[31:24];
      wb_rdt <= {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr+0]};
   end
endmodule
