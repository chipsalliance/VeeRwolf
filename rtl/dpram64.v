/*  ISC License
 *
 *  Basic RAM model with separate read/write ports and byte-wise write enable
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
module dpram64
  #(parameter SIZE=0,
    parameter memfile = "")
  (input wire clk,
   input wire [7:0] 		 we,
   input wire [63:0] 		 din,
   input wire [$clog2(SIZE)-1:0] waddr,
   input wire [$clog2(SIZE)-1:0] raddr,
   output reg [63:0] 		 dout);

   localparam AW = $clog2(SIZE);

   reg [63:0] 			 mem [0:SIZE/8-1] /* verilator public */;

   integer 	 i;
   wire [AW-4:0] wadd = waddr[AW-1:3];

   always @(posedge clk) begin
      if (we[0]) mem[wadd][ 7: 0] <= din[ 7: 0];
      if (we[1]) mem[wadd][15: 8] <= din[15: 8];
      if (we[2]) mem[wadd][23:16] <= din[23:16];
      if (we[3]) mem[wadd][31:24] <= din[31:24];
      if (we[4]) mem[wadd][39:32] <= din[39:32];
      if (we[5]) mem[wadd][47:40] <= din[47:40];
      if (we[6]) mem[wadd][55:48] <= din[55:48];
      if (we[7]) mem[wadd][63:56] <= din[63:56];
      dout <= mem[raddr[AW-1:3]];
   end

   reg [7:0] 			 mem0 [0:SIZE-1] /* verilator public */;
   generate
      initial
	if(|memfile) begin
	   $display("Preloading %m from %s", memfile);
	   $readmemh(memfile, mem);
	   /*for (i=0;i<SIZE/8;i=i+1) begin
	      mem[i][ 7: 0] <= mem0[i+0];
	      mem[i][15: 8] <= mem0[i+1];
	      mem[i][23:16] <= mem0[i+2];
	      mem[i][31:24] <= mem0[i+3];
	      mem[i][39:32] <= mem0[i+4];
	      mem[i][47:40] <= mem0[i+5];
	      mem[i][55:48] <= mem0[i+6];
	      mem[i][63:56] <= mem0[i+7];
	   end*/
	end
   endgenerate

endmodule
