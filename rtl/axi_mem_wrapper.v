`default_nettype none
module axi_mem_wrapper
  #(parameter ID_WIDTH = 0,
    parameter MEM_SIZE = 0,
    parameter INIT_FILE = "")
  (input 		clk,
   input 		 rst_n,

   input [ID_WIDTH-1:0]  i_awid,
   input [31:0] 	 i_awaddr,
   input [7:0] 		 i_awlen,
   input [2:0] 		 i_awsize,
   input [1:0] 		 i_awburst,
   input 		 i_awvalid,
   output 		 o_awready,

   input [ID_WIDTH-1:0]  i_arid,
   input [31:0] 	 i_araddr,
   input [7:0] 		 i_arlen,
   input [2:0] 		 i_arsize,
   input [1:0] 		 i_arburst,
   input 		 i_arvalid,
   output 		 o_arready,

   input [63:0] 	 i_wdata,
   input [7:0] 		 i_wstrb,
   input 		 i_wlast,
   input 		 i_wvalid,
   output 		 o_wready,

   output [ID_WIDTH-1:0] o_bid,
   output [1:0] 	 o_bresp,
   output 		 o_bvalid,
   input 		 i_bready,

   output [ID_WIDTH-1:0] o_rid,
   output [63:0] 	 o_rdata,
   output [1:0] 	 o_rresp,
   output 		 o_rlast,
   output 		 o_rvalid,
   input 		 i_rready);

   wire 	 mem_we;
   wire [31:0] 	 mem_addr;
   wire [7:0] 	 mem_be;
   wire [63:0] 	 mem_wdata;
   wire [63:0] 	 mem_rdata;

   AXI_BUS #(32, 64, ID_WIDTH, 1) slave();

   assign slave.aw_id    = i_awid   ;
   assign slave.aw_addr  = i_awaddr ;
   assign slave.aw_len   = i_awlen  ;
   assign slave.aw_size  = i_awsize ;
   assign slave.aw_burst = i_awburst;
   assign slave.aw_valid = i_awvalid;
   assign o_awready = slave.aw_ready;

   assign slave.ar_id    = i_arid   ;
   assign slave.ar_addr  = i_araddr ;
   assign slave.ar_len   = i_arlen  ;
   assign slave.ar_size  = i_arsize ;
   assign slave.ar_burst = i_arburst;
   assign slave.ar_valid = i_arvalid;
   assign o_arready = slave.ar_ready;

   assign slave.w_data  = i_wdata ;
   assign slave.w_strb  = i_wstrb ;
   assign slave.w_last  = i_wlast ;
   assign slave.w_valid = i_wvalid;
   assign o_wready = slave.w_ready;

   assign o_bid    = slave.b_id   ;
   assign o_bresp  = slave.b_resp ;
   assign o_bvalid = slave.b_valid;
   assign slave.b_ready = i_bready;

   assign o_rid    = slave.r_id   ;
   assign o_rdata  = slave.r_data ;
   assign o_rresp  = slave.r_resp ;
   assign o_rlast  = slave.r_last ;
   assign o_rvalid = slave.r_valid;
   assign slave.r_ready = i_rready;

   axi2mem
     #(.AXI_ID_WIDTH   (ID_WIDTH),
       .AXI_ADDR_WIDTH (32),
       .AXI_DATA_WIDTH (64),
       .AXI_USER_WIDTH (0))
   ram_axi2mem
     (.clk_i  (clk),
      .rst_ni (rst_n),
      .slave  (slave),
      .req_o  (),
      .we_o   (mem_we),
      .addr_o (mem_addr),
      .be_o   (mem_be),
      .data_o (mem_wdata),
      .data_i (mem_rdata));

   dpram64
     #(.SIZE (MEM_SIZE),
       .memfile (INIT_FILE))
   ram
     (.clk   (clk),
      .we    ({8{mem_we}} & mem_be),
      .din   (mem_wdata),
      .waddr (mem_addr),
      .raddr ({mem_addr[$clog2(MEM_SIZE)-1:3],3'b000}),
      .dout  (mem_rdata));

endmodule
