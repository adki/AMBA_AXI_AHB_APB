//----------------------------------------------------------------
//  Copyright (c) 2013 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// bfm_axi.v
//----------------------------------------------------------------
// VERSION: 2013.02.03.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4       - AMBA AXI4
//    AMBA_AXI_CACHE  -
//    AMBA_AXI_PROT   -
//----------------------------------------------------------------
`timescale 1ns/1ns

module bfm_axi #(parameter MST_ID   =0         // Master ID
                         , WIDTH_CID=4
                         , WIDTH_ID =4         // ID width in bits
                         , WIDTH_AD =32        // address width
                         , WIDTH_DA =32        // data width
                         , WIDTH_DS =(WIDTH_DA/8) // data strobe width
                         , WIDTH_DSB=clogb2(WIDTH_DS) // data strobe width
                         , EN       =1
                         , ADDR_LENGTH=12
                   )
(
       input  wire                 ARESETn
     , input  wire                 ACLK
     , output wire [WIDTH_CID-1:0] MID
     //-----------------------------------------------------------
     , output reg  [WIDTH_ID-1:0]  AWID
     , output reg  [WIDTH_AD-1:0]  AWADDR
     `ifdef AMBA_AXI4
     , output reg  [ 7:0]          AWLEN
     , output reg                  AWLOCK
     `else
     , output reg  [ 3:0]          AWLEN
     , output reg  [ 1:0]          AWLOCK
     `endif
     , output reg  [ 2:0]          AWSIZE
     , output reg  [ 1:0]          AWBURST
     `ifdef AMBA_AXI_CACHE
     , output reg  [ 3:0]          AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output reg  [ 2:0]          AWPROT
     `endif
     , output reg                  AWVALID
     , input  wire                 AWREADY
     `ifdef AMBA_AXI4
     , output reg  [ 3:0]          AWQOS
     , output reg  [ 3:0]          AWREGION
     `endif
     //-----------------------------------------------------------
     , output reg  [WIDTH_ID-1:0]  WID
     , output reg  [WIDTH_DA-1:0]  WDATA
     , output reg  [WIDTH_DS-1:0]  WSTRB
     , output reg                  WLAST
     , output reg                  WVALID
     , input  wire                 WREADY
     //-----------------------------------------------------------
     , input  wire [WIDTH_ID-1:0]  BID
     , input  wire [ 1:0]          BRESP
     , input  wire                 BVALID
     , output reg                  BREADY
     //-----------------------------------------------------------
     , output reg  [WIDTH_ID-1:0]  ARID
     , output reg  [WIDTH_AD-1:0]  ARADDR
     `ifdef AMBA_AXI4
     , output reg  [ 7:0]          ARLEN
     , output reg                  ARLOCK
     `else
     , output reg  [ 3:0]          ARLEN
     , output reg  [ 1:0]          ARLOCK
     `endif
     , output reg  [ 2:0]          ARSIZE
     , output reg  [ 1:0]          ARBURST
     `ifdef AMBA_AXI_CACHE
     , output reg  [ 3:0]          ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output reg  [ 2:0]          ARPROT
     `endif
     , output reg                  ARVALID
     , input  wire                 ARREADY
     `ifdef AMBA_AXI4
     , output reg  [ 3:0]          ARQOS
     , output reg  [ 3:0]          ARREGION
     `endif
     //-----------------------------------------------------------
     , input  wire [WIDTH_ID-1:0]  RID
     , input  wire [WIDTH_DA-1:0]  RDATA
     , input  wire [ 1:0]          RRESP
     , input  wire                 RLAST
     , input  wire                 RVALID
     , output reg                  RREADY
     //-----------------------------------------------------------
     , input  wire                 CSYSREQ
     , output reg                  CSYSACK
     , output reg                  CACTIVE
);
     //-----------------------------------------------------------
     assign MID = MST_ID;
     //-----------------------------------------------------------
     reg [15:0] bnum ; initial bnum  = 0;
     reg [15:0] blen ; initial blen  = 0;
     reg [15:0] bsize; initial bsize = 0;
     reg        delay; initial delay = 0;
     reg [31:0] saddr, depth;
     reg        DONE = 1'b0;
     integer    nm, ns;
     //-----------------------------------------------------------
     initial begin
           CSYSACK     = 1'b1;
           CACTIVE     = 1'b1;
           AWID        = 0;
           AWADDR      = ~0;
           AWLEN       = 0;
           AWLOCK      = 0;
           AWSIZE      = 0;
           AWBURST     = 0;
     `ifdef AMBA_AXI_CACHE
           AWCACHE     = 0;
     `endif
     `ifdef AMBA_AXI_PROT
           AWPROT      = 0;
     `endif
           AWVALID     = 0;
           `ifdef AMBA_AXI4
           AWQOS       = 0;
           AWREGION    = 0;
           `endif
           WID         = 0;
           WDATA       = ~0;
           WSTRB       = 0;
           WLAST       = 0;
           WVALID      = 0;
           BREADY      = 0;
           ARID        = 0;
           ARADDR      = ~0;
           ARLEN       = 0;
           ARLOCK      = 0;
           ARSIZE      = 0;
           ARBURST     = 0;
     `ifdef AMBA_AXI_CACHE
           ARCACHE     = 0;
     `endif
     `ifdef AMBA_AXI_PROT
           ARPROT      = 0;
     `endif
           ARVALID     = 0;
           `ifdef AMBA_AXI4
           ARQOS       = 0;
           ARREGION    = 0;
           `endif
           RREADY      = 0; 
           wait (ARESETn==1'b0);
           wait (ARESETn==1'b1);
           repeat (5) @ (posedge ACLK);
           //-----------------------------------------------------
if (EN) begin
   // single-burst with different size
   if (0) begin
   test_raw( 32'h1  //input [31:0] id;
           , 32'h0  //input [31:0] saddr; // start address
           , 32'h10 //input [31:0] depth; // size in byte
           , 32'h4  //input [31:0] bsize; // burst size in byte
           , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw( 32'h2  //input [31:0] id;
           , 32'h10 //input [31:0] saddr; // start address
           , 32'h10 //input [31:0] depth; // size in byte
           , 32'h2  //input [31:0] bsize; // burst size in byte
           , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw( 32'h3  //input [31:0] id;
           , 32'h20 //input [31:0] saddr; // start address
           , 32'h10 //input [31:0] depth; // size in byte
           , 32'h1  //input [31:0] bsize; // burst size in byte
           , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   //---------------------------------------------------------
   // single-burst with different size
   if (0) begin
   test_raw_all( 32'h4  //input [31:0] id;
               , 32'h30 //input [31:0] saddr; // start address
               , 32'h10 //input [31:0] depth; // size in byte
               , 32'h4  //input [31:0] bsize; // burst size in byte
               , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw_all( 32'h5  //input [31:0] id;
               , 32'h40 //input [31:0] saddr; // start address
               , 32'h10 //input [31:0] depth; // size in byte
               , 32'h2  //input [31:0] bsize; // burst size in byte
               , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw_all( 32'h6  //input [31:0] id;
               , 32'h50 //input [31:0] saddr; // start address
               , 32'h10 //input [31:0] depth; // size in byte
               , 32'h1  //input [31:0] bsize; // burst size in byte
               , 32'h1  //input [31:0] bleng; // burst length
   );
   end
   //---------------------------------------------------------
   // burst with different size
   if (1) begin
   blen  = 4;
   bsize = 4;
   test_raw_burst ( 32'h7  //input [31:0] id;
                  , 32'h30 //input [31:0] saddr; // start address
                  , bsize*blen*2//input [31:0] depth; // size in byte
                  , bsize  //input [31:0] bsize; // burst size in byte
                  , blen   //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw_burst ( 32'h8  //input [31:0] id;
                  , 32'h40 //input [31:0] saddr; // start address
                  , 32'h10 //input [31:0] depth; // size in byte
                  , 32'h2  //input [31:0] bsize; // burst size in byte
                  , 32'h4  //input [31:0] bleng; // burst length
   );
   end
   if (0) begin
   test_raw_burst ( 32'h9  //input [31:0] id;
                  , 32'h50 //input [31:0] saddr; // start address
                  , 32'h10 //input [31:0] depth; // size in byte
                  , 32'h1  //input [31:0] bsize; // burst size in byte
                  , 32'h4  //input [31:0] bleng; // burst length
   );
   end
end
           //-----------------------------------------------------
           repeat (10) @ (posedge ACLK);
           DONE = 1'b1;
           //$finish(2);
     end
     //-----------------------------------------------------------
     `include "bfm_axi_tasks.v"
     //-----------------------------------------------------------
     function integer clogb2;
     input [31:0] value;
     begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
           value = value >> 1;
        end
     endfunction
     //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2013.02.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
