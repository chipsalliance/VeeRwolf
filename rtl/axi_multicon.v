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
// Function: SweRVolf Wishbone subsystem
// Comments:
//
//********************************************************************************

`default_nettype none
module axi_multicon
  #(parameter ID_WIDTH = 0)
   (input wire		  clk,
    input wire 		      rst_n,
    input wire [63:0] 	      i_gpio,
    output wire [63:0] 	      o_gpio,
    output wire 	      o_sclk,
    output wire 	      o_cs_n,
    output wire 	      o_mosi,
    input wire 		      i_miso,
    output wire 	      o_spi0_irq,
    output wire 	      o_timer_irq,
    output wire 	      o_sw_irq3,
    output wire 	      o_sw_irq4,
    input wire 		      i_ram_init_done,
    input wire 		      i_ram_init_error,
    output wire [31:0] 	      o_nmi_vec,
    output wire 	      o_nmi_int,
    input wire [ID_WIDTH-1:0] i_awid,
    input wire [31:0] 	      i_awaddr,
    input wire [7:0] 	      i_awlen,
    input wire [2:0] 	      i_awsize,
    input wire [1:0] 	      i_awburst,
    input wire 		      i_awvalid,
    output wire 	      o_awready,

    input wire [ID_WIDTH-1:0] i_arid,
    input wire [31:0] 	      i_araddr,
    input wire [7:0] 	      i_arlen,
    input wire [2:0] 	      i_arsize,
    input wire [1:0] 	      i_arburst,
    input wire 		      i_arvalid,
    output wire 	      o_arready,

    input wire [63:0] 	      i_wdata,
    input wire [7:0] 	      i_wstrb,
    input wire 		      i_wlast,
    input wire 		      i_wvalid,
    output wire 	      o_wready,

    output reg [ID_WIDTH-1:0] o_bid,
    output wire [1:0] 	      o_bresp,
    output wire 	      o_bvalid,
    input wire 		      i_bready,

    output reg [ID_WIDTH-1:0] o_rid,
    output wire [63:0] 	      o_rdata,
    output wire [1:0] 	      o_rresp,
    output wire 	      o_rlast,
    output wire 	      o_rvalid,
    input wire 		      i_rready);

   wire 		       wb_clk = clk;
   wire 		       wb_rst = ~rst_n;

`include "wb_intercon.vh"

   assign o_rlast = 1'b1;

   always @(posedge clk)
     if (i_awvalid & o_awready)
       o_bid <= i_awid;

   always @(posedge clk)
     if (i_arvalid & o_arready)
       o_rid <= i_arid;

   wire [11:2] 		       wb_adr;

   assign		       wb_m2s_cpu_adr = {20'd0,wb_adr,2'b00};

   axi2wb axi2wb
     (
      .i_clk      (clk),
      .i_rst      (wb_rst),
      .o_wb_adr   (wb_adr),
      .o_wb_dat   (wb_m2s_cpu_dat),
      .o_wb_sel   (wb_m2s_cpu_sel),
      .o_wb_we    (wb_m2s_cpu_we),
      .o_wb_cyc   (wb_m2s_cpu_cyc),
      .o_wb_stb   (wb_m2s_cpu_stb),
      .i_wb_rdt   (wb_s2m_cpu_dat),
      .i_wb_ack   (wb_s2m_cpu_ack),
      .i_wb_err   (wb_s2m_cpu_err),

      .i_awaddr   (i_awaddr[11:0]),
      .i_awvalid  (i_awvalid),
      .o_awready  (o_awready),

      .i_araddr   (i_araddr[11:0]),
      .i_arvalid  (i_arvalid),
      .o_arready  (o_arready),

      .i_wdata   (i_wdata),
      .i_wstrb   (i_wstrb),
      .i_wvalid  (i_wvalid),
      .o_wready  (o_wready),

      .o_bvalid  (o_bvalid),
      .i_bready  (i_bready),

      .o_rdata   (o_rdata),
      .o_rvalid  (o_rvalid),
      .i_rready  (i_rready));

   swervolf_syscon syscon
     (.i_clk            (clk),
      .i_rst            (wb_rst),

      .i_gpio           (i_gpio),
      .o_gpio           (o_gpio),
      .o_timer_irq      (o_timer_irq),
      .o_sw_irq3        (o_sw_irq3),
      .o_sw_irq4        (o_sw_irq4),
      .i_ram_init_done  (i_ram_init_done),
      .i_ram_init_error (i_ram_init_error),
      .o_nmi_vec        (o_nmi_vec),
      .o_nmi_int        (o_nmi_int),

      .i_wb_adr         (wb_m2s_sys_adr[5:0]),
      .i_wb_dat         (wb_m2s_sys_dat),
      .i_wb_sel         (wb_m2s_sys_sel),
      .i_wb_we          (wb_m2s_sys_we),
      .i_wb_cyc         (wb_m2s_sys_cyc),
      .i_wb_stb         (wb_m2s_sys_stb),
      .o_wb_rdt         (wb_s2m_sys_dat),
      .o_wb_ack         (wb_s2m_sys_ack));


   wire [7:0] 		       spi_rdt;
   assign wb_s2m_spi_flash_dat = {24'd0,spi_rdt};

   simple_spi spi
     (// Wishbone slave interface
      .clk_i  (clk),
      .rst_i  (wb_rst),
      /* Note! Below is a horrible hack that needs some explanation

       The AXI bus is 64-bit and there is no support for telling the slave
       that it just wants to read a part of a 64-bit word.

       On the slave side, the SPI controller has an 8-bit databus.
       So in order to ensure that only one register gets accessed by the 64-bit
       master, the registers are placed 64 bits apart from each other, at
       addresses 0x0, 0x8, 0x10, 0x18 and 0x20 instead of the original 0x0, 0x1,
       0x2, 0x3 and 0x4. This works easy enough by just cutting of the three
       least significant bits of the address before passing it to the slave.

       Now, to complicate things, there is an wb2axi bridge that converts 64-bit
       datapath into 32 bits between the master and slave. Since the master
       can't indicate what part of the 64-bit word it actually wants to read,
       every 64-bit read gets turned into two consecutive 32-bit reads on the
       wishbone side.

       E.g. a read from address 0x8 on the 64-bit AXI side gets turned into two
       read operations from 0x8 and 0xc on the 32-bit Wishbone side.

       Usually this is not a real problem. Just a bit inefficient. But in this
       case we have the SPDR register that holds the incoming data. When we
       read a byte from that register, it is removed from the SPI FIFO and
       can't be read again. Now, if we read from this register two times, every
       time we just want to read a byte, this means that we throw away half of
       our received data and things break down.

       Writes are no problem since, there is a byte mask that tells which
       bytes to really write

       In order to work around this issue, we look at bit 2. Why? Because a
       64-bit read to any of the mapped registers (which are 64-bit aligned)
       will get turned into two read operations. First, one against the actual
       register, and then an additional read from address+4, i.e. address, but
       with bit 2 set as well. We still need to respond to the second read but
       it doesn't matter what data it contains since no one should look at it.

       So, when we see a read with bit 2 set, we redirect this access to
       register zero. Doesn't really matter which register as long as we pick
       a non-volatile one.

       TODO: Make something sensible here instead
       */
      .adr_i  (wb_m2s_spi_flash_adr[2] ? 3'd0 : wb_m2s_spi_flash_adr[5:3]),
      .dat_i  (wb_m2s_spi_flash_dat[7:0]),
      .we_i   (wb_m2s_spi_flash_we),
      .cyc_i  (wb_m2s_spi_flash_cyc),
      .stb_i  (wb_m2s_spi_flash_stb),
      .dat_o  (spi_rdt),
      .ack_o  (wb_s2m_spi_flash_ack),
      .inta_o (o_spi0_irq),
      // SPI interface
      .sck_o  (o_sclk),
      .ss_o   (o_cs_n),
      .mosi_o (o_mosi),
      .miso_i (i_miso));

endmodule
