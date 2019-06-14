/*  ISC License
 *
 *  Verilog testbench for SweRV SoC
 *
 *  Copyright (C) 2019  Olof Kindgren <olof.kindgren@gmail.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
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
