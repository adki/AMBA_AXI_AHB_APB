//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// VERSION: 2015.07.12.
//----------------------------------------------------------
// DMA AXI simplified version
//----------------------------------------------------------
// Limitations:
//----------------------------------------------------------
`include "dma_axi_simple_defines.v"
`include "dma_axi_simple_core_read.v"
`include "dma_axi_simple_core_write.v"
`include "dma_axi_simple_fifo_sync_small.v"
`timescale 1ns/1ns

module dma_axi_simple_core
     #(parameter AXI_MST_ID   =1         // Master ID
               , AXI_WIDTH_CID=4
               , AXI_WIDTH_ID =4         // ID width in bits
               , AXI_WIDTH_AD =32        // address width
               , AXI_WIDTH_DA =32        // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8) // data strobe width
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
               , AXI_WIDTH_SID=AXI_WIDTH_CID+AXI_WIDTH_ID
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     `undef Otype `define Otype wire
     `undef Itype `define Itype wire
     `AMBA_AXI_MASTER_PORT
     //-----------------------------------------------------------
     , input   wire            DMA_EN
     , input   wire            DMA_GO
     , output  wire            DMA_BUSY
     , output  wire            DMA_DONE
     , input   wire  [31:0]    DMA_SRC
     , input   wire  [31:0]    DMA_DST
     , input   wire  [15:0]    DMA_BNUM // num of bytes to move
     , input   wire  [ 7:0]    DMA_CHUNK// num of bytes to move at a time
);
   //-----------------------------------------------------
   assign M_MID = AXI_MST_ID[AXI_WIDTH_CID-1:0]; // master id
   //-----------------------------------------------------
   wire  DMA_BUSY_R;
   wire  DMA_DONE_R;
   wire  DMA_BUSY_W;
   wire  DMA_DONE_W;
   assign DMA_BUSY = DMA_BUSY_R | DMA_BUSY_W;
   assign DMA_DONE = DMA_DONE_R & DMA_DONE_W;
   //-----------------------------------------------------
   localparam FIFO_DW = AXI_WIDTH_DS + AXI_WIDTH_DA
            , FIFO_AW = 4;
   wire               fifo_wr_rdy;
   wire               fifo_wr_vld;
   wire [FIFO_DW-1:0] fifo_wr_dat;
   wire               fifo_rd_rdy;
   wire               fifo_rd_vld;
   wire [FIFO_DW-1:0] fifo_rd_dat;
   wire               fifo_full  ;
   wire               fifo_empty ;
   wire [FIFO_AW:0]   fifo_items ;
   wire [FIFO_AW:0]   fifo_rooms ;
   //-----------------------------------------------------
   dma_axi_simple_core_read #(.AXI_WIDTH_CID(AXI_WIDTH_CID)
                             ,.AXI_WIDTH_ID (AXI_WIDTH_ID )
                             ,.AXI_WIDTH_AD (AXI_WIDTH_AD )
                             ,.AXI_WIDTH_DA (AXI_WIDTH_DA )
                             ,.FIFO_WIDTH   (FIFO_DW      )
                             ,.FIFO_DEPTH   (1<<FIFO_AW   ))
   u_read (
       .ARESETn   (ARESETn )
     , .ACLK      (ACLK    )
     //-----------------------------------------------------------
     `AMBA_AXI_MASTER_PORT_CONNECTION_AR
     `AMBA_AXI_MASTER_PORT_CONNECTION_R
     //-----------------------------------------------------------
     , .DMA_EN    (DMA_EN    )
     , .DMA_GO    (DMA_GO    )
     , .DMA_BUSY  (DMA_BUSY_R)
     , .DMA_DONE  (DMA_DONE_R)
     , .DMA_SRC   (DMA_SRC   )
     , .DMA_BNUM  (DMA_BNUM  )
     , .DMA_CHUNK (DMA_CHUNK )
     //-----------------------------------------------------------
     , .fifo_wr_rdy(fifo_wr_rdy)
     , .fifo_wr_vld(fifo_wr_vld)
     , .fifo_wr_dat(fifo_wr_dat)
     , .fifo_empty (fifo_empty )
     , .fifo_rooms (fifo_rooms )
   );
   //-----------------------------------------------------
   dma_axi_simple_core_write #(.AXI_WIDTH_CID(AXI_WIDTH_CID)
                              ,.AXI_WIDTH_ID (AXI_WIDTH_ID )
                              ,.AXI_WIDTH_AD (AXI_WIDTH_AD )
                              ,.AXI_WIDTH_DA (AXI_WIDTH_DA )
                              ,.FIFO_WIDTH   (FIFO_DW      )
                              ,.FIFO_DEPTH   (1<<FIFO_AW   ))
   u_write (
       .ARESETn   (ARESETn )
     , .ACLK      (ACLK    )
     //-----------------------------------------------------------
     `AMBA_AXI_MASTER_PORT_CONNECTION_AW
     `AMBA_AXI_MASTER_PORT_CONNECTION_W
     `AMBA_AXI_MASTER_PORT_CONNECTION_B
     //-----------------------------------------------------------
     , .DMA_EN    (DMA_EN    )
     , .DMA_GO    (DMA_GO    )
     , .DMA_BUSY  (DMA_BUSY_W)
     , .DMA_DONE  (DMA_DONE_W)
     , .DMA_DST   (DMA_DST   )
     , .DMA_BNUM  (DMA_BNUM  )
     , .DMA_CHUNK (DMA_CHUNK )
     //-----------------------------------------------------------
     , .fifo_rd_rdy(fifo_rd_rdy)
     , .fifo_rd_vld(fifo_rd_vld)
     , .fifo_rd_dat(fifo_rd_dat)
     , .fifo_items (fifo_items )
   );
   //-----------------------------------------------------------
   // Note each transaction consists of 'len' entries.
   dma_axi_simple_fifo_sync_small
          #(.FDW(FIFO_DW) // fifof data width (data+rid+last)
           ,.FAW(FIFO_AW))// num of entries in 2 to the power FAW
   u_fifo (
       .rst     (~ARESETn)
     , .clr     (~DMA_EN )
     , .clk     ( ACLK   )
     , .wr_rdy  (fifo_wr_rdy )
     , .wr_vld  (fifo_wr_vld )
     , .wr_din  (fifo_wr_dat )
     , .rd_rdy  (fifo_rd_rdy )
     , .rd_vld  (fifo_rd_vld )
     , .rd_dout (fifo_rd_dat )
     , .full    (fifo_full   )
     , .empty   (fifo_empty  )
     , .fullN   ()
     , .emptyN  ()
     , .rd_cnt  (fifo_items  )
     , .wr_cnt  (fifo_rooms  )
   );
   //-----------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
      tmp = value - 1;
      for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
   end
   endfunction
   //-----------------------------------------------------------
   // synthesis translate_off
   always @ (posedge ACLK) begin
       if (DMA_EN&DMA_GO) begin
           if (DMA_SRC[AXI_WIDTH_DSB-1:0]!==DMA_DST[AXI_WIDTH_DSB-1:0]) begin
$display($time,,"%m src dst not aligned: 0x%X 0x%X",
           DMA_SRC[AXI_WIDTH_DSB-1:0],DMA_DST[AXI_WIDTH_DSB-1:0]);
           end
       end
   end
   // synthesis translate_on
   //-----------------------------------------------------------
endmodule
//----------------------------------------------------------
// Revision history
//
// 2015.07.12: Started by Ando Ki.
//----------------------------------------------------------
