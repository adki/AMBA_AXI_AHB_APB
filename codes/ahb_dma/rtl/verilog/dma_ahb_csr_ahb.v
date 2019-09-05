//----------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// dma_ahb_csr_ahb.v
//----------------------------------------------------------
// VERSION: 2014.04.29.
//----------------------------------------------------------
// CSR interface
//----------------------------------------------------------
// Limitations:
//  - No partial access supported; only word access
//  - HLOCK is not supported
//  - Split transaction is not supported
//  - Early termination is not supported
//  - Busy (HTRANS) is not supported
//  - All burst transactions should go on
//    without BUSY cycle
//----------------------------------------------------------
`timescale  1ns/1ns
`include "dma_ahb_csr.v"

module dma_ahb_csr_ahb
(
       input   wire          HRESETn 
     , input   wire          HCLK
     , input   wire          HSEL
     , input   wire  [31:0]  HADDR
     , input   wire  [ 1:0]  HTRANS
     , input   wire          HWRITE
     , input   wire  [ 2:0]  HSIZE
     , input   wire  [ 2:0]  HBURST
     , input   wire  [31:0]  HWDATA
     , output  reg   [31:0]  HRDATA
     , output  wire  [ 1:0]  HRESP
     , input   wire          HREADYin
     , output  reg           HREADYout
     , output  wire          IRQ
     //---------------------------------------------------
     , output  wire          DMA_EN
     , output  wire          DMA_GO
     , input   wire          DMA_BUSY
     , input   wire          DMA_DONE
     , output  wire  [31:0]  DMA_SRC
     , output  wire  [31:0]  DMA_DST
     , output  wire  [15:0]  DMA_BNUM // num of bytes to move
     , output  wire  [ 4:0]  DMA_BURST // burst length 1, 4, 8 , 16
);
   //---------------------------------------------------
   assign HRESP = 2'b00; // `HRESP_OKAY;
   //---------------------------------------------------
   // CSR access signals
   localparam T_ADDR_WID = 8;
   reg  [T_ADDR_WID-1:0] T_ADDR;
   reg                   T_WREN;
   reg                   T_RDEN;
   reg  [31:0]           T_WDATA; // should be valid during T_WREN
   wire [31:0]           T_RDATA; // should be valid after one cycle from T_RDEN
   reg  [ 2:0]           T_SIZE;
   //-------------------------------------------------
   reg [2:0] state;
   localparam STH_IDLE   = 3'h0,
              STH_WRITE0 = 3'h1,
              STH_WRITE1 = 3'h2,
              STH_READ0  = 3'h3, 
              STH_READ1  = 3'h4;
   //-------------------------------------------------
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRDATA    <=  ~'h0;
           HREADYout <=  1'b1;
           T_ADDR    <=   'h0;
           T_WREN    <=  1'b0;
           T_RDEN    <=  1'b0;
           T_WDATA   <=  ~'h0;
           T_SIZE    <=  3'h0;
           state     <= STH_IDLE;
       end else begin // if (HRESETn==0) begin
           case (state)
           STH_IDLE: begin
                T_RDEN    <= 1'b0;
                T_WREN    <= 1'b0;
                if (HSEL && HREADYin) begin
                   case (HTRANS)
                   2'b00, 2'b01: begin //`HTRANS_IDLE, `HTRANS_BUSY
                          HREADYout <= 1'b1;
                          T_RDEN    <= 1'b0;
                          T_WREN    <= 1'b0;
                          state     <= STH_IDLE;
                    end // HTRANS_IDLE or HTRANS_BUSY
                   2'b10, 2'b11: begin //`HTRANS_NONSEQ, `HTRANS_SEQ
                          HREADYout <= 1'b0;
                          T_ADDR    <= HADDR[T_ADDR_WID-1:0];
                          T_SIZE    <= HSIZE;
                          if (HWRITE) begin // write
                              state  <= STH_WRITE0;
                          end else begin // read
                              T_RDEN <= 1'b1; //byte_enable(HADDR[1:0], HSIZE);
                              state  <= STH_READ0;
                          end
                    end // HTRANS_NONSEQ or HTRANS_SEQ
                   endcase // HTRANS
                end else begin// if (HSEL && HREADYin)
                    T_WREN    <= 1'b0;
                    T_RDEN    <= 1'b0;
                    HREADYout <= 1'b1;
                end
                end // STH_IDLE
           STH_WRITE0: begin
                     T_WREN    <= 1'b1;
                     T_WDATA   <= HWDATA;
                     HREADYout <= 1'b1;
                     state     <= STH_WRITE1;
                end // STH_WRITE0
           STH_WRITE1: begin
                     T_WREN    <= 1'b0;
                     T_WDATA   <= 32'b0;
                     HREADYout <= 1'b1;
                     state     <= STH_IDLE;
                end // STH_WRITE1
           STH_READ0: begin
                    T_RDEN    <= 1'b0;
                    state     <= STH_READ1;
                end // STH_READ0
           STH_READ1: begin
                    HREADYout <= 1'b1;
                    HRDATA    <= T_RDATA;
                    state     <= STH_IDLE;
                end // STH_READ1
           endcase // state
       end // if (HRESETn==0)
   end // always
   //---------------------------------------------------------
   dma_ahb_csr #(.T_ADDR_WID(T_ADDR_WID))
   u_csr (
       .RESET_N   (HRESETn)
     , .CLK       (HCLK   )
     , .T_ADDR    (T_ADDR )
     , .T_WREN    (T_WREN )
     , .T_RDEN    (T_RDEN )
     , .T_WDATA   (T_WDATA)
     , .T_RDATA   (T_RDATA)
     , .IRQ       (IRQ    )
     , .DMA_EN    (DMA_EN   )
     , .DMA_GO    (DMA_GO   )
     , .DMA_BUSY  (DMA_BUSY )
     , .DMA_DONE  (DMA_DONE )
     , .DMA_SRC   (DMA_SRC  )
     , .DMA_DST   (DMA_DST  )
     , .DMA_BNUM  (DMA_BNUM )// num of bytes to move
     , .DMA_BURST (DMA_BURST)// burst length 1, 4, 8 , 16
   );
   //---------------------------------------------------
endmodule
//----------------------------------------------------------
// Revision history:
//
// 2014.04.29: Started Ando Ki (adki@dynalith.com)
//-------------------------------------------------------
