`ifndef DMA_AXI_SIMPLE_DEFINES_V
`define DMA_AXI_SIMPLE_DEFINES_V
//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// VERSION: 2015.07.12.
//----------------------------------------------------------
     //-----------------------------------------------------------
`define Otype wire
`define Itype wire
     //-----------------------------------------------------------
`define AMBA_AXI_MASTER_PORT_AW\
     , output `Otype [AXI_WIDTH_ID-1:0]  M_AWID\
     , output `Otype [AXI_WIDTH_AD-1:0]  M_AWADDR\
     `ifdef AMBA_AXI4\
     , output `Otype [ 7:0]              M_AWLEN\
     , output `Otype                     M_AWLOCK\
     `else\
     , output `Otype [ 3:0]              M_AWLEN\
     , output `Otype [ 1:0]              M_AWLOCK\
     `endif\
     , output `Otype [ 2:0]              M_AWSIZE\
     , output `Otype [ 1:0]              M_AWBURST\
     `ifdef AMBA_AXI_CACHE\
     , output `Otype [ 3:0]              M_AWCACHE\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , output `Otype [ 2:0]              M_AWPROT\
     `endif\
     , output `Otype                     M_AWVALID\
     , input  `Itype                     M_AWREADY\
     `ifdef AMBA_AXI4\
     , output `Otype [ 3:0]              M_AWQOS\
     , output `Otype [ 3:0]              M_AWREGION\
     `endif
`define AMBA_AXI_MASTER_PORT_W\
     , output `Otype [AXI_WIDTH_ID-1:0]  M_WID\
     , output `Otype [AXI_WIDTH_DA-1:0]  M_WDATA\
     , output `Otype [AXI_WIDTH_DS-1:0]  M_WSTRB\
     , output `Otype                     M_WLAST\
     , output `Otype                     M_WVALID\
     , input  `Itype                     M_WREADY
`define AMBA_AXI_MASTER_PORT_B\
     , input  `Itype [AXI_WIDTH_ID-1:0]  M_BID\
     , input  `Itype [ 1:0]              M_BRESP\
     , input  `Itype                     M_BVALID\
     , output `Otype                     M_BREADY
`define AMBA_AXI_MASTER_PORT_AR\
     , output `Otype [AXI_WIDTH_ID-1:0]  M_ARID\
     , output `Otype [AXI_WIDTH_AD-1:0]  M_ARADDR\
     `ifdef AMBA_AXI4\
     , output `Otype [ 7:0]              M_ARLEN\
     , output `Otype                     M_ARLOCK\
     `else\
     , output `Otype [ 3:0]              M_ARLEN\
     , output `Otype [ 1:0]              M_ARLOCK\
     `endif\
     , output `Otype [ 2:0]              M_ARSIZE\
     , output `Otype [ 1:0]              M_ARBURST\
     `ifdef AMBA_AXI_CACHE\
     , output `Otype [ 3:0]              M_ARCACHE\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , output `Otype [ 2:0]              M_ARPROT\
     `endif\
     , output `Otype                     M_ARVALID\
     , input  `Itype                     M_ARREADY\
     `ifdef AMBA_AXI4\
     , output `Otype [ 3:0]              M_ARQOS\
     , output `Otype [ 3:0]              M_ARREGION\
     `endif
`define AMBA_AXI_MASTER_PORT_R\
     , input  `Itype [AXI_WIDTH_ID-1:0]  M_RID\
     , input  `Itype [AXI_WIDTH_DA-1:0]  M_RDATA\
     , input  `Itype [ 1:0]              M_RRESP\
     , input  `Itype                     M_RLAST\
     , input  `Itype                     M_RVALID\
     , output `Otype                     M_RREADY
`define AMBA_AXI_MASTER_PORT\
     , output `Otype [AXI_WIDTH_CID-1:0] M_MID\
     `AMBA_AXI_MASTER_PORT_AW\
     `AMBA_AXI_MASTER_PORT_W\
     `AMBA_AXI_MASTER_PORT_B\
     `AMBA_AXI_MASTER_PORT_AR\
     `AMBA_AXI_MASTER_PORT_R

     //-----------------------------------------------------------
