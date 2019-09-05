//----------------------------------------------------------------
//  Copyright (c) 2015 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//----------------------------------------------------------------
// dma_axi_simple_csr_write.v
//----------------------------------------------------------------
// VERSION: 2015.07.12.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4                  - AMBA AXI4
//    BURST_TYPE_WRAPP_ENABLED   - Burst wrapping type enabled
//----------------------------------------------------------------
// Limitations:
//----------------------------------------------------------------
`include "dma_axi_simple_defines.v"
`timescale 1ns/1ns

module dma_axi_simple_csr_write
     #(parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
               , AXI_WIDTH_ID = 4 // ID width in bits
               , AXI_WIDTH_AD =32 // address width
               , AXI_WIDTH_DA =32 // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               , ADDR_LENGTH = 8 // size of memory
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     `undef Otype `define Otype reg 
     `undef Itype `define Itype wire
     `AMBA_AXI_SLAVE_PORT_AW
     `AMBA_AXI_SLAVE_PORT_W
     `AMBA_AXI_SLAVE_PORT_B
     //-----------------------------------------------------------
     , output reg                      TW_REQ=1'b0
     , input  wire                     TW_GRT
     , output reg  [ADDR_LENGTH-1:0]   TW_ADDR='h0
     , output reg                      TW_WREN=1'b0
     , output reg  [31:0]              TW_WDATA=32'h0
     , output reg  [ 3:0]              TW_WSTRB=4'h0
);
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_SID-1:0] S_AWID_reg   ;
     reg  [AXI_WIDTH_AD-1:0]  S_AWADDR_reg ;
     `ifdef AMBA_AXI4
     reg  [ 7:0]              S_AWLEN_reg  ; // note 0 means one-beat
     reg                      S_AWLOCK_reg ;
     `else
     reg  [ 3:0]              S_AWLEN_reg  ;
     reg  [ 1:0]              S_AWLOCK_reg ;
     `endif
     reg  [ 2:0]              S_AWSIZE_reg ;
     reg  [ 1:0]              S_AWBURST_reg;
     reg  [ 3:0]              S_AWCACHE_reg;
     reg  [ 2:0]              S_AWPROT_reg ;
     //-----------------------------------------------------------
     reg  [ADDR_LENGTH+1:0] addrW; // address of each transfer within a burst
     `ifdef AMBA_AXI4
     reg  [ 8:0]            beatW; // keeps num of transfers within a burst
     `else
     reg  [ 4:0]            beatW; // keeps num of transfers within a burst
     `endif
     //-----------------------------------------------------------
     localparam STW_IDLE   = 'h0,
                STW_ARB    = 'h1,
                STW_WRITE  = 'h2,
                STW_RSP    = 'h3;
     reg [2:0] stateW=STW_IDLE; // synthesis attribute keep stateW is "true"
     always @ (posedge ACLK or negedge ARESETn) begin
     if (ARESETn==1'b0) begin
         S_AWID_reg    <= 'h0;
         S_AWADDR_reg  <= 'h0;
         S_AWLEN_reg   <= 'h0;
         S_AWSIZE_reg  <= 'b0;
         S_AWBURST_reg <= 'b0;
         S_AWLOCK_reg  <= 'b0;
         S_AWCACHE_reg <= 'h0;
         S_AWPROT_reg  <= 'b0;
         S_AWREADY     <= 1'b0;
         S_WREADY      <= 1'b0;
         S_BID         <=  'h0;
         S_BRESP       <= 2'b10; // SLAVE ERROR
         S_BVALID      <= 1'b0;
         addrW       <=  'h0;
         beatW       <=  'h0;
         TW_REQ      <= 1'b0;
         TW_ADDR     <= 8'h0;
         TW_WREN     <= 1'b0;
         TW_WDATA    <=32'h0;
         stateW      <= STW_IDLE;
     end else begin
         case (stateW)
         STW_IDLE: begin
             if ((S_AWVALID==1'b1)&&(S_AWREADY==1'b1)) begin
                  S_AWID_reg    <= S_AWID   ;
                  S_AWADDR_reg  <= S_AWADDR ;
                  S_AWLEN_reg   <= S_AWLEN  ;
                  S_AWSIZE_reg  <= S_AWSIZE ;
                  S_AWBURST_reg <= S_AWBURST;
                  S_AWLOCK_reg  <= S_AWLOCK ;
                  `ifdef AMBA_AXI_CACHE
                  S_AWCACHE_reg <= S_AWCACHE;
                  `else
                  S_AWCACHE_reg <= 'h0;
                  `endif
                  `ifdef AMBA_AXI_PROT
                  S_AWPROT_reg  <= S_AWPROT ;
                  `else
                  S_AWPROT_reg  <= 'h0;
                  `endif
                  S_AWREADY     <= 1'b0;
                  S_WREADY      <= 1'b0;
                  S_BRESP       <= 2'b00; // OKAY
                  addrW       <= S_AWADDR[ADDR_LENGTH+1:0];
                  beatW       <=  'h0;
                  TW_REQ      <= 1'b1;
                  TW_WREN     <= 1'b0;
                  if (TW_GRT) stateW <= STW_WRITE;
                  else        stateW <= STW_ARB;
                  // synthesis translate_off
                  if (S_AWLEN!=='h0) $display($time,,"%m ERROR burst not allowed");
                  if (S_AWSIZE!=='h2) $display($time,,"%m ERROR partial not allowed");
                  // synthesis translate_on
             end else begin
                 S_AWREADY <= 1'b1;
                 TW_WREN <= 1'b0;
                 TW_REQ  <= 1'b0;
             end
             end // STW_IDLE
         STW_ARB: begin
             if (TW_GRT) begin
                 stateW <= STW_WRITE;
                 S_WREADY <= 1'b1;
             end
             end // STW_ARB
         STW_WRITE: begin
             if ((S_WVALID==1'b1)&&(S_WREADY==1'b1)) begin
                 TW_ADDR  <= {addrW[ADDR_LENGTH-1:2], 2'b0};
                 if (AXI_WIDTH_DA==128) begin
                     TW_WDATA <= S_WDATA>>(addrW[3:2]<<3);
                     //case (addrW[3:2])
                     //2'b00: TW_WDATA <= S_WDATA[ 31:0 ];
                     //2'b01: TW_WDATA <= S_WDATA[ 63:32];
                     //2'b10: TW_WDATA <= S_WDATA[ 95:64];
                     //2'b11: TW_WDATA <= S_WDATA[127:96];
                     //endcase
                 end else if (AXI_WIDTH_DA==64) begin
                     TW_WDATA <= S_WDATA>>(addrW[2]<<3);
                     //if (addrW[2]) begin
                     //    TW_WDATA <= S_WDATA[63:32];
                     //end else begin
                     //    TW_WDATA <= S_WDATA[31:0];
                     //end
                 end else begin
                     TW_WDATA <= S_WDATA;
                 end
                 TW_WSTRB <= S_WSTRB;
                 TW_WREN  <= 1'b1;
                 beatW    <= beatW + 1;
                 addrW    <= get_next_addr_wr(addrW,S_AWSIZE_reg,S_AWBURST_reg,S_AWLEN_reg);
                 if (beatW>=S_AWLEN_reg) begin
                     S_WREADY <= 1'b0;
                     S_BVALID <= 1'b1;
                     S_BID    <= S_AWID_reg;
                     if (S_WLAST==1'b0) S_BRESP <= 2'b10; // SLVERR - missing last
                     stateW  <= STW_RSP;
                 end
                 if (S_WID!=S_AWID_reg) S_BRESP <= 2'b10; // SLVERR - ID mis-match occured
             end else begin
                 S_WREADY  <= 1'b1;
                 TW_WREN <= 1'b0;
             end
             end // STW_WRITE
         STW_RSP: begin
             TW_WREN <= 1'b0;
             if (S_BREADY==1'b1) begin
                 S_BVALID  <= 1'b0;
                 S_AWREADY <= 1'b1;
                 stateW  <= STW_IDLE;
             end
             end // STW_RSP
         endcase
     end // if
     end // always
     //-----------------------------------------------------------
     function [ADDR_LENGTH+1:0] get_next_addr_wr;
          input [ADDR_LENGTH+1:0] addr ;
          input [ 2:0]            size ;
          input [ 1:0]            burst; // burst type
          `ifdef AMBA_AXI4
          input [ 7:0]            len  ; // burst length
          `else
          input [ 3:0]            len  ; // burst length
          `endif
          reg   [ADDR_LENGTH-AXI_WIDTH_DSB+1:0] naddr;
          reg   [ADDR_LENGTH+1:0] mask ;
     begin
          case (burst)
          2'b00: get_next_addr_wr = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_wr = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH+1:AXI_WIDTH_DSB];
                     naddr = naddr + 1;
                     get_next_addr_wr = {naddr,{AXI_WIDTH_DSB{1'b0}}};
                 end
                 end
          2'b10: begin
                 `ifdef BURST_TYPE_WRAPP_ENABLED
                 mask          = get_wrap_mask(size,len);
                 get_next_addr_wr = (addr&~mask)
                               | (((addr&mask)+(1<<size))&mask);
                 `else
                 // synopsys translate_off
                 $display($time,,"%m ERROR BURST WRAP not supported");
                 // synopsys translate_on
                 `endif
                 end
          2'b11: begin
                 get_next_addr_wr = addr;
                 // synopsys translate_off
                 $display($time,,"%m ERROR un-defined BURST %01x", burst);
                 // synopsys translate_on
                 end
          endcase
     end
     endfunction
     //-----------------------------------------------------------
     `ifdef BURST_TYPE_WRAPP_ENABLED
     function [ADDR_LENGTH+1:0] get_wrap_mask;
          input [ 2:0]      size ;
          `ifdef AMBA_AXI4
          input [ 7:0]      len  ; // burst length
          `else
          input [ 3:0]      len  ; // burst length
          `endif
     begin
          case (size)
          3'b000: get_wrap_mask = (    len)-1;
          3'b001: get_wrap_mask = (  2*len)-1;
          3'b010: get_wrap_mask = (  4*len)-1;
          3'b011: get_wrap_mask = (  8*len)-1;
          3'b100: get_wrap_mask = ( 16*len)-1;
          3'b101: get_wrap_mask = ( 32*len)-1;
          3'b110: get_wrap_mask = ( 64*len)-1;
          3'b111: get_wrap_mask = (128*len)-1;
          endcase
     end
     endfunction
     `endif
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

//----------------------------------------------------------------
// Revision History
//
// 2015.07.12: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
