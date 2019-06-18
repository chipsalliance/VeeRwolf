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
  #(parameter bootrom_file = "jumptoram.vh",
    parameter ram_init_file = "zephyr_blinky.vh")
   (input 	 clk,
    input 	 rstn,
    output 	 led0);

   wire 	 clk25;
   wire 	 rst25;

   clk_gen_nexys clk_gen
     (.i_clk (clk),
      .i_rst (~rstn),
      .o_clk25 (clk25),
      .o_rst25 (rst25));

   swervolf_core
     #(.bootrom_file (bootrom_file),
       .ram_init_file (ram_init_file))
   swervolf
     (.clk  (clk25),
      .rstn (~rst25),
      .o_gpio (led0));

endmodule
