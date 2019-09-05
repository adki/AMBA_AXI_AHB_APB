//----------------------------------------------------------------
//  Copyright (c) 2015 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// top.v
//----------------------------------------------------------------
// VERSION: 2015.07.12.
//----------------------------------------------------------------
`timescale 1ns/1ns

`ifndef WIDTH_AD
`define WIDTH_AD   32 // address width
`endif
`ifndef WIDTH_DA
`define WIDTH_DA   32 // data width
`endif
`ifndef ADDR_LENGTH
`define ADDR_LENGTH 20
`endif

module top ;
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
   end
   `endif
   //---------------------------------------------------------
   // +---------+                               +-----------------+
   // |  BFM    |                               | DMA             |
   // |         |                               |                 |
   // | MID[WIDTH_CID] --BFM_MID[WIDTH_CID]--|  |                 |
   // | AxID[WIDTH_ID] --BFM_AxID[WIDTH_ID]--+->|S_AxID[WIDTH_SID]|
   // |         |                               |                 |
   //---------------------------------------------------------
   // +---------+                               +----------------+
   // |  DMA    |                               | MEM            |
   // |         |                               |                |
   // | MID[WIDTH_CID] --MEM_MID[WIDTH_CID]--|  |                |
   // | AxID[WIDTH_ID] --MEM_AxID[WIDTH_ID]--+->|AxID[WIDTH_SID] |
   // |         |                               |                |
   //---------------------------------------------------------
   localparam WIDTH_CID   = 2    // Channel ID width in bits; it should be 0 since no AXI matrix
            , WIDTH_ID    = 4    // ID width in bits for master
            , WIDTH_AD    =`WIDTH_AD    // address width
            , WIDTH_DA    =`WIDTH_DA    // data width
            , WIDTH_DS    =(WIDTH_DA/8)  // data strobe width
            , WIDTH_SID   =WIDTH_CID+WIDTH_ID // ID for slave
            , WIDTH_AWUSER=1  // Write-address user path
            , WIDTH_WUSER =1  // Write-data user path
            , WIDTH_BUSER =1  // Write-response user path
            , WIDTH_ARUSER=1  // read-address user path
            , WIDTH_RUSER =1; // read-data user path
   localparam ADDR_BASE0  =32'h0000_0000
            , ADDR_LENGTH0=`ADDR_LENGTH
            , ADDR_BASE1  =(ADDR_BASE0+(1<<ADDR_LENGTH0))
            , ADDR_LENGTH1=`ADDR_LENGTH;
   //---------------------------------------------------------
   reg                       ARESETn;
   reg                       ACLK   ;
   //--------------------------------------------------------------
   wire  [WIDTH_CID-1:0]     BFM_MID     , MEM_MID     ;
   wire  [WIDTH_SID-1:0]     BFM_AWID    , MEM_AWID    ;
   wire  [WIDTH_AD-1:0]      BFM_AWADDR  , MEM_AWADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]              BFM_AWLEN   , MEM_AWLEN   ;
   wire                      BFM_AWLOCK  , MEM_AWLOCK  ;
   `else
   wire  [ 3:0]              BFM_AWLEN   , MEM_AWLEN   ;
   wire  [ 1:0]              BFM_AWLOCK  , MEM_AWLOCK  ;
   `endif
   wire  [ 2:0]              BFM_AWSIZE  , MEM_AWSIZE  ;
   wire  [ 1:0]              BFM_AWBURST , MEM_AWBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]              BFM_AWCACHE , MEM_AWCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]              BFM_AWPROT  , MEM_AWPROT  ;
   `endif
   wire                      BFM_AWVALID , MEM_AWVALID ;
   wire                      BFM_AWREADY , MEM_AWREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]              BFM_AWQOS   , MEM_AWQOS   ;
   wire  [ 3:0]              BFM_AWREGION, MEM_AWREGION;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [WIDTH_AWUSER-1:0]  BFM_AWUSER  , MEM_AWUSER  ;
   `endif
   wire  [WIDTH_SID-1:0]     BFM_WID     , MEM_WID     ;
   wire  [WIDTH_DA-1:0]      BFM_WDATA   , MEM_WDATA   ;
   wire  [WIDTH_DS-1:0]      BFM_WSTRB   , MEM_WSTRB   ;
   wire                      BFM_WLAST   , MEM_WLAST   ;
   wire                      BFM_WVALID  , MEM_WVALID  ;
   wire                      BFM_WREADY  , MEM_WREADY  ;
   `ifdef AMBA_AXI_WUSER
   wire  [WIDTH_WUSER-1:0]   BFM_WUSER   , MEM_WUSER   ;
   `endif
   wire  [WIDTH_SID-1:0]     BFM_BID     , MEM_BID     ;
   wire  [ 1:0]              BFM_BRESP   , MEM_BRESP   ;
   wire                      BFM_BVALID  , MEM_BVALID  ;
   wire                      BFM_BREADY  , MEM_BREADY  ;
   `ifdef AMBA_AXI_BUSER
   wire  [WIDTH_BUSER-1:0]   BFM_BUSER   , MEM_BUSER   ;
   `endif
   wire  [WIDTH_SID-1:0]     BFM_ARID    , MEM_ARID    ;
   wire  [WIDTH_AD-1:0]      BFM_ARADDR  , MEM_ARADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]              BFM_ARLEN   , MEM_ARLEN   ;
   wire                      BFM_ARLOCK  , MEM_ARLOCK  ;
   `else
   wire  [ 3:0]              BFM_ARLEN   , MEM_ARLEN   ;
   wire  [ 1:0]              BFM_ARLOCK  , MEM_ARLOCK  ;
   `endif
   wire  [ 2:0]              BFM_ARSIZE  , MEM_ARSIZE  ;
   wire  [ 1:0]              BFM_ARBURST , MEM_ARBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]              BFM_ARCACHE , MEM_ARCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]              BFM_ARPROT  , MEM_ARPROT  ;
   `endif
   wire                      BFM_ARVALID , MEM_ARVALID ;
   wire                      BFM_ARREADY , MEM_ARREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]              BFM_ARQOS   , MEM_ARQOS   ;
   wire  [ 3:0]              BFM_ARREGION, MEM_ARREGION;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [WIDTH_ARUSER-1:0]  BFM_ARUSER  , MEM_ARUSER  ;
   `endif
   wire  [WIDTH_SID-1:0]     BFM_RID     , MEM_RID     ;
   wire  [WIDTH_DA-1:0]      BFM_RDATA   , MEM_RDATA   ;
   wire  [ 1:0]              BFM_RRESP   , MEM_RRESP   ;
   wire                      BFM_RLAST   , MEM_RLAST   ;
   wire                      BFM_RVALID  , MEM_RVALID  ;
   wire                      BFM_RREADY  , MEM_RREADY  ;
   `ifdef AMBA_AXI_RUSER
   wire  [WIDTH_RUSER-1:0]   BFM_RUSER   , MEM_RUSER   ;
   `endif
   //---------------------------------------------------------
   bfm_axi    #(.MST_ID   (0        ) // Master ID
               ,.WIDTH_CID(WIDTH_CID)
               ,.WIDTH_ID (WIDTH_ID ) // ID width in bits
               ,.WIDTH_AD (WIDTH_AD ) // address width
               ,.WIDTH_DA (WIDTH_DA ))// data width
   u_bfm_axi(
         .ARESETn   (ARESETn          )
       , .ACLK      (ACLK             )
       , .MID       (BFM_MID          )
       , .AWID      (BFM_AWID[WIDTH_ID-1:0])
       , .AWADDR    (BFM_AWADDR       )
       , .AWLEN     (BFM_AWLEN        )
       , .AWLOCK    (BFM_AWLOCK       )
       , .AWSIZE    (BFM_AWSIZE       )
       , .AWBURST   (BFM_AWBURST      )
       `ifdef AMBA_AXI_CACHE
       , .AWCACHE   (BFM_AWCACHE      )
       `endif
       `ifdef AMBA_AXI_PROT
       , .AWPROT    (BFM_AWPROT       )
       `endif
       , .AWVALID   (BFM_AWVALID      )
       , .AWREADY   (BFM_AWREADY      )
       `ifdef AMBA_AXI4
       , .AWQOS     (BFM_AWQOS        )
       , .AWREGION  (BFM_AWREGION     )
       `endif
       , .WID       (BFM_WID[WIDTH_ID-1:0])
       , .WDATA     (BFM_WDATA        )
       , .WSTRB     (BFM_WSTRB        )
       , .WLAST     (BFM_WLAST        )
       , .WVALID    (BFM_WVALID       )
       , .WREADY    (BFM_WREADY       )
       , .BID       (BFM_BID[WIDTH_ID-1:0])
       , .BRESP     (BFM_BRESP        )
       , .BVALID    (BFM_BVALID       )
       , .BREADY    (BFM_BREADY       )
       , .ARID      (BFM_ARID[WIDTH_ID-1:0])
       , .ARADDR    (BFM_ARADDR       )
       , .ARLEN     (BFM_ARLEN        )
       , .ARLOCK    (BFM_ARLOCK       )
       , .ARSIZE    (BFM_ARSIZE       )
       , .ARBURST   (BFM_ARBURST      )
       `ifdef AMBA_AXI_CACHE
       , .ARCACHE   (BFM_ARCACHE      )
       `endif
       `ifdef AMBA_AXI_PROT
       , .ARPROT    (BFM_ARPROT       )
       `endif
       , .ARVALID   (BFM_ARVALID      )
       , .ARREADY   (BFM_ARREADY      )
       `ifdef AMBA_AXI4
       , .ARQOS     (BFM_ARQOS        )
       , .ARREGION  (BFM_ARREGION     )
       `endif
       , .RID       (BFM_RID[WIDTH_ID-1:0])
       , .RDATA     (BFM_RDATA        )
       , .RRESP     (BFM_RRESP        )
       , .RLAST     (BFM_RLAST        )
       , .RVALID    (BFM_RVALID       )
       , .RREADY    (BFM_RREADY       )
       , .CSYSREQ   (1'b1             )
       , .CSYSACK   ()
       , .CACTIVE   ()
   );
   assign BFM_AWID[WIDTH_SID-1:WIDTH_ID] = BFM_MID;
   assign BFM_WID [WIDTH_SID-1:WIDTH_ID] = BFM_MID;
   assign BFM_ARID[WIDTH_SID-1:WIDTH_ID] = BFM_MID;
   //---------------------------------------------------------
   dma_axi_simple #(.AXI_MST_ID   (1        ) // Master ID
                   ,.AXI_WIDTH_CID(WIDTH_CID)
                   ,.AXI_WIDTH_ID (WIDTH_ID ) // ID width in bits
                   ,.AXI_WIDTH_AD (WIDTH_AD ) // address width
                   ,.AXI_WIDTH_DA (WIDTH_DA ))// data width
   u_dma (
         .ARESETn     (ARESETn           )
       , .ACLK        (ACLK              )
       , .M_MID       (MEM_MID           )
       , .M_AWID      (MEM_AWID[WIDTH_ID-1:0])
       , .M_AWADDR    (MEM_AWADDR        )
       , .M_AWLEN     (MEM_AWLEN         )
       , .M_AWLOCK    (MEM_AWLOCK        )
       , .M_AWSIZE    (MEM_AWSIZE        )
       , .M_AWBURST   (MEM_AWBURST       )
       `ifdef AMBA_AXI_CACHE
       , .M_AWCACHE   (MEM_AWCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_AWPROT    (MEM_AWPROT      )
       `endif
       , .M_AWVALID   (MEM_AWVALID     )
       , .M_AWREADY   (MEM_AWREADY     )
       `ifdef AMBA_AXI4
       , .M_AWQOS     (MEM_AWQOS       )
       , .M_AWREGION  (MEM_AWREGION    )
       `endif
       , .M_WID       (MEM_WID[WIDTH_ID-1:0])
       , .M_WDATA     (MEM_WDATA       )
       , .M_WSTRB     (MEM_WSTRB       )
       , .M_WLAST     (MEM_WLAST       )
       , .M_WVALID    (MEM_WVALID      )
       , .M_WREADY    (MEM_WREADY      )
       , .M_BID       (MEM_BID[WIDTH_ID-1:0])
       , .M_BRESP     (MEM_BRESP       )
       , .M_BVALID    (MEM_BVALID      )
       , .M_BREADY    (MEM_BREADY      )
       , .M_ARID      (MEM_ARID[WIDTH_ID-1:0])
       , .M_ARADDR    (MEM_ARADDR      )
       , .M_ARLEN     (MEM_ARLEN       )
       , .M_ARLOCK    (MEM_ARLOCK      )
       , .M_ARSIZE    (MEM_ARSIZE      )
       , .M_ARBURST   (MEM_ARBURST     )
       `ifdef AMBA_AXI_CACHE
       , .M_ARCACHE   (MEM_ARCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_ARPROT    (MEM_ARPROT      )
       `endif
       , .M_ARVALID   (MEM_ARVALID     )
       , .M_ARREADY   (MEM_ARREADY     )
       `ifdef AMBA_AXI4
       , .M_ARQOS     (MEM_ARQOS       )
       , .M_ARREGION  (MEM_ARREGION    )
       `endif
       , .M_RID       (MEM_RID[WIDTH_ID-1:0])
       , .M_RDATA     (MEM_RDATA       )
       , .M_RRESP     (MEM_RRESP       )
       , .M_RLAST     (MEM_RLAST       )
       , .M_RVALID    (MEM_RVALID      )
       , .M_RREADY    (MEM_RREADY      )
       , .S_AWID      (BFM_AWID        )
       , .S_AWADDR    (BFM_AWADDR      )
       , .S_AWLEN     (BFM_AWLEN       )
       , .S_AWLOCK    (BFM_AWLOCK      )
       , .S_AWSIZE    (BFM_AWSIZE      )
       , .S_AWBURST   (BFM_AWBURST     )
       `ifdef AMBA_AXI_CACHE
       , .S_AWCACHE   (BFM_AWCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .S_AWPROT    (BFM_AWPROT      )
       `endif
       , .S_AWVALID   (BFM_AWVALID     )
       , .S_AWREADY   (BFM_AWREADY     )
       `ifdef AMBA_AXI4
       , .S_AWQOS     (BFM_AWQOS       )
       , .S_AWREGION  (BFM_AWREGION    )
       `endif
       , .S_WID       (BFM_WID         )
       , .S_WDATA     (BFM_WDATA       )
       , .S_WSTRB     (BFM_WSTRB       )
       , .S_WLAST     (BFM_WLAST       )
       , .S_WVALID    (BFM_WVALID      )
       , .S_WREADY    (BFM_WREADY      )
       , .S_BID       (BFM_BID         )
       , .S_BRESP     (BFM_BRESP       )
       , .S_BVALID    (BFM_BVALID      )
       , .S_BREADY    (BFM_BREADY      )
       , .S_ARID      (BFM_ARID        )
       , .S_ARADDR    (BFM_ARADDR      )
       , .S_ARLEN     (BFM_ARLEN       )
       , .S_ARLOCK    (BFM_ARLOCK      )
       , .S_ARSIZE    (BFM_ARSIZE      )
       , .S_ARBURST   (BFM_ARBURST     )
       `ifdef AMBA_AXI_CACHE
       , .S_ARCACHE   (BFM_ARCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .S_ARPROT    (BFM_ARPROT      )
       `endif
       , .S_ARVALID   (BFM_ARVALID     )
       , .S_ARREADY   (BFM_ARREADY     )
       `ifdef AMBA_AXI4
       , .S_ARQOS     (BFM_ARQOS       )
       , .S_ARREGION  (BFM_ARREGION    )
       `endif
       , .S_RID       (BFM_RID         )
       , .S_RDATA     (BFM_RDATA       )
       , .S_RRESP     (BFM_RRESP       )
       , .S_RLAST     (BFM_RLAST       )
       , .S_RVALID    (BFM_RVALID      )
       , .S_RREADY    (BFM_RREADY      )
       , .IRQ         (                )
   );
   assign MEM_AWID[WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   assign MEM_WID [WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   assign MEM_ARID[WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   //---------------------------------------------------------
   mem_axi   #(.AXI_WIDTH_CID  (WIDTH_CID)// Channel ID width in bits
              ,.AXI_WIDTH_ID   (WIDTH_ID )// ID width in bits
              ,.AXI_WIDTH_AD   (WIDTH_AD )// address width
              ,.AXI_WIDTH_DA   (WIDTH_DA )// data width
              ,.AXI_WIDTH_DS   (WIDTH_DS )// data strobe width
              ,.ADDR_LENGTH(ADDR_LENGTH0) // effective addre bits
             )
   u_mem  (
          .ARESETn  (ARESETn           )
        , .ACLK     (ACLK              )
        , .AWID     (MEM_AWID          )
        , .AWADDR   (MEM_AWADDR        )
        , .AWLEN    (MEM_AWLEN         )
        , .AWLOCK   (MEM_AWLOCK        )
        , .AWSIZE   (MEM_AWSIZE        )
        , .AWBURST  (MEM_AWBURST       )
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE  (MEM_AWCACHE       )
        `endif
        `ifdef AMBA_AXI_PROT
        , .AWPROT   (MEM_AWPROT        )
        `endif
        , .AWVALID  (MEM_AWVALID       )
        , .AWREADY  (MEM_AWREADY       )
        `ifdef AMBA_AXI4
        , .AWQOS    (MEM_AWQOS         )
        , .AWREGION (MEM_AWREGION      )
        `endif
        , .WID      (MEM_WID           )
        , .WDATA    (MEM_WDATA         )
        , .WSTRB    (MEM_WSTRB         )
        , .WLAST    (MEM_WLAST         )
        , .WVALID   (MEM_WVALID        )
        , .WREADY   (MEM_WREADY        )
        , .BID      (MEM_BID           )
        , .BRESP    (MEM_BRESP         )
        , .BVALID   (MEM_BVALID        )
        , .BREADY   (MEM_BREADY        )
        , .ARID     (MEM_ARID          )
        , .ARADDR   (MEM_ARADDR        )
        , .ARLEN    (MEM_ARLEN         )
        , .ARLOCK   (MEM_ARLOCK        )
        , .ARSIZE   (MEM_ARSIZE        )
        , .ARBURST  (MEM_ARBURST       )
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE  (MEM_ARCACHE       )
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT   (MEM_ARPROT        )
        `endif
        , .ARVALID  (MEM_ARVALID       )
        , .ARREADY  (MEM_ARREADY       )
        `ifdef AMBA_AXI4
        , .ARQOS    (MEM_ARQOS         )
        , .ARREGION (MEM_ARREGION      )
        `endif
        , .RID      (MEM_RID           )
        , .RDATA    (MEM_RDATA         )
        , .RRESP    (MEM_RRESP         )
        , .RLAST    (MEM_RLAST         )
        , .RVALID   (MEM_RVALID        )
        , .RREADY   (MEM_RREADY        )
        , .CSYSREQ  (1'b1              )
        , .CSYSACK  ()
        , .CACTIVE  ()
   );
   //---------------------------------------------------------
   always #5 ACLK = ~ACLK;
   initial begin
       ACLK    = 0;
       ARESETn = 0;
       repeat (2) @ (posedge ACLK);
       ARESETn = 1;
       repeat (5) @ (posedge ACLK);
repeat (1000) @ (posedge ACLK);
$finish(2);
       wait(u_bfm_axi.DONE==1'b1);
       repeat (5) @ (posedge ACLK);
       repeat (50) @ (posedge ACLK);
       $finish(2);
   end
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpvars(0);
   end
   `endif
   //---------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.07.12: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