`define AMBA_AXI_SLAVE_PORT_AW\
     , input  `Itype [AXI_WIDTH_SID-1:0] S_AWID\
     , input  `Itype [AXI_WIDTH_AD-1:0]  S_AWADDR\
     `ifdef AMBA_AXI4\
     , input  `Itype [ 7:0]              S_AWLEN\
     , input  `Itype                     S_AWLOCK\
     `else\
     , input  `Itype [ 3:0]              S_AWLEN\
     , input  `Itype [ 1:0]              S_AWLOCK\
     `endif\
     , input  `Itype [ 2:0]              S_AWSIZE\
     , input  `Itype [ 1:0]              S_AWBURST\
     `ifdef AMBA_AXI_CACHE\
     , input  `Itype [ 3:0]              S_AWCACHE\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , input  `Itype [ 2:0]              S_AWPROT\
     `endif\
     , input  `Itype                     S_AWVALID\
     , output `Otype                     S_AWREADY\
     `ifdef AMBA_AXI4\
     , input  `Itype [ 3:0]              S_AWQOS\
     , input  `Itype [ 3:0]              S_AWREGION\
     `endif
`define AMBA_AXI_SLAVE_PORT_W\
     , input  `Itype [AXI_WIDTH_SID-1:0] S_WID\
     , input  `Itype [AXI_WIDTH_DA-1:0]  S_WDATA\
     , input  `Itype [AXI_WIDTH_DS-1:0]  S_WSTRB\
     , input  `Itype                     S_WLAST\
     , input  `Itype                     S_WVALID\
     , output `Otype                     S_WREADY
`define AMBA_AXI_SLAVE_PORT_B\
     , output `Otype [AXI_WIDTH_SID-1:0] S_BID\
     , output `Otype [ 1:0]              S_BRESP\
     , output `Otype                     S_BVALID\
     , input  `Itype                     S_BREADY
`define AMBA_AXI_SLAVE_PORT_AR\
     , input  `Itype [AXI_WIDTH_SID-1:0] S_ARID\
     , input  `Itype [AXI_WIDTH_AD-1:0]  S_ARADDR\
     `ifdef AMBA_AXI4\
     , input  `Itype [ 7:0]              S_ARLEN\
     , input  `Itype                     S_ARLOCK\
     `else\
     , input  `Itype [ 3:0]              S_ARLEN\
     , input  `Itype [ 1:0]              S_ARLOCK\
     `endif\
     , input  `Itype [ 2:0]              S_ARSIZE\
     , input  `Itype [ 1:0]              S_ARBURST\
     `ifdef AMBA_AXI_CACHE\
     , input  `Itype [ 3:0]              S_ARCACHE\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , input  `Itype [ 2:0]              S_ARPROT\
     `endif\
     , input  `Itype                     S_ARVALID\
     , output `Otype                     S_ARREADY\
     `ifdef AMBA_AXI4\
     , input  `Itype [ 3:0]              S_ARQOS\
     , input  `Itype [ 3:0]              S_ARREGION\
     `endif
