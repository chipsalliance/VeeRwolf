/*  ISC License
 *
 *  SweRV SoC Nexys A7 toplevel
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
