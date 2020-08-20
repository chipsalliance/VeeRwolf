// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 Western Digital Corporation or its affiliates.
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
// Function: Top wrapper file with el2_swerv/mem instantiated inside
// Comments:
//
//********************************************************************************
`default_nettype wire
module swerv_wrapper_dmi
import el2_pkg::*;
 #(
`include "el2_param.vh"
)
(
   input logic                             clk,
   input logic                             rst_l,
   input logic                             dbg_rst_l,
   input logic [31:1]                      rst_vec,
   input logic                             nmi_int,
   input logic [31:1]                      nmi_vec,


   output logic [31:0]                     trace_rv_i_insn_ip,
   output logic [31:0]                     trace_rv_i_address_ip,
   output logic [1:0]                      trace_rv_i_valid_ip,
   output logic [1:0]                      trace_rv_i_exception_ip,
   output logic [4:0]                      trace_rv_i_ecause_ip,
   output logic [1:0]                      trace_rv_i_interrupt_ip,
   output logic [31:0]                     trace_rv_i_tval_ip,

   // Bus signals

   //-------------------------- LSU AXI signals--------------------------
   // AXI Write Channels
   output logic                            lsu_axi_awvalid,
   input  logic                            lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_awid,
   output logic [31:0]                     lsu_axi_awaddr,
   output logic [3:0]                      lsu_axi_awregion,
   output logic [7:0]                      lsu_axi_awlen,
   output logic [2:0]                      lsu_axi_awsize,
   output logic [1:0]                      lsu_axi_awburst,
   output logic                            lsu_axi_awlock,
   output logic [3:0]                      lsu_axi_awcache,
   output logic [2:0]                      lsu_axi_awprot,
   output logic [3:0]                      lsu_axi_awqos,

   output logic                            lsu_axi_wvalid,
   input  logic                            lsu_axi_wready,
   output logic [63:0]                     lsu_axi_wdata,
   output logic [7:0]                      lsu_axi_wstrb,
   output logic                            lsu_axi_wlast,

   input  logic                            lsu_axi_bvalid,
   output logic                            lsu_axi_bready,
   input  logic [1:0]                      lsu_axi_bresp,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_bid,

   // AXI Read Channels
   output logic                            lsu_axi_arvalid,
   input  logic                            lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_arid,
   output logic [31:0]                     lsu_axi_araddr,
   output logic [3:0]                      lsu_axi_arregion,
   output logic [7:0]                      lsu_axi_arlen,
   output logic [2:0]                      lsu_axi_arsize,
   output logic [1:0]                      lsu_axi_arburst,
   output logic                            lsu_axi_arlock,
   output logic [3:0]                      lsu_axi_arcache,
   output logic [2:0]                      lsu_axi_arprot,
   output logic [3:0]                      lsu_axi_arqos,

   input  logic                            lsu_axi_rvalid,
   output logic                            lsu_axi_rready,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_rid,
   input  logic [63:0]                     lsu_axi_rdata,
   input  logic [1:0]                      lsu_axi_rresp,
   input  logic                            lsu_axi_rlast,

   //-------------------------- IFU AXI signals--------------------------
   // AXI Write Channels
   output logic                            ifu_axi_awvalid,
   input  logic                            ifu_axi_awready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_awid,
   output logic [31:0]                     ifu_axi_awaddr,
   output logic [3:0]                      ifu_axi_awregion,
   output logic [7:0]                      ifu_axi_awlen,
   output logic [2:0]                      ifu_axi_awsize,
   output logic [1:0]                      ifu_axi_awburst,
   output logic                            ifu_axi_awlock,
   output logic [3:0]                      ifu_axi_awcache,
   output logic [2:0]                      ifu_axi_awprot,
   output logic [3:0]                      ifu_axi_awqos,

   output logic                            ifu_axi_wvalid,
   input  logic                            ifu_axi_wready,
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   input  logic                            ifu_axi_bvalid,
   output logic                            ifu_axi_bready,
   input  logic [1:0]                      ifu_axi_bresp,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_bid,

   // AXI Read Channels
   output logic                            ifu_axi_arvalid,
   input  logic                            ifu_axi_arready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_arid,
   output logic [31:0]                     ifu_axi_araddr,
   output logic [3:0]                      ifu_axi_arregion,
   output logic [7:0]                      ifu_axi_arlen,
   output logic [2:0]                      ifu_axi_arsize,
   output logic [1:0]                      ifu_axi_arburst,
   output logic                            ifu_axi_arlock,
   output logic [3:0]                      ifu_axi_arcache,
   output logic [2:0]                      ifu_axi_arprot,
   output logic [3:0]                      ifu_axi_arqos,

   input  logic                            ifu_axi_rvalid,
   output logic                            ifu_axi_rready,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_rid,
   input  logic [63:0]                     ifu_axi_rdata,
   input  logic [1:0]                      ifu_axi_rresp,
   input  logic                            ifu_axi_rlast,

   //-------------------------- SB AXI signals--------------------------
   // AXI Write Channels
   output logic                            sb_axi_awvalid,
   input  logic                            sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_awid,
   output logic [31:0]                     sb_axi_awaddr,
   output logic [3:0]                      sb_axi_awregion,
   output logic [7:0]                      sb_axi_awlen,
   output logic [2:0]                      sb_axi_awsize,
   output logic [1:0]                      sb_axi_awburst,
   output logic                            sb_axi_awlock,
   output logic [3:0]                      sb_axi_awcache,
   output logic [2:0]                      sb_axi_awprot,
   output logic [3:0]                      sb_axi_awqos,

   output logic                            sb_axi_wvalid,
   input  logic                            sb_axi_wready,
   output logic [63:0]                     sb_axi_wdata,
   output logic [7:0]                      sb_axi_wstrb,
   output logic                            sb_axi_wlast,

   input  logic                            sb_axi_bvalid,
   output logic                            sb_axi_bready,
   input  logic [1:0]                      sb_axi_bresp,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_bid,

   // AXI Read Channels
   output logic                            sb_axi_arvalid,
   input  logic                            sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_arid,
   output logic [31:0]                     sb_axi_araddr,
   output logic [3:0]                      sb_axi_arregion,
   output logic [7:0]                      sb_axi_arlen,
   output logic [2:0]                      sb_axi_arsize,
   output logic [1:0]                      sb_axi_arburst,
   output logic                            sb_axi_arlock,
   output logic [3:0]                      sb_axi_arcache,
   output logic [2:0]                      sb_axi_arprot,
   output logic [3:0]                      sb_axi_arqos,

   input  logic                            sb_axi_rvalid,
   output logic                            sb_axi_rready,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_rid,
   input  logic [63:0]                     sb_axi_rdata,
   input  logic [1:0]                      sb_axi_rresp,
   input  logic                            sb_axi_rlast,

   //-------------------------- DMA AXI signals--------------------------
   // AXI Write Channels
   input  logic                            dma_axi_awvalid,
   output logic                            dma_axi_awready,
   input  logic [pt.DMA_BUS_TAG-1:0]       dma_axi_awid,
   input  logic [31:0]                     dma_axi_awaddr,
   input  logic [2:0]                      dma_axi_awsize,
   input  logic [2:0]                      dma_axi_awprot,
   input  logic [7:0]                      dma_axi_awlen,
   input  logic [1:0]                      dma_axi_awburst,


   input  logic                            dma_axi_wvalid,
   output logic                            dma_axi_wready,
   input  logic [63:0]                     dma_axi_wdata,
   input  logic [7:0]                      dma_axi_wstrb,
   input  logic                            dma_axi_wlast,

   output logic                            dma_axi_bvalid,
   input  logic                            dma_axi_bready,
   output logic [1:0]                      dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]       dma_axi_bid,

   // AXI Read Channels
   input  logic                            dma_axi_arvalid,
   output logic                            dma_axi_arready,
   input  logic [pt.DMA_BUS_TAG-1:0]       dma_axi_arid,
   input  logic [31:0]                     dma_axi_araddr,
   input  logic [2:0]                      dma_axi_arsize,
   input  logic [2:0]                      dma_axi_arprot,
   input  logic [7:0]                      dma_axi_arlen,
   input  logic [1:0]                      dma_axi_arburst,

   output logic                            dma_axi_rvalid,
   input  logic                            dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]       dma_axi_rid,
   output logic [63:0]                     dma_axi_rdata,
   output logic [1:0]                      dma_axi_rresp,
   output logic                            dma_axi_rlast,

   // clk ratio signals
   input logic                             lsu_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                             ifu_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                             dbg_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                             dma_bus_clk_en, // Clock ratio b/w cpu core clk & AHB slave interface

   input logic                             timer_int,
   input logic [pt.PIC_TOTAL_INT:1]        extintsrc_req,

   output logic                            dec_tlu_perfcnt0, // toggles when slot0 perf counter 0 has an event inc
   output logic                            dec_tlu_perfcnt1,
   output logic                            dec_tlu_perfcnt2,
   output logic                            dec_tlu_perfcnt3,

   //Debug module
   input  logic                            dmi_reg_en,
   input  logic [6:0]                      dmi_reg_addr,
   input  logic                            dmi_reg_wr_en,
   input  logic [31:0] 	            dmi_reg_wdata,
   output logic [31:0] 	            dmi_reg_rdata,
   input  logic                            dmi_hard_reset,

   // external MPC halt/run interface
   input logic                             mpc_debug_halt_req, // Async halt request
   input logic                             mpc_debug_run_req,  // Async run request
   input logic                             mpc_reset_run_req,  // Run/halt after reset
   output logic                            mpc_debug_halt_ack, // Halt ack
   output logic                            mpc_debug_run_ack,  // Run ack
   output logic                            debug_brkpt_status, // debug breakpoint

   input logic                             i_cpu_halt_req,      // Async halt req to CPU
   output logic                            o_cpu_halt_ack,      // core response to halt
   output logic                            o_cpu_halt_status,   // 1'b1 indicates core is halted
   output logic                            o_debug_mode_status, // Core to the PMU that core is in debug mode. When core is in debug mode, the PMU should refrain from sendng a halt or run request
   input logic                             i_cpu_run_req, // Async restart req to CPU
   output logic                            o_cpu_run_ack, // Core response to run req
   input logic                             scan_mode,     // To enable scan mode
   input logic                             mbist_mode     // to enable mbist
);

   el2_dccm_ext_in_pkt_t  [pt.DCCM_NUM_BANKS-1:0] dccm_ext_in_pkt;
   el2_ccm_ext_in_pkt_t  [pt.ICCM_NUM_BANKS-1:0] iccm_ext_in_pkt;
   el2_ic_data_ext_in_pkt_t  [pt.ICACHE_NUM_WAYS-1:0][pt.ICACHE_BANKS_WAY-1:0] ic_data_ext_in_pkt;
   el2_ic_tag_ext_in_pkt_t  [pt.ICACHE_NUM_WAYS-1:0] ic_tag_ext_in_pkt;

   logic                             active_l2clk;
   logic                             free_l2clk;

   // DCCM ports
   logic         dccm_wren;
   logic         dccm_rden;
   logic [pt.DCCM_BITS-1:0]         dccm_wr_addr_lo;
   logic [pt.DCCM_BITS-1:0]         dccm_wr_addr_hi;
   logic [pt.DCCM_BITS-1:0]         dccm_rd_addr_lo;
   logic [pt.DCCM_BITS-1:0]         dccm_rd_addr_hi;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi;

   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi;

   // PIC ports

   // Icache & Itag ports
   logic [31:1]  ic_rw_addr;
   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_wr_en  ;     // Which way to write
   logic         ic_rd_en ;


   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_tag_valid;   // Valid from the I$ tag valid outside (in flops).

   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_rd_hit;      // ic_rd_hit[3:0]
   logic         ic_tag_perr;                       // Ic tag parity error

   logic [pt.ICACHE_INDEX_HI:3]  ic_debug_addr;     // Read/Write addresss to the Icache.
   logic         ic_debug_rd_en;                    // Icache debug rd
   logic         ic_debug_wr_en;                    // Icache debug wr
   logic         ic_debug_tag_array;                // Debug tag array
   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_debug_way;   // Debug way. Rd or Wr.

   logic [25:0]  ictag_debug_rd_data;               // Debug icache tag.
   logic [pt.ICACHE_BANKS_WAY-1:0][70:0]  ic_wr_data;
   logic [63:0]  ic_rd_data;
   logic [70:0]  ic_debug_rd_data;                  // Data read from Icache. 2x64bits + parity bits. F2 stage. With ECC
   logic [70:0]  ic_debug_wr_data;                  // Debug wr cache.

   logic [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr;       // ecc error per bank
   logic [pt.ICACHE_BANKS_WAY-1:0] ic_parerr;       // parity error per bank

   logic [63:0]  ic_premux_data;
   logic         ic_sel_premux_data;

   // ICCM ports
   logic [pt.ICCM_BITS-1:1]    iccm_rw_addr;
   logic           iccm_wren;
   logic           iccm_rden;
   logic [2:0]     iccm_wr_size;
   logic [77:0]    iccm_wr_data;
   logic           iccm_buf_correct_ecc;
   logic           iccm_correction_state;

   logic [63:0]    iccm_rd_data;
   logic [77:0]    iccm_rd_data_ecc;

   logic        core_rst_l;                         // Core reset including rst_l and dbg_rst_l
   logic        jtag_tdoEn;

   logic        dccm_clk_override;
   logic        icm_clk_override;
   logic        dec_tlu_core_ecc_disable;

 //// AHB LITE BUS
   logic [31:0]              haddr;
   logic [2:0]               hburst;
   logic                     hmastlock;
   logic [3:0]               hprot;
   logic [2:0]               hsize;
   logic [1:0]               htrans;
   logic                     hwrite;

   logic [63:0]              hrdata;
   logic                     hready;
   logic                     hresp;

   // LSU AHB Master
   logic [31:0]              lsu_haddr;
   logic [2:0]               lsu_hburst;
   logic                     lsu_hmastlock;
   logic [3:0]               lsu_hprot;
   logic [2:0]               lsu_hsize;
   logic [1:0]               lsu_htrans;
   logic                     lsu_hwrite;
   logic [63:0]              lsu_hwdata;

   logic [63:0]              lsu_hrdata;
   logic                     lsu_hready;
   logic                     lsu_hresp;
   // Debug Syster Bus AHB
   logic [31:0]              sb_haddr;
   logic [2:0]               sb_hburst;
   logic                     sb_hmastlock;
   logic [3:0]               sb_hprot;
   logic [2:0]               sb_hsize;
   logic [1:0]               sb_htrans;
   logic                     sb_hwrite;
   logic [63:0]              sb_hwdata;

    logic [63:0]             sb_hrdata;
    logic                    sb_hready;
    logic                    sb_hresp;

   // DMA Slave
   logic                     dma_hsel;
   logic [31:0]              dma_haddr;
   logic [2:0]               dma_hburst;
   logic                     dma_hmastlock;
   logic [3:0]               dma_hprot;
   logic [2:0]               dma_hsize;
   logic [1:0]               dma_htrans;
   logic                     dma_hwrite;
   logic [63:0]              dma_hwdata;
   logic                     dma_hreadyin;

   logic [63:0]              dma_hrdata;
   logic                     dma_hreadyout;
   logic                     dma_hresp;



   // AHB
   assign  hrdata[63:0]                           = '0;
   assign  hready                                 = '0;
   assign  hresp                                  = '0;
   // LSU
   assign  lsu_hrdata[63:0]                       = '0;
   assign  lsu_hready                             = '0;
   assign  lsu_hresp                              = '0;
   // Debu
   assign  sb_hrdata[63:0]                        = '0;
   assign  sb_hready                              = '0;
   assign  sb_hresp                               = '0;

   // DMA
   assign  dma_hsel                               = '0;
   assign  dma_haddr[31:0]                        = '0;
   assign  dma_hburst[2:0]                        = '0;
   assign  dma_hmastlock                          = '0;
   assign  dma_hprot[3:0]                         = '0;
   assign  dma_hsize[2:0]                         = '0;
   assign  dma_htrans[1:0]                        = '0;
   assign  dma_hwrite                             = '0;
   assign  dma_hwdata[63:0]                       = '0;
   assign  dma_hreadyin                           = '0;

   // Instantiate the el2_swerv core
   el2_swerv swerv (
                                .soft_int (1'b0),
                                .core_id  (28'd0),
                                .*
                                );

   // Instantiate the mem
   el2_mem   mem (
                             .clk(active_l2clk),
                             .rst_l(core_rst_l),
                             .*
                             );

endmodule