`define AMBA_AXI_SLAVE_PORT_R\
     , output `Otype [AXI_WIDTH_SID-1:0] S_RID\
     , output `Otype [AXI_WIDTH_DA-1:0]  S_RDATA\
     , output `Otype [ 1:0]              S_RRESP\
     , output `Otype                     S_RLAST\
     , output `Otype                     S_RVALID\
     , input  `Itype                     S_RREADY
`define AMBA_AXI_SLAVE_PORT\
        `AMBA_AXI_SLAVE_PORT_AW\
        `AMBA_AXI_SLAVE_PORT_W\
        `AMBA_AXI_SLAVE_PORT_B\
        `AMBA_AXI_SLAVE_PORT_AR\
        `AMBA_AXI_SLAVE_PORT_R

   //-----------------------------------------------------
`define AMBA_AXI_MASTER_PORT_CONNECTION_AW\
     , .M_AWID     (M_AWID    )\
     , .M_AWADDR   (M_AWADDR  )\
     `ifdef AMBA_AXI4\
     , .M_AWLEN    (M_AWLEN   )\
     , .M_AWLOCK   (M_AWLOCK  )\
     `else\
     , .M_AWLEN    (M_AWLEN   )\
     , .M_AWLOCK   (M_AWLOCK  )\
     `endif\
     , .M_AWSIZE   (M_AWSIZE  )\
     , .M_AWBURST  (M_AWBURST )\
     `ifdef AMBA_AXI_CACHE\
     , .M_AWCACHE  (M_AWCACHE )\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , .M_AWPROT   (M_AWPROT  )\
     `endif\
     , .M_AWVALID  (M_AWVALID )\
     , .M_AWREADY  (M_AWREADY )\
     `ifdef AMBA_AXI4\
     , .M_AWQOS    (M_AWQOS   )\
     , .M_AWREGION (M_AWREGION)\
     `endif
`define AMBA_AXI_MASTER_PORT_CONNECTION_W\
     , .M_WID      (M_WID     )\
     , .M_WDATA    (M_WDATA   )\
     , .M_WSTRB    (M_WSTRB   )\
     , .M_WLAST    (M_WLAST   )\
     , .M_WVALID   (M_WVALID  )\
     , .M_WREADY   (M_WREADY  )
`define AMBA_AXI_MASTER_PORT_CONNECTION_B\
     , .M_BID      (M_BID     )\
     , .M_BRESP    (M_BRESP   )\
     , .M_BVALID   (M_BVALID  )\
     , .M_BREADY   (M_BREADY  )
`define AMBA_AXI_MASTER_PORT_CONNECTION_AR\
     , .M_ARID     (M_ARID    )\
     , .M_ARADDR   (M_ARADDR  )\
     `ifdef AMBA_AXI4\
     , .M_ARLEN    (M_ARLEN   )\
     , .M_ARLOCK   (M_ARLOCK  )\
     `else\
     , .M_ARLEN    (M_ARLEN   )\
     , .M_ARLOCK   (M_ARLOCK  )\
     `endif\
     , .M_ARSIZE   (M_ARSIZE  )\
     , .M_ARBURST  (M_ARBURST )\
     `ifdef AMBA_AXI_CACHE\
     , .M_ARCACHE  (M_ARCACHE )\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , .M_ARPROT   (M_ARPROT  )\
     `endif\
     , .M_ARVALID  (M_ARVALID )\
     , .M_ARREADY  (M_ARREADY )\
     `ifdef AMBA_AXI4\
     , .M_ARQOS    (M_ARQOS   )\
     , .M_ARREGION (M_ARREGION)\
     `endif
`define AMBA_AXI_MASTER_PORT_CONNECTION_R\
     , .M_RID      (M_RID     )\
     , .M_RDATA    (M_RDATA   )\
     , .M_RRESP    (M_RRESP   )\
     , .M_RLAST    (M_RLAST   )\
     , .M_RVALID   (M_RVALID  )\
     , .M_RREADY   (M_RREADY  )
`define AMBA_AXI_MASTER_PORT_CONNECTION\
     , .M_MID      (M_MID     )\
     `AMBA_AXI_MASTER_PORT_CONNECTION_AW\
     `AMBA_AXI_MASTER_PORT_CONNECTION_W\
     `AMBA_AXI_MASTER_PORT_CONNECTION_B\
     `AMBA_AXI_MASTER_PORT_CONNECTION_AR\
     `AMBA_AXI_MASTER_PORT_CONNECTION_R

     //--------------------------------------------------
