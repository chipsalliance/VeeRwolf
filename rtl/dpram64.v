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
// Function: Basic RAM model with separate read/write ports and byte-wise write enable
// Comments:
//
//********************************************************************************

module dpram64
  #(parameter SIZE=0,
    parameter mem_clear = 0,
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

   generate
      initial begin
	 if (mem_clear)
	   for (i=0;i<SIZE;i=i+1)
	     mem[i] = 64'd0;
	 if(|memfile) begin
	    $display("Preloading %m from %s", memfile);
	    $readmemh(memfile, mem);
	 end
      end
   endgenerate

endmodule
