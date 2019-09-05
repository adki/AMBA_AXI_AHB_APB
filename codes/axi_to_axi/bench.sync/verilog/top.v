//----------------------------------------------------------------
//  Copyright (c) 2010-2011-2015 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// top.v
//----------------------------------------------------------------
// VERSION: 2015.08.15.
//----------------------------------------------------------------
`timescale 1ns/1ns

`ifndef WIDTH_CID
`define WIDTH_CID 4
`endif
`ifndef WIDTH_ID
`define WIDTH_ID 4
`endif
`ifndef WIDTH_AD
`define WIDTH_AD 32
`endif
`ifndef WIDTH_DA
`define WIDTH_DA 32
`endif
`ifndef ADDR_LENGTH
`define ADDR_LENGTH 12
`endif

module top ;
   //---------------------------------------------------------
   parameter  WIDTH_CID  =`WIDTH_CID  // Channel ID width in bits
            , WIDTH_ID   =`WIDTH_ID   // ID width in bits
            , WIDTH_AD   =`WIDTH_AD   // address width
            , WIDTH_DA   =`WIDTH_DA   // data width
            , WIDTH_DS   =(WIDTH_DA/8)   // data strobe width
            , WIDTH_DSB  =clogb2(WIDTH_DS)  // 
            , WIDTH_SID  =(WIDTH_CID+WIDTH_ID)
            , ADDR_LENGTH=`ADDR_LENGTH;
   //---------------------------------------------------------
   reg                  ARESETn  = 1'b0;
   //---------------------------------------------------------
   `ifndef ACLK_FREQ
   `define ACLK_FREQ   50000000.0 // 50Mhz
   `endif
   localparam real ACLK_FREQ   = `ACLK_FREQ,
                   ACLK_PERIOD = 1000000000.0/ACLK_FREQ;// nsec
   reg                  ACLK   = 1'b0;
   always #(ACLK_PERIOD/2.0) ACLK <= ~ACLK;
   //---------------------------------------------------------
   //     +-------+                           +----------------+      +----------------+
   //     | BFM   |                           | bridge         |      | slave          |
   //     |       +---> S_MID [CID] ---+      |                |      |                |
   //     |       |                    |      |                |      |                |
   //     |       +---> S_AWID[ ID] ---+----->+ AWID[CID+ID]   +----->+ AWID[CID+ID]   |
   //     |       |                    |      |                |      |                |
   //     |       +---> S_WID [ ID] ---+----->+ WID [CID+ID]   +----->+ WID [CID+ID]   |
   //     |       |                           |                |      |                |
   //     |       +<--- S_BID'[ ID] <--+------+ BID [CID+ID]   +<-----+ BID [CID+ID]   |
   //     |       |                    |      |                |      |                |
   //     |       |                           |                |      |                |
   //     |       +---> S_MID [CID] ---+      |                |      |                |
   //     |       |                    |      |                |      |                |
   //     |       +---> S_ARID[ ID] ---+----->+ ARID[CID+ID]   +----->+ ARID[CID+ID]   |
   //     |       |                           |                |      |                |
   //     |       +<--- S_RID'[ ID] <--+------+ RID [CID+ID]   +<-----+ RID [CID+ID]   |
   //     |       |                    |      |                |      |                |
   //     |       |                           |                |      |                |
   //     +-------+                           +----------------+      +----------------+
   //---------------------------------------------------------
   wire [WIDTH_CID-1:0]              S_MID      ; // note that it is from bfm-bridge
   wire [WIDTH_SID-1:0] M_AWID                  ; // note that it is for bridge-slave
   wire [WIDTH_ID-1:0]               S_AWID     ; // note that it is for bfm-bridge
   wire [WIDTH_AD-1:0]  M_AWADDR   , S_AWADDR   ;
   `ifdef AMBA_AXI4
   wire [ 7:0]          M_AWLEN    , S_AWLEN    ;
   wire                 M_AWLOCK   , S_AWLOCK   ;
   `else
   wire [ 3:0]          M_AWLEN    , S_AWLEN    ;
   wire [ 1:0]          M_AWLOCK   , S_AWLOCK   ;
   `endif
   wire [ 2:0]          M_AWSIZE   , S_AWSIZE   ;
   wire [ 1:0]          M_AWBURST  , S_AWBURST  ;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]          M_AWCACHE  , S_AWCACHE  ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]          M_AWPROT   , S_AWPROT   ;
   `endif
   wire                 M_AWVALID  , S_AWVALID  ;
   wire                 M_AWREADY  , S_AWREADY  ;
   `ifdef AMBA_AXI4
   wire [ 3:0]          M_AWQOS    , S_AWQOS    ;
   wire [ 3:0]          M_AWREGION , S_AWREGION ;
   `endif
   wire [WIDTH_SID-1:0] M_WID                   ;
   wire [WIDTH_ID-1:0]               S_WID      ;
   wire [WIDTH_DA-1:0]  M_WDATA    , S_WDATA    ;
   wire [WIDTH_DS-1:0]  M_WSTRB    , S_WSTRB    ;
   wire                 M_WLAST    , S_WLAST    ;
   wire                 M_WVALID   , S_WVALID   ;
   wire                 M_WREADY   , S_WREADY   ;
   wire [WIDTH_SID-1:0] M_BID                   ;
   wire [WIDTH_SID-1:0]              S_BID      ;
   wire [ 1:0]          M_BRESP    , S_BRESP    ;
   wire                 M_BVALID   , S_BVALID   ;
   wire                 M_BREADY   , S_BREADY   ;
   wire [WIDTH_SID-1:0] M_ARID                  ;
   wire [WIDTH_ID-1:0]               S_ARID     ;
   wire [WIDTH_AD-1:0]  M_ARADDR   , S_ARADDR   ;
   `ifdef AMBA_AXI4
   wire [ 7:0]          M_ARLEN    , S_ARLEN    ;
   wire                 M_ARLOCK   , S_ARLOCK   ;
   `else
   wire [ 3:0]          M_ARLEN    , S_ARLEN    ;
   wire [ 1:0]          M_ARLOCK   , S_ARLOCK   ;
   `endif
   wire [ 2:0]          M_ARSIZE   , S_ARSIZE   ;
   wire [ 1:0]          M_ARBURST  , S_ARBURST  ;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]          M_ARCACHE  , S_ARCACHE  ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]          M_ARPROT   , S_ARPROT   ;
   `endif
   wire                 M_ARVALID  , S_ARVALID  ;
   wire                 M_ARREADY  , S_ARREADY  ;
   `ifdef AMBA_AXI4
   wire [ 3:0]          M_ARQOS    , S_ARQOS    ;
   wire [ 3:0]          M_ARREGION , S_ARREGION ;
   `endif
   wire [WIDTH_SID-1:0] M_RID                   ;
   wire [WIDTH_SID-1:0]              S_RID      ;
   wire [WIDTH_DA-1:0]  M_RDATA    , S_RDATA    ;
   wire [ 1:0]          M_RRESP    , S_RRESP    ;
   wire                 M_RLAST    , S_RLAST    ;
   wire                 M_RVALID   , S_RVALID   ;
   wire                 M_RREADY   , S_RREADY   ;
   //---------------------------------------------------------
   axi_bridge_sync #(.AXI_WIDTH_CID(WIDTH_CID)// Channel ID
                    ,.AXI_WIDTH_ID (WIDTH_ID )// ID width in bits
                    ,.AXI_WIDTH_AD (WIDTH_AD )// address width
                    ,.AXI_WIDTH_DA (WIDTH_DA )// data width
                    )
   Uaxi_bridge (
       .ARESETn                    (ARESETn        )
     , .ACLK                       (ACLK           )
     , .S_AWID                     ({S_MID,S_AWID} )
     , .S_AWADDR                   (S_AWADDR       )
     `ifdef AMBA_AXI4
     , .S_AWLEN                    (S_AWLEN        )
     , .S_AWLOCK                   (S_AWLOCK       )
     `else
     , .S_AWLEN                    (S_AWLEN        )
     , .S_AWLOCK                   (S_AWLOCK       )
     `endif
     , .S_AWSIZE                   (S_AWSIZE       )
     , .S_AWBURST                  (S_AWBURST      )
     `ifdef AMBA_AXI_CACHE
     , .S_AWCACHE                  (S_AWCACHE      )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_AWPROT                   (S_AWPROT       )
     `endif
     , .S_AWVALID                  (S_AWVALID      )
     , .S_AWREADY                  (S_AWREADY      )
     `ifdef AMBA_AXI4
     , .S_AWQOS                    (S_AWQOS        )
     , .S_AWREGION                 (S_AWREGION     )
     `endif
     , .S_WID                      ({S_MID,S_WID}  )
     , .S_WDATA                    (S_WDATA        )
     , .S_WSTRB                    (S_WSTRB        )
     , .S_WLAST                    (S_WLAST        )
     , .S_WVALID                   (S_WVALID       )
     , .S_WREADY                   (S_WREADY       )
     , .S_BID                      (S_BID          )
     , .S_BRESP                    (S_BRESP        )
     , .S_BVALID                   (S_BVALID       )
     , .S_BREADY                   (S_BREADY       )
     , .S_ARID                     ({S_MID,S_ARID} )
     , .S_ARADDR                   (S_ARADDR       )
     `ifdef AMBA_AXI4
     , .S_ARLEN                    (S_ARLEN        )
     , .S_ARLOCK                   (S_ARLOCK       )
     `else
     , .S_ARLEN                    (S_ARLEN        )
     , .S_ARLOCK                   (S_ARLOCK       )
     `endif
     , .S_ARSIZE                   (S_ARSIZE       )
     , .S_ARBURST                  (S_ARBURST      )
     `ifdef AMBA_AXI_CACHE
     , .S_ARCACHE                  (S_ARCACHE      )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_ARPROT                   (S_ARPROT       )
     `endif
     , .S_ARVALID                  (S_ARVALID      )
     , .S_ARREADY                  (S_ARREADY      )
     `ifdef AMBA_AXI4
     , .S_ARQOS                    (S_ARQOS        )
     , .S_ARREGION                 (S_ARREGION     )
     `endif
     , .S_RID                      (S_RID          )
     , .S_RDATA                    (S_RDATA        )
     , .S_RRESP                    (S_RRESP        )
     , .S_RLAST                    (S_RLAST        )
     , .S_RVALID                   (S_RVALID       )
     , .S_RREADY                   (S_RREADY       )
     , .M_AWID                     (M_AWID         )
     , .M_AWADDR                   (M_AWADDR       )
     `ifdef AMBA_AXI4
     , .M_AWLEN                    (M_AWLEN        )
     , .M_AWLOCK                   (M_AWLOCK       )
     `else
     , .M_AWLEN                    (M_AWLEN        )
     , .M_AWLOCK                   (M_AWLOCK       )
     `endif
     , .M_AWSIZE                   (M_AWSIZE       )
     , .M_AWBURST                  (M_AWBURST      )
     `ifdef AMBA_AXI_CACHE
     , .M_AWCACHE                  (M_AWCACHE      )
     `endif
     `ifdef AMBA_AXI_PROT
     , .M_AWPROT                   (M_AWPROT       )
     `endif
     , .M_AWVALID                  (M_AWVALID      )
     , .M_AWREADY                  (M_AWREADY      )
     `ifdef AMBA_AXI4
     , .M_AWQOS                    (M_AWQOS        )
     , .M_AWREGION                 (M_AWREGION     )
     `endif
     , .M_WID                      (M_WID          )
     , .M_WDATA                    (M_WDATA        )
     , .M_WSTRB                    (M_WSTRB        )
     , .M_WLAST                    (M_WLAST        )
     , .M_WVALID                   (M_WVALID       )
     , .M_WREADY                   (M_WREADY       )
     , .M_BID                      (M_BID          )
     , .M_BRESP                    (M_BRESP        )
     , .M_BVALID                   (M_BVALID       )
     , .M_BREADY                   (M_BREADY       )
     , .M_ARID                     (M_ARID         )
     , .M_ARADDR                   (M_ARADDR       )
     `ifdef AMBA_AXI4
     , .M_ARLEN                    (M_ARLEN        )
     , .M_ARLOCK                   (M_ARLOCK       )
     `else
     , .M_ARLEN                    (M_ARLEN        )
     , .M_ARLOCK                   (M_ARLOCK       )
     `endif
     , .M_ARSIZE                   (M_ARSIZE       )
     , .M_ARBURST                  (M_ARBURST      )
     `ifdef AMBA_AXI_CACHE
     , .M_ARCACHE                  (M_ARCACHE      )
     `endif
     `ifdef AMBA_AXI_PROT
     , .M_ARPROT                   (M_ARPROT       )
     `endif
     , .M_ARVALID                  (M_ARVALID      )
     , .M_ARREADY                  (M_ARREADY      )
     `ifdef AMBA_AXI4
     , .M_ARQOS                    (M_ARQOS        )
     , .M_ARREGION                 (M_ARREGION     )
     `endif
     , .M_RID                      (M_RID          )
     , .M_RDATA                    (M_RDATA        )
     , .M_RRESP                    (M_RRESP        )
     , .M_RLAST                    (M_RLAST        )
     , .M_RVALID                   (M_RVALID       )
     , .M_RREADY                   (M_RREADY       )
   );
   //---------------------------------------------------------
   bfm_axi #(.MST_ID   (2        ) // Master ID
            ,.WIDTH_CID(WIDTH_CID)
            ,.WIDTH_ID (WIDTH_ID ) // ID width in bits
            ,.WIDTH_AD (WIDTH_AD ) // address width
            ,.WIDTH_DA (WIDTH_DA ))// data width
   u_bfm_axi (
         .ARESETn            (ARESETn      )
       , .ACLK               (ACLK         )
       , .MID                (S_MID        )
       , .AWID               (S_AWID[WIDTH_ID-1:0])
       , .AWADDR             (S_AWADDR     )
       , .AWLEN              (S_AWLEN      )
       , .AWLOCK             (S_AWLOCK     )
       , .AWSIZE             (S_AWSIZE     )
       , .AWBURST            (S_AWBURST    )
       `ifdef AMBA_AXI_CACHE
       , .AWCACHE            (S_AWCACHE    )
       `endif
       `ifdef AMBA_AXI_PROT
       , .AWPROT             (S_AWPROT     )
       `endif
       , .AWVALID            (S_AWVALID    )
       , .AWREADY            (S_AWREADY    )
       `ifdef AMBA_AXI4
       , .AWQOS              (S_AWQOS      )
       , .AWREGION           (S_AWREGION   )
       `endif
       , .WID                (S_WID[WIDTH_ID-1:0])
       , .WDATA              (S_WDATA      )
       , .WSTRB              (S_WSTRB      )
       , .WLAST              (S_WLAST      )
       , .WVALID             (S_WVALID     )
       , .WREADY             (S_WREADY     )
       , .BID                (S_BID[WIDTH_ID-1:0])
       , .BRESP              (S_BRESP      )
       , .BVALID             (S_BVALID     )
       , .BREADY             (S_BREADY     )
       , .ARID               (S_ARID[WIDTH_ID-1:0])
       , .ARADDR             (S_ARADDR     )
       , .ARLEN              (S_ARLEN      )
       , .ARLOCK             (S_ARLOCK     )
       , .ARSIZE             (S_ARSIZE     )
       , .ARBURST            (S_ARBURST    )
       `ifdef AMBA_AXI_CACHE
       , .ARCACHE            (S_ARCACHE    )
       `endif
       `ifdef AMBA_AXI_PROT
       , .ARPROT             (S_ARPROT     )
       `endif
       , .ARVALID            (S_ARVALID    )
       , .ARREADY            (S_ARREADY    )
       `ifdef AMBA_AXI4
       , .ARQOS              (S_ARQOS      )
       , .ARREGION           (S_ARREGION   )
       `endif
       , .RID                (S_RID[WIDTH_ID-1:0])
       , .RDATA              (S_RDATA      )
       , .RRESP              (S_RRESP      )
       , .RLAST              (S_RLAST      )
       , .RVALID             (S_RVALID     )
       , .RREADY             (S_RREADY     )
       , .CSYSREQ            (1'b1         )
       , .CSYSACK            (             )
       , .CACTIVE            (             )
   );
   //---------------------------------------------------------
   axi_slave #(.WIDTH_CID(WIDTH_CID  ) // Channel ID width in bits
              ,.WIDTH_ID (WIDTH_ID   ) // ID width in bits
              ,.WIDTH_AD (WIDTH_AD   ) // address width
              ,.WIDTH_DA (WIDTH_DA   ) // data width
              ,.ADDR_LENGTH  (ADDR_LENGTH) // effective addre bits
              )
   Uaxi_slave
   (
       .ARESETn       (ARESETn  )
     , .ACLK          (ACLK     )
     , .AWID          (M_AWID   )
     , .AWADDR        (M_AWADDR )
     , .AWLEN         (M_AWLEN  )
     , .AWLOCK        (M_AWLOCK )
     , .AWSIZE        (M_AWSIZE )
     , .AWBURST       (M_AWBURST)
     `ifdef AMBA_AXI_CACHE
     , .AWCACHE       (M_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .AWPROT        (M_AWPROT )
     `endif
     , .AWVALID       (M_AWVALID)
     , .AWREADY       (M_AWREADY)
     `ifdef AMBA_AXI4
     , .AWQOS         (M_AWQOS   )
     , .AWREGION      (M_AWREGION)
     `endif
     , .WID           (M_WID   )
     , .WDATA         (M_WDATA )
     , .WSTRB         (M_WSTRB )
     , .WLAST         (M_WLAST )
     , .WVALID        (M_WVALID)
     , .WREADY        (M_WREADY)
     , .BID           (M_BID   )
     , .BRESP         (M_BRESP )
     , .BVALID        (M_BVALID)
     , .BREADY        (M_BREADY)
     , .ARID          (M_ARID  )
     , .ARADDR        (M_ARADDR)
     , .ARLEN         (M_ARLEN )
     , .ARLOCK        (M_ARLOCK)
     , .ARSIZE        (M_ARSIZE )
     , .ARBURST       (M_ARBURST)
     `ifdef AMBA_AXI_CACHE
     , .ARCACHE       (M_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .ARPROT        (M_ARPROT )
     `endif
     , .ARVALID       (M_ARVALID)
     , .ARREADY       (M_ARREADY)
     `ifdef AMBA_AXI4
     , .ARQOS         (M_ARQOS   )
     , .ARREGION      (M_ARREGION)
     `endif
     , .RID           (M_RID    )
     , .RDATA         (M_RDATA  )
     , .RRESP         (M_RRESP  )
     , .RLAST         (M_RLAST  )
     , .RVALID        (M_RVALID )
     , .RREADY        (M_RREADY )
     , .CSYSREQ       (1'b1     )
     , .CSYSACK       (         )
     , .CACTIVE       (         )
   );
   //---------------------------------------------------------
   initial begin
       ACLK    = 0;
       ARESETn = 0;
       repeat (3) @ (negedge ACLK);
       ARESETn = 1;
       repeat (3) @ (negedge ACLK);
       //---------------------------------------------------------
       wait (u_bfm_axi.DONE==1'b1);
       //---------------------------------------------------------
       repeat (10) @ (negedge ACLK);
       $finish(2);
   end
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd"); //$dumplimit(1000000);
       $dumpvars(0);
   end
   `endif
   //----------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
     tmp = value - 1;
     for (clogb2=0; tmp>0; clogb2=clogb2+1) tmp = tmp>>1;
   end
   endfunction
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.08.15: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