`define AMBA_AXI_SLAVE_PORT_CONNECTION_AW\
     , .S_AWID     (S_AWID    )\
     , .S_AWADDR   (S_AWADDR  )\
     `ifdef AMBA_AXI4\
     , .S_AWLEN    (S_AWLEN   )\
     , .S_AWLOCK   (S_AWLOCK  )\
     `else\
     , .S_AWLEN    (S_AWLEN   )\
     , .S_AWLOCK   (S_AWLOCK  )\
     `endif\
     , .S_AWSIZE   (S_AWSIZE  )\
     , .S_AWBURST  (S_AWBURST )\
     `ifdef AMBA_AXI_CACHE\
     , .S_AWCACHE  (S_AWCACHE )\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , .S_AWPROT   (S_AWPROT  )\
     `endif\
     , .S_AWVALID  (S_AWVALID )\
     , .S_AWREADY  (S_AWREADY )\
     `ifdef AMBA_AXI4\
     , .S_AWQOS    (S_AWQOS   )\
     , .S_AWREGION (S_AWREGION)\
     `endif
`define AMBA_AXI_SLAVE_PORT_CONNECTION_W\
     , .S_WID      (S_WID     )\
     , .S_WDATA    (S_WDATA   )\
     , .S_WSTRB    (S_WSTRB   )\
     , .S_WLAST    (S_WLAST   )\
     , .S_WVALID   (S_WVALID  )\
     , .S_WREADY   (S_WREADY  )
`define AMBA_AXI_SLAVE_PORT_CONNECTION_B\
     , .S_BID      (S_BID     )\
     , .S_BRESP    (S_BRESP   )\
     , .S_BVALID   (S_BVALID  )\
     , .S_BREADY   (S_BREADY  )
`define AMBA_AXI_SLAVE_PORT_CONNECTION_AR\
     , .S_ARID     (S_ARID    )\
     , .S_ARADDR   (S_ARADDR  )\
     `ifdef AMBA_AXI4\
     , .S_ARLEN    (S_ARLEN   )\
     , .S_ARLOCK   (S_ARLOCK  )\
     `else\
     , .S_ARLEN    (S_ARLEN   )\
     , .S_ARLOCK   (S_ARLOCK  )\
     `endif\
     , .S_ARSIZE   (S_ARSIZE  )\
     , .S_ARBURST  (S_ARBURST )\
     `ifdef AMBA_AXI_CACHE\
     , .S_ARCACHE  (S_ARCACHE )\
     `endif\
     `ifdef AMBA_AXI_PROT\
     , .S_ARPROT   (S_ARPROT  )\
     `endif\
     , .S_ARVALID  (S_ARVALID )\
     , .S_ARREADY  (S_ARREADY )\
     `ifdef AMBA_AXI4\
     , .S_ARQOS    (S_ARQOS   )\
     , .S_ARREGION (S_ARREGION)\
     `endif
`define AMBA_AXI_SLAVE_PORT_CONNECTION_R\
     , .S_RID      (S_RID     )\
     , .S_RDATA    (S_RDATA   )\
     , .S_RRESP    (S_RRESP   )\
     , .S_RLAST    (S_RLAST   )\
     , .S_RVALID   (S_RVALID  )\
     , .S_RREADY   (S_RREADY  )
`define AMBA_AXI_SLAVE_PORT_CONNECTION\
        `AMBA_AXI_SLAVE_PORT_CONNECTION_AW\
        `AMBA_AXI_SLAVE_PORT_CONNECTION_W\
        `AMBA_AXI_SLAVE_PORT_CONNECTION_B\
        `AMBA_AXI_SLAVE_PORT_CONNECTION_AR\
        `AMBA_AXI_SLAVE_PORT_CONNECTION_R


//----------------------------------------------------------
// Revision history
//
// 2015.07.12: Started by Ando Ki.
//----------------------------------------------------------
`endif
