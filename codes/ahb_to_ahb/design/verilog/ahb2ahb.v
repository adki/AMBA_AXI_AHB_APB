//----------------------------------------------------------------
//  Copyright (c) 2010-2012 by Ando Ki.
//  All right reserved.
//----------------------------------------------------------------
// AHB-to-AHB bus bridge, synchronous
//----------------------------------------------------------------
// VERSION: 2012.02.17.
//----------------------------------------------------------------
// Macros and parameters:
//----------------------------------------------------------------
// Note:
//----------------------------------------------------------------
// Signal naming convention:
//    * forward: address and control information goes out
//    * bakward: data information comes in
//    * fwd_ : forward
//    * bwd_ : backward
//----------------------------------------------------------------
// Limitations:
//  - HLOCK is not supported
//  - Split transaction is not supported
//  - Early termination is not supported
//  - Busy (HTRANS) is not supported
//  - All burst transactions should go on
//    without BUSY cycle
//----------------------------------------------------------------
`timescale 1ns/1ns
`include "ahb2ahb_slave_core.v"
`include "ahb2ahb_master_core.v"
`include "ahb2ahb_fifo.v"

module ahb2ahb (
       input   wire        HRESETn
     , input   wire        HCLK
     , input   wire        sHSEL
     , input   wire [31:0] sHADDR
     , input   wire [1:0]  sHTRANS
     , input   wire        sHWRITE
     , input   wire [2:0]  sHSIZE
     , input   wire [2:0]  sHBURST
     , input   wire [31:0] sHWDATA
     , output  wire [31:0] sHRDATA
     , output  wire [1:0]  sHRESP
     , input   wire        sHREADYin
     , output  wire        sHREADYout
     , output  wire        mHBUSREQ
     , input   wire        mHGRANT
     , output  wire [31:0] mHADDR
     , output  wire [1:0]  mHTRANS
     , output  wire        mHWRITE
     , output  wire [2:0]  mHSIZE
     , output  wire [2:0]  mHBURST
     , output  wire [31:0] mHWDATA
     , input   wire [31:0] mHRDATA
     , input   wire [1:0]  mHRESP
     , input   wire        mHREADY
);
   //--------------------------------------------------------
   localparam FIFO_AW=5;
   //--------------------------------------------------------
   wire             fwd_wr_rdy;
   wire             fwd_wr_vld;
   wire [31:0]      fwd_wr_dat;
   wire             fwd_rd_rdy;
   wire             fwd_rd_vld;
   wire [31:0]      fwd_rd_dat;
   wire             fwd_full;
   wire             fwd_empty;
   wire [FIFO_AW:0] fwd_cnt_rd;
   wire [FIFO_AW:0] fwd_cnt_wr;
   wire             bwd_rd_rdy;
   wire             bwd_rd_vld;
   wire [31:0]      bwd_rd_dat;
   wire             bwd_wr_rdy;
   wire             bwd_wr_vld;
   wire [31:0]      bwd_wr_dat;
   wire             bwd_full;
   wire             bwd_empty;
   wire [FIFO_AW:0] bwd_cnt_rd;
   wire [FIFO_AW:0] bwd_cnt_wr;

   //----------------------------------------------------
   // It handles AHB transaction as a slave.
   // It pushes request information to the forward FIFO.
   // It pops response information from the backwoard FIFO.
   ahb2ahb_slave_core Uslave (
           .HRESETn   (HRESETn   )
         , .HCLK      (HCLK      )
         , .HSEL      (sHSEL     )
         , .HADDR     (sHADDR    )
         , .HTRANS    (sHTRANS   )
         , .HWRITE    (sHWRITE   )
         , .HSIZE     (sHSIZE    )
         , .HBURST    (sHBURST   )
         , .HWDATA    (sHWDATA   )
         , .HRDATA    (sHRDATA   )
         , .HRESP     (sHRESP    )
         , .HREADYin  (sHREADYin )
         , .HREADYout (sHREADYout)
         , .fwr_clk   (          ) // output: should be HCLK
         , .fwr_rdy   (fwd_wr_rdy)
         , .fwr_vld   (fwd_wr_vld)
         , .fwr_dat   (fwd_wr_dat)
         , .fwr_full  (fwd_full  )
         , .fwr_cnt   (fwd_cnt_wr) // how many rooms available
         , .brd_clk   (          ) // output: should be HCLK
         , .brd_rdy   (bwd_rd_rdy)
         , .brd_vld   (bwd_rd_vld)
         , .brd_dat   (bwd_rd_dat)
         , .brd_empty (bwd_empty )
         , .brd_cnt   (bwd_cnt_rd) // how many items avilable
   );

   //----------------------------------------------------
   ahb2ahb_master_core Umaster (
           .HRESETn   (HRESETn )
         , .HCLK      (HCLK    )
         , .HBUSREQ   (mHBUSREQ)
         , .HGRANT    (mHGRANT )
         , .HADDR     (mHADDR  )
         , .HTRANS    (mHTRANS )
         , .HWRITE    (mHWRITE )
         , .HSIZE     (mHSIZE  )
         , .HBURST    (mHBURST )
         , .HWDATA    (mHWDATA )
         , .HRDATA    (mHRDATA )
         , .HRESP     (mHRESP  )
         , .HREADY    (mHREADY )
         , .frd_clk   (          ) // output: should be HCLK
         , .frd_rdy   (fwd_rd_rdy)
         , .frd_vld   (fwd_rd_vld)
         , .frd_dat   (fwd_rd_dat)
         , .frd_empty (fwd_empty )
         , .frd_cnt   (fwd_cnt_rd) // num ele. to read
         , .bwr_clk   (          ) // output: should be HCLK
         , .bwr_rdy   (bwd_wr_rdy)
         , .bwr_vld   (bwd_wr_vld)
         , .bwr_dat   (bwd_wr_dat)
         , .bwr_full  (bwd_full  )
         , .bwr_cnt   (bwd_cnt_wr) // num rooms to write
   );

   //---------------------------------------------------
   // from slave-to-master
   // all address related information
   ahb2ahb_fifo #(32, FIFO_AW) Ufwd_fifo (
        .rst     (~HRESETn   )
      , .clr     (1'b0       )
      , .clk     (HCLK       ) // it should be HCLK
      , .wr_rdy  (fwd_wr_rdy )
      , .wr_vld  (fwd_wr_vld )
      , .wr_din  (fwd_wr_dat )
      , .rd_rdy  (fwd_rd_rdy )
      , .rd_vld  (fwd_rd_vld )
      , .rd_dout (fwd_rd_dat )
      , .empty   (fwd_empty  )
      , .full    (fwd_full   )
      , .fullN   ()
      , .emptyN  ()
      , .rd_cnt  (fwd_cnt_rd ) // how many items
      , .wr_cnt  (fwd_cnt_wr ) // how many rooms
   );

   //---------------------------------------------------
   // from master-to-slave
   // all data related information
   ahb2ahb_fifo #(32, FIFO_AW) Ubwd_fifo (
        .rst     (~HRESETn  )
      , .clr     (1'b0      )
      , .clk     (HCLK      ) // it should be HCLK
      , .wr_rdy  (bwd_wr_rdy)
      , .wr_vld  (bwd_wr_vld)
      , .wr_din  (bwd_wr_dat)
      , .rd_rdy  (bwd_rd_rdy)
      , .rd_vld  (bwd_rd_vld)
      , .rd_dout (bwd_rd_dat)
      , .empty   (bwd_empty )
      , .full    (bwd_full  )
      , .fullN   ()
      , .emptyN  ()
      , .rd_cnt  (bwd_cnt_rd)
      , .wr_cnt  (bwd_cnt_wr)
   );

endmodule

//----------------------------------------------------------------
// Revision History
//
// 2012.02.12.: timescale and include
// 2010.01.07.: Starting by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
