//----------------------------------------------------------------
//  Copyright (c) 2013 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// top.v
//----------------------------------------------------------------
// VERSION: 2013.02.03.
//----------------------------------------------------------------
`timescale 1ns/1ns

`ifndef WIDTH_AD
`define WIDTH_AD   32 // address width
`endif
`ifndef WIDTH_DA
`define WIDTH_DA   32 // data width
`endif
`ifndef ADDR_LENGTH
`define ADDR_LENGTH 12
`endif

module top ;
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
   end
   `endif
   //---------------------------------------------------------
   localparam WIDTH_CID   = 0    // Channel ID width in bits; it should be 0 since no AXI matrix
            , WIDTH_ID    = 4    // ID width in bits
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
   reg                      ARESETn;
   reg                      ACLK   ;
   //--------------------------------------------------------------
   wire  [WIDTH_CID-1:0]     MID        ;
   wire  [WIDTH_ID-1:0]      AWID       ;
   wire  [WIDTH_AD-1:0]      AWADDR     ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]              AWLEN      ;
   wire                      AWLOCK     ;
   `else
   wire  [ 3:0]              AWLEN      ;
   wire  [ 1:0]              AWLOCK     ;
   `endif
   wire  [ 2:0]              AWSIZE     ;
   wire  [ 1:0]              AWBURST    ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]              AWCACHE    ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]              AWPROT     ;
   `endif
   wire                      AWVALID    ;
   wire                      AWREADY    ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]              AWQOS      ;
   wire  [ 3:0]              AWREGION   ;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [WIDTH_AWUSER-1:0]  AWUSER     ;
   `endif
   wire  [WIDTH_ID-1:0]      WID        ;
   wire  [WIDTH_DA-1:0]      WDATA      ;
   wire  [WIDTH_DS-1:0]      WSTRB      ;
   wire                      WLAST      ;
   wire                      WVALID     ;
   wire                      WREADY     ;
   `ifdef AMBA_AXI_WUSER
   wire  [WIDTH_WUSER-1:0]   WUSER      ;
   `endif
   wire  [WIDTH_ID-1:0]      BID        ;
   wire  [ 1:0]              BRESP      ;
   wire                      BVALID     ;
   wire                      BREADY     ;
   `ifdef AMBA_AXI_BUSER
   wire  [WIDTH_BUSER-1:0]   BUSER      ;
   `endif
   wire  [WIDTH_ID-1:0]      ARID       ;
   wire  [WIDTH_AD-1:0]      ARADDR     ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]              ARLEN      ;
   wire                      ARLOCK     ;
   `else
   wire  [ 3:0]              ARLEN      ;
   wire  [ 1:0]              ARLOCK     ;
   `endif
   wire  [ 2:0]              ARSIZE     ;
   wire  [ 1:0]              ARBURST    ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]              ARCACHE    ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]              ARPROT     ;
   `endif
   wire                      ARVALID    ;
   wire                      ARREADY    ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]              ARQOS      ;
   wire  [ 3:0]              ARREGION   ;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [WIDTH_ARUSER-1:0]  ARUSER     ;
   `endif
   wire  [WIDTH_ID-1:0]      RID        ;
   wire  [WIDTH_DA-1:0]      RDATA      ;
   wire  [ 1:0]              RRESP      ;
   wire                      RLAST      ;
   wire                      RVALID     ;
   wire                      RREADY     ;
   `ifdef AMBA_AXI_RUSER
   wire  [WIDTH_RUSER-1:0]   RUSER      ;
   `endif
   reg                       CSYSREQ    ;
   wire                      CSYSACKbfm ;
   wire                      CACTIVEbfm ;
   wire                      CSYSACKmem ;
   wire                      CACTIVEmem ;
   //---------------------------------------------------------
        bfm_axi    #(.MST_ID   (0        ) // Master ID
                    ,.WIDTH_CID(WIDTH_CID)
                    ,.WIDTH_ID (WIDTH_ID ) // ID width in bits
                    ,.WIDTH_AD (WIDTH_AD ) // address width
                    ,.WIDTH_DA (WIDTH_DA ))// data width
        u_bfm_axi(
              .ARESETn   (ARESETn        )
            , .ACLK      (ACLK           )
            , .MID       (MID          )
            , .AWID      (AWID         )
            , .AWADDR    (AWADDR       )
            , .AWLEN     (AWLEN        )
            , .AWLOCK    (AWLOCK       )
            , .AWSIZE    (AWSIZE       )
            , .AWBURST   (AWBURST      )
   `ifdef AMBA_AXI_CACHE
            , .AWCACHE   (AWCACHE      )
   `endif
   `ifdef AMBA_AXI_PROT
            , .AWPROT    (AWPROT       )
   `endif
            , .AWVALID   (AWVALID      )
            , .AWREADY   (AWREADY      )
        `ifdef AMBA_AXI4
            , .AWQOS     (AWQOS        )
            , .AWREGION  (AWREGION     )
        `endif
            , .WID       (WID          )
            , .WDATA     (WDATA        )
            , .WSTRB     (WSTRB        )
            , .WLAST     (WLAST        )
            , .WVALID    (WVALID       )
            , .WREADY    (WREADY       )
            , .BID       (BID          )
            , .BRESP     (BRESP        )
            , .BVALID    (BVALID       )
            , .BREADY    (BREADY       )
            , .ARID      (ARID         )
            , .ARADDR    (ARADDR       )
            , .ARLEN     (ARLEN        )
            , .ARLOCK    (ARLOCK       )
            , .ARSIZE    (ARSIZE       )
            , .ARBURST   (ARBURST      )
   `ifdef AMBA_AXI_CACHE
            , .ARCACHE   (ARCACHE      )
   `endif
   `ifdef AMBA_AXI_PROT
            , .ARPROT    (ARPROT       )
   `endif
            , .ARVALID   (ARVALID      )
            , .ARREADY   (ARREADY      )
        `ifdef AMBA_AXI4
            , .ARQOS     (ARQOS        )
            , .ARREGION  (ARREGION     )
        `endif
            , .RID       (RID          )
            , .RDATA     (RDATA        )
            , .RRESP     (RRESP        )
            , .RLAST     (RLAST        )
            , .RVALID    (RVALID       )
            , .RREADY    (RREADY       )
            , .CSYSREQ   (CSYSREQ      )
            , .CSYSACK   (CSYSACKbfm   )
            , .CACTIVE   (CACTIVEbfm   )
        );
   //---------------------------------------------------------
        mem_axi   #(.AXI_WIDTH_CID  (WIDTH_CID)// Channel ID width in bits
                   ,.AXI_WIDTH_ID   (WIDTH_ID )// ID width in bits
                   ,.AXI_WIDTH_AD   (WIDTH_AD )// address width
                   ,.AXI_WIDTH_DA   (WIDTH_DA )// data width
                   ,.AXI_WIDTH_DS   (WIDTH_DS )// data strobe width
                   ,.ADDR_LENGTH(ADDR_LENGTH0) // effective addre bits
                  )
        u_mem_axi  (
               .ARESETn  (ARESETn         )
             , .ACLK     (ACLK            )
             , .AWID     (AWID          )
             , .AWADDR   (AWADDR        )
             , .AWLEN    (AWLEN         )
             , .AWLOCK   (AWLOCK        )
             , .AWSIZE   (AWSIZE        )
             , .AWBURST  (AWBURST       )
   `ifdef AMBA_AXI_CACHE
             , .AWCACHE  (AWCACHE       )
   `endif
   `ifdef AMBA_AXI_PROT
             , .AWPROT   (AWPROT        )
   `endif
             , .AWVALID  (AWVALID       )
             , .AWREADY  (AWREADY       )
        `ifdef AMBA_AXI4
             , .AWQOS    (AWQOS         )
             , .AWREGION (AWREGION      )
        `endif
             , .WID      (WID           )
             , .WDATA    (WDATA         )
             , .WSTRB    (WSTRB         )
             , .WLAST    (WLAST         )
             , .WVALID   (WVALID        )
             , .WREADY   (WREADY        )
             , .BID      (BID           )
             , .BRESP    (BRESP         )
             , .BVALID   (BVALID        )
             , .BREADY   (BREADY        )
             , .ARID     (ARID          )
             , .ARADDR   (ARADDR        )
             , .ARLEN    (ARLEN         )
             , .ARLOCK   (ARLOCK        )
             , .ARSIZE   (ARSIZE        )
             , .ARBURST  (ARBURST       )
   `ifdef AMBA_AXI_CACHE
             , .ARCACHE  (ARCACHE       )
   `endif
   `ifdef AMBA_AXI_PROT
             , .ARPROT   (ARPROT        )
   `endif
             , .ARVALID  (ARVALID       )
             , .ARREADY  (ARREADY       )
        `ifdef AMBA_AXI4
             , .ARQOS    (ARQOS         )
             , .ARREGION (ARREGION      )
        `endif
             , .RID      (RID           )
             , .RDATA    (RDATA         )
             , .RRESP    (RRESP         )
             , .RLAST    (RLAST         )
             , .RVALID   (RVALID        )
             , .RREADY   (RREADY        )
             , .CSYSREQ  (CSYSREQ       )
             , .CSYSACK  (CSYSACKmem    )
             , .CACTIVE  (CACTIVEmem    )
        );
   //---------------------------------------------------------
   always #5 ACLK = ~ACLK;
   initial begin
       ACLK    = 0;
       ARESETn = 0;
       CSYSREQ = 1;
       repeat (2) @ (posedge ACLK);
       ARESETn = 1;
       repeat (2) @ (posedge ACLK);
       wait((CACTIVEbfm==1'b1)&&(CACTIVEmem==1'b1));
       repeat (5) @ (posedge ACLK);
       wait(u_bfm_axi.DONE==1'b1);
       repeat (5) @ (posedge ACLK);
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
// 2013.02.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
