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
// Function: Verilog testbench for VeeRwolf for Nexys A7
// Comments:
//
//********************************************************************************

`default_nettype none
module veerwolf_nexys_tb
  #(parameter bootrom_file  = "jumptoram.vh")
  ;

   localparam RAM_SIZE     = 32'h10000;
   
   reg 	 clk = 1'b0;
   reg 	 rst = 1'b1;
   always #5 clk <= !clk;
   initial #100 rst <= 1'b0;
   wire  o_gpio;

   reg [1023:0] ram_init_file;

   initial begin
      if ($value$plusargs("ram_init_file=%s", ram_init_file)) begin
	 $display("Loading RAM contents from %0s", ram_init_file);
	 $readmemh(ram_init_file, ram.ram.mem);
      end
   end

   reg [1023:0] rom_init_file;

   initial begin
      if ($value$plusargs("rom_init_file=%s", rom_init_file)) begin
	 $display("Loading ROM contents from %0s", rom_init_file);
	 $readmemh(rom_init_file, veerwolf.bootrom.ram.mem);
      end
   end

   veerwolf_nexys
     #(.bootrom_file (bootrom_file),
       .ram_init_file (""))
   veerwolf
     (.clk         (clk),
      .rstn        (!rst),
      .ddram_a     (),
      .ddram_ba    (),
      .ddram_ras_n (),
      .ddram_cas_n (),
      .ddram_we_n  (),
      .ddram_cs_n  (),
      .ddram_dm    (),
      .ddram_dq    (16'dz),
      .ddram_dqs_p (),
      .ddram_dqs_n (),
      .ddram_clk_p (),
      .ddram_clk_n (),
      .ddram_cke   (),
      .ddram_odt   (),
      .o_serial_tx (serial),
      .i_serial_rx (1'b1),
      .led0 (),
      .led1 (),
      .led2 (),
      .led3 (),
      .led4 ());

endmodule
