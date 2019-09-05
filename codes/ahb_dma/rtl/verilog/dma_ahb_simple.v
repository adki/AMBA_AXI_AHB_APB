//--------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// dma_ahb_simple.v
//--------------------------------------------------------
// VERSION = 2014.04.29.
//--------------------------------------------------------
// Note:
//--------------------------------------------------------
`include "dma_ahb_csr_ahb.v"
`include "dma_ahb_master.v"
`timescale 1ns/1ns

module dma_ahb_simple
(
       input   wire          HRESETn
     , input   wire          HCLK
     //---------------------------------------------------
     , input   wire          S_HSEL
     , input   wire  [31:0]  S_HADDR
     , input   wire  [ 1:0]  S_HTRANS
     , input   wire          S_HWRITE
     , input   wire  [ 2:0]  S_HSIZE
     , input   wire  [ 2:0]  S_HBURST
     , input   wire  [31:0]  S_HWDATA
     , output  wire  [31:0]  S_HRDATA
     , output  wire  [ 1:0]  S_HRESP
     , input   wire          S_HREADYin
     , output  wire          S_HREADYout
     //---------------------------------------------------
     , output  wire          IRQ
     //---------------------------------------------------
     // bus interface
     , output  wire          M_HBUSREQ
     , input   wire          M_HGRANT
     , output  wire  [31:0]  M_HADDR
     , output  wire  [ 1:0]  M_HTRANS
     , output  wire          M_HWRITE
     , output  wire  [ 2:0]  M_HSIZE
     , output  wire  [ 2:0]  M_HBURST
     , output  wire  [ 3:0]  M_HPROT
     , output  wire  [31:0]  M_HWDATA
     , input   wire  [31:0]  M_HRDATA
     , input   wire  [ 1:0]  M_HRESP
     , input   wire          M_HREADY
     //---------------------------------------------------
);
   //-----------------------------------------------------
   wire            DMA_EN   ; // synchronous reset
   wire            DMA_GO   ;
   wire            DMA_BUSY ;
   wire            DMA_DONE ;
   wire  [31:0]    DMA_SRC  ; // source address
   wire  [31:0]    DMA_DST  ; // destination address
   wire  [15:0]    DMA_BNUM ; // num of bytes to move
   wire  [ 4:0]    DMA_BURST; // burst length 1, 4, 8 , 16
   //-----------------------------------------------------
   dma_ahb_csr_ahb
   u_csr (
       .HRESETn   (HRESETn    )
     , .HCLK      (HCLK       )
     , .HSEL      (S_HSEL     )
     , .HADDR     (S_HADDR    )
     , .HTRANS    (S_HTRANS   )
     , .HWRITE    (S_HWRITE   )
     , .HSIZE     (S_HSIZE    )
     , .HBURST    (S_HBURST   )
     , .HWDATA    (S_HWDATA   )
     , .HRDATA    (S_HRDATA   )
     , .HRESP     (S_HRESP    )
     , .HREADYin  (S_HREADYin )
     , .HREADYout (S_HREADYout)
     , .IRQ       (IRQ        )
     , .DMA_EN    (DMA_EN     )
     , .DMA_GO    (DMA_GO     )
     , .DMA_BUSY  (DMA_BUSY   )
     , .DMA_DONE  (DMA_DONE   )
     , .DMA_SRC   (DMA_SRC    )
     , .DMA_DST   (DMA_DST    )
     , .DMA_BNUM  (DMA_BNUM   )
     , .DMA_BURST (DMA_BURST  )
   );
   //-----------------------------------------------------
   dma_ahb_master
   u_master (
       .HRESETn   (HRESETn    )
     , .HCLK      (HCLK       )
     , .HBUSREQ   (M_HBUSREQ  )
     , .HGRANT    (M_HGRANT   )
     , .HADDR     (M_HADDR    )
     , .HTRANS    (M_HTRANS   )
     , .HWRITE    (M_HWRITE   )
     , .HSIZE     (M_HSIZE    )
     , .HBURST    (M_HBURST   )
     , .HPROT     (M_HPROT    )
     , .HWDATA    (M_HWDATA   )
     , .HRDATA    (M_HRDATA   )
     , .HRESP     (M_HRESP    )
     , .HREADY    (M_HREADY   )
     , .DMA_EN    (DMA_EN     )
     , .DMA_GO    (DMA_GO     )
     , .DMA_BUSY  (DMA_BUSY   )
     , .DMA_DONE  (DMA_DONE   )
     , .DMA_SRC   (DMA_SRC    )
     , .DMA_DST   (DMA_DST    )
     , .DMA_BNUM  (DMA_BNUM   )
     , .DMA_BURST (DMA_BURST  )
   );
   //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2014.04.29: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
