//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// VERSION: 2015.07.12.
//----------------------------------------------------------
// DMA AXI simplified version
//----------------------------------------------------------
// Limitations:
// - 32-bit data only: WSTRB is 4-bit only.
//----------------------------------------------------------
`include "dma_axi_simple_defines.v"
`include "dma_axi_simple_csr.v"
`include "dma_axi_simple_csr_read.v"
`include "dma_axi_simple_csr_write.v"
`timescale 1ns/1ns

module dma_axi_simple_csr_axi
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
     `AMBA_AXI_SLAVE_PORT
     //--------------------------------------------------
     , output  wire                    IRQ
     , output  wire                    DMA_EN
     , output  wire                    DMA_GO
     , input   wire                    DMA_BUSY
     , input   wire                    DMA_DONE
     , output  wire  [31:0]            DMA_SRC
     , output  wire  [31:0]            DMA_DST
     , output  wire  [15:0]            DMA_BNUM // num of bytes to move
     , output  wire  [ 7:0]            DMA_CHUNK// num of bytes to move at a time
);
   //-----------------------------------------------------
   localparam T_ADDR_WID=8;
   //-----------------------------------------------------
   wire [T_ADDR_WID-1:0]  T_ADDR ;
   wire                   T_WREN ;
   wire                   T_RDEN ;
   wire [31:0]            T_WDATA;
   wire [31:0]            T_RDATA;
   //-----------------------------------------------------
   wire                   TR_REQ  ;
   reg                    TR_GRT  =1'b0;
   wire [T_ADDR_WID-1:0]  TR_ADDR ;
   wire                   TR_RDEN ;
   wire [31:0]            TR_RDATA;
   //-----------------------------------------------------
   wire                   TW_REQ  ;
   reg                    TW_GRT  =1'b0;
   wire [T_ADDR_WID-1:0]  TW_ADDR ;
   wire                   TW_WREN ;
   wire [31:0]            TW_WDATA;
   wire [ 3:0]            TW_WSTRB;
   //-----------------------------------------------------
   always @ (posedge ACLK or negedge ARESETn) begin
   if (ARESETn==1'b0) begin
       TR_GRT <= 1'b0;
       TW_GRT <= 1'b0;
   end else begin
       casex ({TW_REQ,TR_REQ,TW_GRT,TR_GRT})
       4'b00_00: {TW_GRT,TR_GRT} <= 2'b00;
       // priority
       4'b1x_00: {TW_GRT,TR_GRT} <= 2'b10;
       4'b01_00: {TW_GRT,TR_GRT} <= 2'b01;
       // sustain
       4'b1x_10: {TW_GRT,TR_GRT} <= 2'b10;
       4'bx1_01: {TW_GRT,TR_GRT} <= 2'b01;
       // handover
       4'b01_x0: {TW_GRT,TR_GRT} <= 2'b01;
       4'b10_0x: {TW_GRT,TR_GRT} <= 2'b10;
       // last
       4'b00_xx: {TW_GRT,TR_GRT} <= 2'b00;
       default:  {TW_GRT,TR_GRT} <= 2'b00;
       endcase
   end // if
   end // always
   //-----------------------------------------------------
   assign T_ADDR   = (TW_GRT) ? TW_ADDR : TR_ADDR;
   assign T_WREN   = (TW_GRT) ? TW_WREN : 1'b0   ;
   assign T_RDEN   = (TR_GRT) ? TR_RDEN : 1'b0   ;
   assign T_WDATA  = TW_WDATA;
   assign TR_RDATA = T_RDATA;
   //-----------------------------------------------------
   dma_axi_simple_csr #(.T_ADDR_WID(8))
   u_csr (
       .RESET_N   (ARESETn  )
     , .CLK       (ACLK     )
     , .T_ADDR    (T_ADDR   )
     , .T_WREN    (T_WREN   )
     , .T_RDEN    (T_RDEN   )
     , .T_WDATA   (T_WDATA  )
     , .T_RDATA   (T_RDATA  )
     , .IRQ       (IRQ      )
     , .DMA_EN    (DMA_EN   )
     , .DMA_GO    (DMA_GO   )
     , .DMA_BUSY  (DMA_BUSY )
     , .DMA_DONE  (DMA_DONE )
     , .DMA_SRC   (DMA_SRC  )
     , .DMA_DST   (DMA_DST  )
     , .DMA_BNUM  (DMA_BNUM )// num of bytes to move
     , .DMA_CHUNK (DMA_CHUNK)// AxLEN ( +l beats)
   );
   //-----------------------------------------------------
   dma_axi_simple_csr_read #(.AXI_WIDTH_CID(AXI_WIDTH_CID) // Channel ID width in bits
                            ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                            ,.AXI_WIDTH_SID(AXI_WIDTH_SID) // ID width in bits
                            ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                            ,.AXI_WIDTH_DA (AXI_WIDTH_DA ) // data width
                            ,.ADDR_LENGTH  (T_ADDR_WID   ))
   u_csr_read (
       .ARESETn   (ARESETn )
     , .ACLK      (ACLK    )
     `AMBA_AXI_SLAVE_PORT_CONNECTION_AR
     `AMBA_AXI_SLAVE_PORT_CONNECTION_R
     , .TR_REQ    (TR_REQ  )
     , .TR_GRT    (TR_GRT  )
     , .TR_ADDR   (TR_ADDR )
     , .TR_RDEN   (TR_RDEN )
     , .TR_RDATA  (TR_RDATA)
   );
   //-----------------------------------------------------
   dma_axi_simple_csr_write #(.AXI_WIDTH_CID(AXI_WIDTH_CID)
                             ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                             ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                             ,.AXI_WIDTH_DA (AXI_WIDTH_DA ) // data width
                             ,.ADDR_LENGTH  (T_ADDR_WID   ))
   u_csr_write (
       .ARESETn  (ARESETn )
     , .ACLK     (ACLK    )
     `AMBA_AXI_SLAVE_PORT_CONNECTION_AW
     `AMBA_AXI_SLAVE_PORT_CONNECTION_W
     `AMBA_AXI_SLAVE_PORT_CONNECTION_B
     , .TW_REQ   (TW_REQ  )
     , .TW_GRT   (TW_GRT  )
     , .TW_ADDR  (TW_ADDR )
     , .TW_WREN  (TW_WREN )
     , .TW_WDATA (TW_WDATA)
     , .TW_WSTRB (TW_WSTRB)
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
// 2015.07.12: Started by Ando Ki, based on DIP_0050_cis_if_ahb.v
//----------------------------------------------------------
