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
// Function: VeeRwolf Altera Agilex clock generation
// Comments:
//
//********************************************************************************

module clk_gen_agilex
  (input  wire    i_clk,
   input  wire    i_rst,
   output wire    o_clk_core,
   output wire    o_rst_core);

   parameter CPU_TYPE = "";

   wire   o_clk_pll;
   wire   locked;
   wire   ninit_done;
   reg    rst_reg1;
   reg    rst_reg2;

   assign o_rst_core = rst_reg2;
   assign o_clk_core = o_clk_pll;

   // ================================================================
   // Synchronize Reset
   // ================================================================
   always @(posedge o_clk_pll) begin
    if (!locked || i_rst) begin
      rst_reg1 <= 1'b1;
      rst_reg2 <= 1'b1;
    end else begin
      rst_reg1 <= 1'b0;
      rst_reg2 <= rst_reg1;
    end
   end

  // ================================================================
  // Agilex Reset Release
  // ================================================================
	altera_agilex_config_reset_release_endpoint config_reset_release_endpoint(
		.conf_reset(ninit_done)
	);

   ipm_iopll_basic #(
      .REFERENCE_CLOCK_FREQUENCY ("100.0 MHz"),
      .N_CNT                     (1), // divide factor of N-counter
      .M_CNT                     (8), // multiply factor of M-counter
      .C0_CNT                    ((CPU_TYPE == "EL2") ? 32 : 16), // divide factor for the output clock 
      .C1_CNT                    (1),
      .C2_CNT                    (1),
      .C3_CNT                    (1),
      .C4_CNT                    (1),
      .C5_CNT                    (1),
      .C6_CNT                    (1),
      .PLL_SIM_MODEL             ("")
   ) my_pll (
    .refclk    (i_clk),           //input, width = 1
    .reset     (ninit_done),      //input, width = 1
    .outclk0   (o_clk_pll),             //output, width = 1
    .outclk1   (),                //output, width = 1
    .outclk2   (),                //output, width = 1
    .outclk3   (),                //output, width = 1
    .outclk4   (),                //output, width = 1
    .outclk5   (),                //output, width = 1
    .outclk6   (),                //output, width = 1
    .locked    (locked)           //output, width = 1
   );
endmodule
