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
// Function: Verilog testbench for SweRVolf
// Comments:
//
//********************************************************************************

`default_nettype none
module swervolf_core_tb
  #(parameter bootrom_file  = "jumptoram.vh")
`ifdef VERILATOR
  (input clk,
   input  rst,
   output o_gpio)
`endif
  ;

`ifndef VERILATOR
   reg 	 clk = 1'b0;
   reg 	 rst = 1'b1;
   always #5 clk <= !clk;
   initial #100 rst <= 1'b0;
   wire  o_gpio;
`endif

   reg [1023:0] ram_init_file;

   initial begin
      if ($value$plusargs("ram_init_file=%s", ram_init_file)) begin
	 $display("Loading RAM contents from %0s", ram_init_file);
	 $readmemh(ram_init_file, swervolf.ram.ram.mem);
      end
   end

   reg [1023:0] rom_init_file;

   initial begin
      if ($value$plusargs("rom_init_file=%s", rom_init_file)) begin
	 $display("Loading ROM contents from %0s", rom_init_file);
	 $readmemh(rom_init_file, swervolf.bootrom.ram.mem);
      end
   end

   swervolf_core
     #(.bootrom_file (bootrom_file),
       .ram_init_file (""))
   swervolf
     (.clk  (clk),
      .rstn (!rst),
      .o_gpio (o_gpio));

endmodule
