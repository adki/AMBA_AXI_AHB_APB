//--------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//--------------------------------------------------------
// axi_bridge_sync.v
//--------------------------------------------------------
// VERSION = 2012.01.02.
//--------------------------------------------------------
// NOTE
//--------------------------------------------------------
`include "axi_bridge_sync_fifo.v"
`include "axi_bridge_core.v"
`timescale 1ns/1ns

module axi_bridge_sync
     #(parameter AXI_WIDTH_CID=4         // Channel ID
               , AXI_WIDTH_ID =4         // ID width in bits
               , AXI_WIDTH_AD =32        // address width
               , AXI_WIDTH_DA =32        // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] S_AWID
     , input  wire [AXI_WIDTH_AD-1:0]  S_AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S_AWLEN
     , input  wire                     S_AWLOCK
     `else
     , input  wire [ 3:0]              S_AWLEN
     , input  wire [ 1:0]              S_AWLOCK
     `endif
     , input  wire [ 2:0]              S_AWSIZE
     , input  wire [ 1:0]              S_AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S_AWPROT
     `endif
     , input  wire                     S_AWVALID
     , output wire                     S_AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S_AWQOS
     , input  wire [ 3:0]              S_AWREGION
     `endif
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] S_WID
     , input  wire [AXI_WIDTH_DA-1:0]  S_WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  S_WSTRB
     , input  wire                     S_WLAST
     , input  wire                     S_WVALID
     , output wire                     S_WREADY
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] S_BID
     , output wire [ 1:0]              S_BRESP
     , output wire                     S_BVALID
     , input  wire                     S_BREADY
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] S_ARID
     , input  wire [AXI_WIDTH_AD-1:0]  S_ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S_ARLEN
     , input  wire                     S_ARLOCK
     `else
     , input  wire [ 3:0]              S_ARLEN
     , input  wire [ 1:0]              S_ARLOCK
     `endif
     , input  wire [ 2:0]              S_ARSIZE
     , input  wire [ 1:0]              S_ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S_ARPROT
     `endif
     , input  wire                     S_ARVALID
     , output wire                     S_ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S_ARQOS
     , input  wire [ 3:0]              S_ARREGION
     `endif
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] S_RID
     , output wire [AXI_WIDTH_DA-1:0]  S_RDATA
     , output wire [ 1:0]              S_RRESP
     , output wire                     S_RLAST
     , output wire                     S_RVALID
     , input  wire                     S_RREADY
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] M_AWID
     , output wire [AXI_WIDTH_AD-1:0]  M_AWADDR
     `ifdef AMBA_AXI4
     , output wire [ 7:0]              M_AWLEN
     , output wire                     M_AWLOCK
     `else
     , output wire [ 3:0]              M_AWLEN
     , output wire [ 1:0]              M_AWLOCK
     `endif
     , output wire [ 2:0]              M_AWSIZE
     , output wire [ 1:0]              M_AWBURST
     `ifdef AMBA_AXI_CACHE
     , output wire [ 3:0]              M_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output wire [ 2:0]              M_AWPROT
     `endif
     , output wire                     M_AWVALID
     , input  wire                     M_AWREADY
     `ifdef AMBA_AXI4
     , output wire [ 3:0]              M_AWQOS
     , output wire [ 3:0]              M_AWREGION
     `endif
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] M_WID
     , output wire [AXI_WIDTH_DA-1:0]  M_WDATA
     , output wire [AXI_WIDTH_DS-1:0]  M_WSTRB
     , output wire                     M_WLAST
     , output wire                     M_WVALID
     , input  wire                     M_WREADY
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] M_BID
     , input  wire [ 1:0]              M_BRESP
     , input  wire                     M_BVALID
     , output wire                     M_BREADY
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] M_ARID
     , output wire [AXI_WIDTH_AD-1:0]  M_ARADDR
     `ifdef AMBA_AXI4
     , output wire [ 7:0]              M_ARLEN
     , output wire                     M_ARLOCK
     `else
     , output wire [ 3:0]              M_ARLEN
     , output wire [ 1:0]              M_ARLOCK
     `endif
     , output wire [ 2:0]              M_ARSIZE
     , output wire [ 1:0]              M_ARBURST
     `ifdef AMBA_AXI_CACHE
     , output wire [ 3:0]              M_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output wire [ 2:0]              M_ARPROT
     `endif
     , output wire                     M_ARVALID
     , input  wire                     M_ARREADY
     `ifdef AMBA_AXI4
     , output wire [ 3:0]              M_ARQOS
     , output wire [ 3:0]              M_ARREGION
     `endif
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] M_RID
     , input  wire [AXI_WIDTH_DA-1:0]  M_RDATA
     , input  wire [ 1:0]              M_RRESP
     , input  wire                     M_RLAST
     , input  wire                     M_RVALID
     , output wire                     M_RREADY
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     axi_bridge_core #(.AXI_WIDTH_CID(AXI_WIDTH_CID) // Channel ID
                      ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                      ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                      ,.AXI_WIDTH_DA (AXI_WIDTH_DA ) // data width
                      ,.ASYNC        (1'b0         )
                      )
     Uaxi_bridge_core (
                                       .ARESETn         (ARESETn     )
                                      ,.S_ACLK          (ACLK        )
                                      ,.S_AWID          (S_AWID      )
                                      ,.S_AWADDR        (S_AWADDR    )
     `ifdef AMBA_AXI4
                                      ,.S_AWLEN         (S_AWLEN     )
                                      ,.S_AWLOCK        (S_AWLOCK    )
     `else
                                      ,.S_AWLEN         (S_AWLEN     )
                                      ,.S_AWLOCK        (S_AWLOCK    )
     `endif
                                      ,.S_AWSIZE        (S_AWSIZE    )
                                      ,.S_AWBURST       (S_AWBURST   )
     `ifdef AMBA_AXI_CACHE
                                      ,.S_AWCACHE       (S_AWCACHE   )
     `endif
     `ifdef AMBA_AXI_PROT
                                      ,.S_AWPROT        (S_AWPROT    )
     `endif
                                      ,.S_AWVALID       (S_AWVALID   )
                                      ,.S_AWREADY       (S_AWREADY   )
     `ifdef AMBA_AXI4
                                      ,.S_AWQOS         (S_AWQOS     )
                                      ,.S_AWREGION      (S_AWREGION  )
     `endif
                                      ,.S_WID           (S_WID       )
                                      ,.S_WDATA         (S_WDATA     )
                                      ,.S_WSTRB         (S_WSTRB     )
                                      ,.S_WLAST         (S_WLAST     )
                                      ,.S_WVALID        (S_WVALID    )
                                      ,.S_WREADY        (S_WREADY    )
                                      ,.S_BID           (S_BID       )
                                      ,.S_BRESP         (S_BRESP     )
                                      ,.S_BVALID        (S_BVALID    )
                                      ,.S_BREADY        (S_BREADY    )
                                      ,.S_ARID          (S_ARID      )
                                      ,.S_ARADDR        (S_ARADDR    )
     `ifdef AMBA_AXI4
                                      ,.S_ARLEN         (S_ARLEN     )
                                      ,.S_ARLOCK        (S_ARLOCK    )
     `else
                                      ,.S_ARLEN         (S_ARLEN     )
                                      ,.S_ARLOCK        (S_ARLOCK    )
     `endif
                                      ,.S_ARSIZE        (S_ARSIZE    )
                                      ,.S_ARBURST       (S_ARBURST   )
     `ifdef AMBA_AXI_CACHE
                                      ,.S_ARCACHE       (S_ARCACHE   )
     `endif
     `ifdef AMBA_AXI_PROT
                                      ,.S_ARPROT        (S_ARPROT    )
     `endif
                                      ,.S_ARVALID       (S_ARVALID   )
                                      ,.S_ARREADY       (S_ARREADY   )
     `ifdef AMBA_AXI4
                                      ,.S_ARQOS         (S_ARQOS     )
                                      ,.S_ARREGION      (S_ARREGION  )
     `endif
                                      ,.S_RID           (S_RID       )
                                      ,.S_RDATA         (S_RDATA     )
                                      ,.S_RRESP         (S_RRESP     )
                                      ,.S_RLAST         (S_RLAST     )
                                      ,.S_RVALID        (S_RVALID    )
                                      ,.S_RREADY        (S_RREADY    )
                                      ,.M_ACLK          (ACLK        )
                                      ,.M_AWID          (M_AWID      )
                                      ,.M_AWADDR        (M_AWADDR    )
     `ifdef AMBA_AXI4
                                      ,.M_AWLEN         (M_AWLEN     )
                                      ,.M_AWLOCK        (M_AWLOCK    )
     `else
                                      ,.M_AWLEN         (M_AWLEN     )
                                      ,.M_AWLOCK        (M_AWLOCK    )
     `endif
                                      ,.M_AWSIZE        (M_AWSIZE    )
                                      ,.M_AWBURST       (M_AWBURST   )
     `ifdef AMBA_AXI_CACHE
                                      ,.M_AWCACHE       (M_AWCACHE   )
     `endif
     `ifdef AMBA_AXI_PROT
                                      ,.M_AWPROT        (M_AWPROT    )
     `endif
                                      ,.M_AWVALID       (M_AWVALID   )
                                      ,.M_AWREADY       (M_AWREADY   )
     `ifdef AMBA_AXI4
                                      ,.M_AWQOS         (M_AWQOS     )
                                      ,.M_AWREGION      (M_AWREGION  )
     `endif
                                      ,.M_WID           (M_WID       )
                                      ,.M_WDATA         (M_WDATA     )
                                      ,.M_WSTRB         (M_WSTRB     )
                                      ,.M_WLAST         (M_WLAST     )
                                      ,.M_WVALID        (M_WVALID    )
                                      ,.M_WREADY        (M_WREADY    )
                                      ,.M_BID           (M_BID       )
                                      ,.M_BRESP         (M_BRESP     )
                                      ,.M_BVALID        (M_BVALID    )
                                      ,.M_BREADY        (M_BREADY    )
                                      ,.M_ARID          (M_ARID      )
                                      ,.M_ARADDR        (M_ARADDR    )
     `ifdef AMBA_AXI4
                                      ,.M_ARLEN         (M_ARLEN     )
                                      ,.M_ARLOCK        (M_ARLOCK    )
     `else
                                      ,.M_ARLEN         (M_ARLEN     )
                                      ,.M_ARLOCK        (M_ARLOCK    )
     `endif
                                      ,.M_ARSIZE        (M_ARSIZE    )
                                      ,.M_ARBURST       (M_ARBURST   )
     `ifdef AMBA_AXI_CACHE
                                      ,.M_ARCACHE       (M_ARCACHE   )
     `endif
     `ifdef AMBA_AXI_PROT
                                      ,.M_ARPROT        (M_ARPROT    )
     `endif
                                      ,.M_ARVALID       (M_ARVALID   )
                                      ,.M_ARREADY       (M_ARREADY   )
     `ifdef AMBA_AXI4
                                      ,.M_ARQOS         (M_ARQOS     )
                                      ,.M_ARREGION      (M_ARREGION  )
     `endif
                                      ,.M_RID           (M_RID       )
                                      ,.M_RDATA         (M_RDATA     )
                                      ,.M_RRESP         (M_RRESP     )
                                      ,.M_RLAST         (M_RLAST     )
                                      ,.M_RVALID        (M_RVALID    )
                                      ,.M_RREADY        (M_RREADY    )
     );
     //-----------------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2012.01.02: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
