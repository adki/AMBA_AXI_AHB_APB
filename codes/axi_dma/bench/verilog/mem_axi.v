//----------------------------------------------------------------
//  Copyright (c) 2013 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// mem_axi.v
//----------------------------------------------------------------
// VERSION: 2013.02.03.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4                  - AMBA AXI4
//    AMBA_AXI_CACHE
//    AMBA_AXI_PROT
//    BURST_TYPE_WRAPP_ENABLED   - Burst wrapping type enabled
//----------------------------------------------------------------
//  [PARAMETER]
//----------------------------------------------------------------
// size of memory in byte: 1<<ADDR_LENGTH
//----------------------------------------------------------------
`timescale 1ns/1ns

`include "mem_axi_dpram_sync.v"

module mem_axi #(parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
                         , AXI_WIDTH_ID = 4 // ID width in bits
                         , AXI_WIDTH_AD =32 // address width
                         , AXI_WIDTH_DA =32 // data width
                         , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
                         , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
                         , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
                         , ADDR_LENGTH  =12 // effective addre bits
                         )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     , input  wire [AXI_WIDTH_SID-1:0] AWID
     , input  wire [AXI_WIDTH_AD-1:0]  AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              AWLEN
     , input  wire                     AWLOCK
     `else
     , input  wire [ 3:0]              AWLEN
     , input  wire [ 1:0]              AWLOCK
     `endif
     , input  wire [ 2:0]              AWSIZE
     , input  wire [ 1:0]              AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              AWPROT
     `endif
     , input  wire                     AWVALID
     , output reg                      AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              AWQOS
     , input  wire [ 3:0]              AWREGION
     `endif
     , input  wire [AXI_WIDTH_SID-1:0] WID
     , input  wire [AXI_WIDTH_DA-1:0]  WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  WSTRB
     , input  wire                     WLAST
     , input  wire                     WVALID
     , output reg                      WREADY
     , output reg  [AXI_WIDTH_SID-1:0] BID
     , output reg  [ 1:0]              BRESP
     , output reg                      BVALID
     , input  wire                     BREADY
     , input  wire [AXI_WIDTH_SID-1:0] ARID
     , input  wire [AXI_WIDTH_AD-1:0]  ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              ARLEN
     , input  wire                     ARLOCK
     `else
     , input  wire [ 3:0]              ARLEN
     , input  wire [ 1:0]              ARLOCK
     `endif
     , input  wire [ 2:0]              ARSIZE
     , input  wire [ 1:0]              ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              ARPROT
     `endif
     , input  wire                     ARVALID
     , output reg                      ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              ARQOS
     , input  wire [ 3:0]              ARREGION
     `endif
     , output reg  [AXI_WIDTH_SID-1:0] RID
     , output reg  [AXI_WIDTH_DA-1:0]  RDATA
     , output reg  [ 1:0]              RRESP
     , output reg                      RLAST
     , output reg                      RVALID
     , input  wire                     RREADY
     , input  wire                     CSYSREQ
     , output wire                     CSYSACK
     , output wire                     CACTIVE
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     assign CSYSACK = CSYSREQ;
     assign CACTIVE = 1'b1;
     //-----------------------------------------------------------
     reg  [ADDR_LENGTH-1:0]  Twaddr ;
     reg  [AXI_WIDTH_DA-1:0] Twdata ;
     reg  [AXI_WIDTH_DS-1:0] Twstrb ;
     reg                     Twen   ;
     reg  [ADDR_LENGTH-1:0]  Traddr ;
     wire [AXI_WIDTH_DA-1:0] Trdata ;
     reg  [AXI_WIDTH_DS-1:0] Trstrb ;
     reg                     Tren   ; // driven by stateR
     wire                    TrenX  ; // actual Tren
     //-----------------------------------------------------------
     // write case
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_SID-1:0] AWID_reg   ;
     reg  [AXI_WIDTH_AD-1:0]  AWADDR_reg ;
     `ifdef AMBA_AXI4
     reg  [ 7:0]              AWLEN_reg  ;
     reg                      AWLOCK_reg ;
     `else
     reg  [ 3:0]              AWLEN_reg  ;
     reg  [ 1:0]              AWLOCK_reg ;
     `endif
     reg  [ 2:0]              AWSIZE_reg ;
     reg  [ 1:0]              AWBURST_reg;
     reg  [ 3:0]              AWCACHE_reg;
     reg  [ 2:0]              AWPROT_reg ;
     //-----------------------------------------------------------
     reg  [ADDR_LENGTH-1:0] addrW; // address of each transfer within a burst
     `ifdef AMBA_AXI4
     reg  [ 7:0]            beatW; // keeps num of transfers within a burst
     `else
     reg  [ 3:0]            beatW; // keeps num of transfers within a burst
     `endif
     //-----------------------------------------------------------
     reg [1:0] stateW;
     localparam STW_IDLE   = 'h0,
                STW_WRITE0 = 'h1,
                STW_WRITE  = 'h2,
                STW_RSP    = 'h3;
     always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             AWID_reg    <= 'h0;
             AWADDR_reg  <= 'h0;
             AWLEN_reg   <= 'h0;
             AWSIZE_reg  <= 'b0;
             AWBURST_reg <= 'b0;
             AWLOCK_reg  <= 'b0;
             AWCACHE_reg <= 'h0;
             AWPROT_reg  <= 'b0;
             AWREADY     <= 1'b0;
             WREADY      <= 1'b0;
             BID         <=  'h0;
             BRESP       <= 2'b10; // SLAVE ERROR
             BVALID      <= 1'b0;
             addrW       <=  'h0;
             beatW       <=  'h0;
             Twaddr      <=  'h0;
             Twdata      <=  'h0;
             Twstrb      <=  'h0;
             Twen        <= 1'b0;
             stateW      <= STW_IDLE;
         end else begin
             case (stateW)
             STW_IDLE: begin
                 if ((AWVALID==1'b1)&&(AWREADY==1'b1)) begin
                      AWID_reg    <= AWID   ;
                      AWADDR_reg  <= AWADDR ;
                      AWLEN_reg   <= AWLEN  ;
                      AWSIZE_reg  <= AWSIZE ;
                      AWBURST_reg <= AWBURST;
                      AWLOCK_reg  <= AWLOCK ;
                      `ifdef AMBA_AXI_CACHE
                      AWCACHE_reg <= AWCACHE;
                      `else
                      AWCACHE_reg <= 'h0;
                      `endif
                      `ifdef AMBA_AXI_PROT
                      AWPROT_reg  <= AWPROT ;
                      `else
                      AWPROT_reg  <= 'h0;
                      `endif
                      AWREADY     <= 1'b0;
                      WREADY      <= 1'b1;
                      BRESP       <= 2'b00; // OKAY
                      addrW       <= AWADDR[ADDR_LENGTH-1:0];
                      beatW       <=  'h0;
                      stateW      <= STW_WRITE0;
                 end else begin
                      AWREADY <= 1'b1;
                 end
                 end // STW_IDLE
             STW_WRITE0: begin
                 if (WVALID==1'b1) begin
                     Twaddr <= addrW;
                     Twdata <= WDATA;
                     Twstrb <= WSTRB;
                     Twen   <= 1'b1;
                     beatW  <= beatW + 1;
                     addrW  <= get_next_addr_wr(addrW,AWSIZE_reg,AWBURST_reg,AWLEN_reg);
                     if (beatW>=AWLEN_reg) begin
                         WREADY <= 1'b0;
                         BVALID <= 1'b1;
                         BID    <= AWID_reg;
                         if (WLAST==1'b0) BRESP <= 2'b10; // SLVERR - missing last
                         stateW <= STW_RSP;
                     end else begin
                         stateW <= STW_WRITE;
                     end
                     if (WID!=AWID_reg) BRESP <= 2'b10; // SLVERR - ID mis-match occured
                 end else begin
                     Twen   <= 1'b0;
                 end
                 end // STW_WRITE0
             STW_WRITE: begin
                 if (WVALID==1'b1) begin
                     Twaddr <= addrW;
                     Twdata <= WDATA;
                     Twstrb <= WSTRB;
                     Twen   <= 1'b1;
                     beatW  <= beatW + 1;
                     addrW  <= get_next_addr_wr(addrW,AWSIZE_reg,AWBURST_reg,AWLEN_reg);
                     if (beatW>=AWLEN_reg) begin
                         WREADY <= 1'b0;
                         BVALID <= 1'b1;
                         BID    <= AWID_reg;
                         if (WLAST==1'b0) BRESP <= 2'b10; // SLVERR - missing last
                         stateW <= STW_RSP;
                     end
                     if (WID!=AWID_reg) BRESP <= 2'b10; // SLVERR - ID mis-match occured
                 end else begin
                     Twen   <= 1'b0;
                 end
                 end // STW_WRITE
             STW_RSP: begin
                 Twen   <= 1'b0;
                 if (BREADY==1'b1) begin
                     BVALID  <= 1'b0;
                     AWREADY <= 1'b1;
                     stateW  <= STW_IDLE;
                 end
                 end // STW_RSP
             endcase
         end
     end
     //-----------------------------------------------------------
     // read case
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_AD-1:0]  ARADDR_reg ;
     `ifdef AMBA_AXI4
     reg  [ 7:0]          ARLEN_reg  ;
     reg                  ARLOCK_reg ;
     `else
     reg  [ 3:0]          ARLEN_reg  ;
     reg  [ 1:0]          ARLOCK_reg ;
     `endif
     reg  [ 2:0]          ARSIZE_reg ;
     reg  [ 1:0]          ARBURST_reg;
     reg  [ 3:0]          ARCACHE_reg;
     reg  [ 2:0]          ARPROT_reg ;
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_DA-1:0]    dataR;
     reg  [ADDR_LENGTH-1:0] addrR; // address of each transfer within a burst
     reg  [AXI_WIDTH_DS-1:0]    strbR; // strobe
     `ifdef AMBA_AXI4
     reg  [ 7:0]            beatR; // keeps num of transfers within a burst
     `else
     reg  [ 3:0]            beatR; // keeps num of transfers within a burst
     `endif
     //-----------------------------------------------------------
     reg [3:0] stateR;
     localparam STR_IDLE   = 'h0,
                STR_READ0  = 'h1,
                STR_READ1  = 'h2,
                STR_READ2  = 'h3,
                STR_READ21 = 'h4,
                STR_READ22 = 'h5,
                STR_READ3  = 'h6,
                STR_READ31 = 'h7,
                STR_READ32 = 'h8,
                STR_READ33 = 'h9,
                STR_READ34 = 'hA,
                STR_END    = 'hB;
     always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             ARADDR_reg  <= 'h0;
             ARLEN_reg   <= 'h0;
             ARLOCK_reg  <= 'b0;
             ARSIZE_reg  <= 'b0;
             ARBURST_reg <= 'b0;
             ARCACHE_reg <= 'h0;
             ARPROT_reg  <= 'b0;
             ARREADY     <= 1'b0;
             RID         <=  'h0;
             RLAST       <= 1'b0;
             RRESP       <= 2'b10; // SLAERROR
             RDATA       <=  'h0;
             RVALID      <= 1'b0;
             dataR       <=  'h0;
             addrR       <=  'h0;
             strbR       <=  'h0;
             beatR       <=  'h0;
             Traddr      <=  'h0;
             Trstrb      <=  'h0;
             Tren        <= 1'b0;
             stateR      <= STR_IDLE;
         end else begin
             case (stateR)
             STR_IDLE: begin
                 if ((ARVALID==1'b1)&&(ARREADY==1'b1)) begin
                      ARADDR_reg  <= ARADDR ;
                      ARLEN_reg   <= ARLEN  ;
                      ARSIZE_reg  <= ARSIZE ;
                      ARBURST_reg <= ARBURST;
                      ARLOCK_reg  <= ARLOCK ;
                      `ifdef AMBA_AXI_CACHE
                      ARCACHE_reg <= ARCACHE;
                      `else
                      ARCACHE_reg <= 'h0;
                      `endif
                      `ifdef AMBA_AXI_PROT
                      ARPROT_reg  <= ARPROT ;
                      `else
                      ARPROT_reg  <= 'h0;
                      `endif
                      ARREADY     <= 1'b0;
                      RID         <= ARID;
                      addrR       <= get_next_addr_rd(ARADDR[ADDR_LENGTH-1:0],ARSIZE,ARBURST,ARLEN);
                      beatR       <=  'h0;
                      Traddr      <= ARADDR[ADDR_LENGTH-1:0];
                      Trstrb      <= get_strb(ARADDR[ADDR_LENGTH-1:0],ARSIZE);
                      Tren        <= 1'b1;
                      stateR      <= STR_READ0;
                 end else begin
                     ARREADY <= 1'b1;
                 end
                 end // STR_IDLE
             STR_READ0: begin // address only
                 if (ARLEN_reg=='h0) begin // single beat burst
                     Tren   <= 1'b0;
                     stateR <= STR_READ1;
                 end else if (ARLEN_reg=='h1) begin // two-beat burst
                     Tren   <= 1'b1;
                     Traddr <= addrR;
                     Trstrb <= get_strb(addrR,ARSIZE_reg);
                     stateR <= STR_READ2;
                 end else begin // three or more beat burst
                     Tren   <= 1'b1;
                     Traddr <= addrR;
                     Trstrb <= get_strb(addrR,ARSIZE_reg);
                     addrR  <= get_next_addr_rd(addrR,ARSIZE_reg,ARBURST_reg,ARLEN_reg);
                     beatR  <= 1;
                     stateR <= STR_READ3;
                 end
                 end // STR_READ0
             STR_READ1: begin // data only
                 RLAST  <= 1'b1;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_END;
                 end // STR_READ1
             STR_READ2: begin // two-beat burst
                 Tren   <= 1'b0;
                 RLAST  <= 1'b0;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_READ21;
                 end // STR_READ2;
             STR_READ21: begin // two-beat burst
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b1;
                     RDATA  <= Trdata;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     stateR <= STR_END;
                 end else begin
                     dataR   <= Trdata;
                     stateR  <= STR_READ22;
                 end
                 end // STR_READ21
             STR_READ22: begin // two-beat burst
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b1;
                     RDATA  <= dataR ;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     stateR <= STR_END;
                 end
                 end // STR_READ22
             STR_READ3: begin // n-beat burst
                 RLAST  <= 1'b0;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 Tren   <= 1'b1;
                 Traddr <= addrR;
                 Trstrb <= get_strb(addrR,ARSIZE_reg);
                 addrR  <= get_next_addr_rd(addrR,ARSIZE_reg,ARBURST_reg,ARLEN_reg);
                 beatR  <= beatR + 1;
                 stateR <= STR_READ31;
                 end // STR_READ3;
             STR_READ31: begin
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b0;
                     RDATA  <= Trdata;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     if (beatR>=ARLEN_reg) begin
                        Tren   <= 1'b1; // actually RREADY determines it
                        Traddr <= addrR;
                        stateR <= STR_READ33;
                     end else begin
                        Tren   <= 1'b1;
                        Traddr <= addrR;
                        Trstrb <= get_strb(addrR,ARSIZE_reg);
                        addrR  <= get_next_addr_rd(addrR,ARSIZE_reg,ARBURST_reg,ARLEN_reg);
                     end
                     beatR  <= beatR + 1;
                 end else begin
                     Tren   <= 1'b1; // actually RREADY determines it
                     dataR  <= Trdata;
                     stateR <= STR_READ32;
                 end
                 end // STR_READ31
             STR_READ32: begin
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b0;
                     RDATA  <= dataR;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     dataR  <= Trdata;
                     if (beatR>=ARLEN_reg) begin
                        Tren   <= 1'b0;
                        stateR <= STR_READ33;
                     end else begin
                        Tren   <= 1'b1; // actually RREADY determines it
                        Traddr <= addrR;
                        Trstrb <= get_strb(addrR,ARSIZE_reg);
                        addrR  <= get_next_addr_rd(addrR,ARSIZE_reg,ARBURST_reg,ARLEN_reg);
                        stateR <= STR_READ31;
                     end
                     beatR  <= beatR + 1;
                 end
                 end // STR_READ32
             STR_READ33: begin
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b1;
                     RDATA  <= Trdata;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     stateR <= STR_END;
                 end else begin
                     Tren   <= 1'b0;
                     dataR  <= Trdata;
                     stateR <= STR_READ34;
                 end
                 end // STR_READ33
             STR_READ34: begin
                 if (RREADY==1'b1) begin
                     RLAST  <= 1'b1;
                     RDATA  <= dataR;
                     RRESP  <= 2'b00;
                     RVALID <= 1'b1;
                     stateR <= STR_END;
                 end
                 end // STR_READ34
             STR_END: begin // data only
                 if (RREADY==1'b1) begin
                     RDATA   <=  'h0;
                     RRESP   <= 2'b10; // SLVERR
                     RLAST   <= 1'b0;
                     RVALID  <= 1'b0;
                     ARREADY <= 1'b1;
                     stateR  <= STR_IDLE;
                 end
                 end // STR_END
             endcase
         end
     end
     //-----------------------------------------------------------
     function [7:0] get_bytes;
          input [2:0] size;
          get_bytes = 1<<size;
     endfunction
     //-----------------------------------------------------------
     function [AXI_WIDTH_DS-1:0] get_strb;
          input [ADDR_LENGTH-1:0] addr;
          input [ 2:0]            size;  // num. of byte to move: 0=1-byte, 1=2-byte
          reg   [AXI_WIDTH_DS-1:0]    offset;
     begin
          offset = addr[AXI_WIDTH_DSB-1:0]; //offset = addr%AXI_WIDTH_DS;
          case (size)
          3'b000: get_strb = {  1{1'b1}}<<offset;
          3'b001: get_strb = {  2{1'b1}}<<offset;
          3'b010: get_strb = {  4{1'b1}}<<offset;
          3'b011: get_strb = {  8{1'b1}}<<offset;
          3'b100: get_strb = { 16{1'b1}}<<offset;
          3'b101: get_strb = { 32{1'b1}}<<offset;
          3'b110: get_strb = { 64{1'b1}}<<offset;
          3'b111: get_strb = {128{1'b1}}<<offset;
          endcase
     end
     endfunction
     //-----------------------------------------------------------
     function [ADDR_LENGTH-1:0] get_next_addr_wr;
          input [ADDR_LENGTH-1:0] addr ;
          input [ 2:0]            size ;
          input [ 1:0]            burst; // burst type
          `ifdef AMBA_AXI4
          input [ 7:0]            len  ; // burst length
          `else
          input [ 3:0]            len  ; // burst length
          `endif
          reg   [ADDR_LENGTH-AXI_WIDTH_DSB-1:0] naddr;
          reg   [ADDR_LENGTH-1:0] mask ;
     begin
          case (burst)
          2'b00: get_next_addr_wr = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_wr = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH-1:AXI_WIDTH_DSB];
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
     function [ADDR_LENGTH-1:0] get_next_addr_rd;
          input [ADDR_LENGTH-1:0] addr ;
          input [ 2:0]            size ;
          input [ 1:0]            burst; // burst type
          `ifdef AMBA_AXI4
          input [ 7:0]            len  ; // burst length
          `else
          input [ 3:0]            len  ; // burst length
          `endif
          reg   [ADDR_LENGTH-AXI_WIDTH_DSB-1:0] naddr;
          reg   [ADDR_LENGTH-1:0] mask ;
     begin
          case (burst)
          2'b00: get_next_addr_rd = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_rd = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH-1:AXI_WIDTH_DSB];
                     naddr = naddr + 1;
                     get_next_addr_rd = {naddr,{AXI_WIDTH_DSB{1'b0}}};
                 end
                 end
          2'b10: begin
                 `ifdef BURST_TYPE_WRAPP_ENABLED
                 mask          = get_wrap_mask(size,len);
                 get_next_addr_rd = (addr&~mask)
                               | (((addr&mask)+(1<<size))&mask);
                 `else
                 // synopsys translate_off
                 $display($time,,"%m ERROR BURST WRAP not supported");
                 // synopsys translate_on
                 `endif
                 end
          2'b11: begin
                 get_next_addr_rd = addr;
                 // synopsys translate_off
                 $display($time,,"%m ERROR un-defined BURST %01x", burst);
                 // synopsys translate_on
                 end
          endcase
     end
     endfunction
     //-----------------------------------------------------------
     `ifdef BURST_TYPE_WRAPP_ENABLED
     function [ADDR_LENGTH-1:0] get_wrap_mask;
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
     assign TrenX = ((stateR==STR_READ31)||(stateR==STR_READ32))
                  ? RREADY : Tren;
     //-----------------------------------------------------------
     // a sort of dual-port memory with write-first feature
     mem_axi_dpram_sync #(.WIDTH_AD   (ADDR_LENGTH ) // size of memory in byte
                         ,.WIDTH_DA   (AXI_WIDTH_DA) // width of a line in bytes
                         )
     u_dpram
     (
             .RESETn (ARESETn)
           , .CLK    (ACLK   )
           , .WADDR  (Twaddr )
           , .WDATA  (Twdata )
           , .WSTRB  (Twstrb )
           , .WEN    (Twen   )
           , .RADDR  (Traddr )
           , .RDATA  (Trdata )
           , .RSTRB  (Trstrb )
           , .REN    (TrenX  )
     );
     //-----------------------------------------------------------
     // synopsys translate_off
     integer abits, depth;
     initial begin
        depth  = 1<<ADDR_LENGTH;
        $display("%m INFO %03dK (%06d) byte memory", depth/1024, depth);
        abits = ADDR_LENGTH-AXI_WIDTH_DSB;
        //if (abits>10) begin
        //       $display("%m INFO sdpram_8x%02dK should be used", 1<<(abits-10));
        //end else begin
        //       $display("%m INFO sdpram_8x%03d should be used", 1<<abits);
        //end
     end
     // synopsys translate_on
     //-----------------------------------------------------------
endmodule

//----------------------------------------------------------------
// Revision History
//
// 2013.02.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
