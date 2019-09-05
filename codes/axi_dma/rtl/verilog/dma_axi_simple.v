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
`include "dma_axi_simple_csr_axi.v"
`include "dma_axi_simple_core.v"
`timescale 1ns/1ns

module dma_axi_simple
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
     // DMA AXI Master Port
     `undef Otype `define Otype wire
     `undef Itype `define Itype wire
     `AMBA_AXI_MASTER_PORT
     //-----------------------------------------------------------
     // AXI Slave Port for CSR
     `undef Otype `define Otype wire
     `undef Itype `define Itype wire
     `AMBA_AXI_SLAVE_PORT
     //--------------------------------------------------
     , output  wire                    IRQ
);
   //-----------------------------------------------------
   wire          DMA_EN   ;
   wire          DMA_GO   ;
   wire          DMA_BUSY ;
   wire          DMA_DONE ;
   wire  [31:0]  DMA_SRC  ;
   wire  [31:0]  DMA_DST  ;
   wire  [15:0]  DMA_BNUM ;// num of bytes to move
   wire  [ 7:0]  DMA_CHUNK;// AxLEN ( +l beats)
   //-----------------------------------------------------
   dma_axi_simple_csr_axi #(.AXI_WIDTH_CID(AXI_WIDTH_CID) // Channel ID width in bits
                           ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                           ,.AXI_WIDTH_SID(AXI_WIDTH_SID) // ID width in bits
                           ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                           ,.AXI_WIDTH_DA (AXI_WIDTH_DA ))// data width
   u_csr (
       .ARESETn  (ARESETn   )
     , .ACLK     (ACLK      )
     `AMBA_AXI_SLAVE_PORT_CONNECTION
     , .IRQ      (IRQ       )
     , .DMA_EN   (DMA_EN    )
     , .DMA_GO   (DMA_GO    )
     , .DMA_BUSY (DMA_BUSY  )
     , .DMA_DONE (DMA_DONE  )
     , .DMA_SRC  (DMA_SRC   )
     , .DMA_DST  (DMA_DST   )
     , .DMA_BNUM (DMA_BNUM  )
     , .DMA_CHUNK(DMA_CHUNK )
   );

   //-----------------------------------------------------
   dma_axi_simple_core #(.AXI_MST_ID   (AXI_MST_ID   ) // Master ID
                        ,.AXI_WIDTH_CID(AXI_WIDTH_CID)
                        ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                        ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                        ,.AXI_WIDTH_DA (AXI_WIDTH_DA ))// data width
   u_core (
       .ARESETn  (ARESETn   )
     , .ACLK     (ACLK      )
     `AMBA_AXI_MASTER_PORT_CONNECTION
     , .DMA_EN   (DMA_EN    )
     , .DMA_GO   (DMA_GO    )
     , .DMA_BUSY (DMA_BUSY  )
     , .DMA_DONE (DMA_DONE  )
     , .DMA_SRC  (DMA_SRC   )
     , .DMA_DST  (DMA_DST   )
     , .DMA_BNUM (DMA_BNUM  )
     , .DMA_CHUNK(DMA_CHUNK )
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
endmodule
//----------------------------------------------------------
// Revision history
//
// 2015.07.12: Started by Ando Ki.
//----------------------------------------------------------
