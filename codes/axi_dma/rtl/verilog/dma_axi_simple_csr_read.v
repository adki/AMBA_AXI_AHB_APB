//----------------------------------------------------------------
//  Copyright (c) 2015 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//----------------------------------------------------------------
// dma_axi_simple_csr_read.v
//----------------------------------------------------------------
// VERSION: 2017.07.12.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4                  - AMBA AXI4
//----------------------------------------------------------------
`include "dma_axi_simple_defines.v"
`timescale 1ns/1ns

module dma_axi_simple_csr_read
     #(parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
               , AXI_WIDTH_ID = 4 // ID width in bits
               , AXI_WIDTH_AD =32 // address width
               , AXI_WIDTH_DA =32 // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               , ADDR_LENGTH = 8)// size of memory
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     `undef Otype `define Otype reg 
     `undef Itype `define Itype wire
     `AMBA_AXI_SLAVE_PORT_AR
     `AMBA_AXI_SLAVE_PORT_R
     //-----------------------------------------------------------
     , output reg                      TR_REQ=1'b0
     , input  wire                     TR_GRT
     , output reg  [ADDR_LENGTH-1:0]   TR_ADDR='h0
     , output reg                      TR_RDEN=1'b0
     , input  wire [31:0]              TR_RDATA
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_AD-1:0]  S_ARADDR_reg = 'h0;
     `ifdef AMBA_AXI4
     reg  [ 7:0]              S_ARLEN_reg  = 'h0; // note that 0 means one-beat
     reg                      S_ARLOCK_reg =1'b0;
     `else
     reg  [ 3:0]              S_ARLEN_reg  = 'h0;
     reg  [ 1:0]              S_ARLOCK_reg = 'h0;
     `endif
     reg  [ 2:0]              S_ARSIZE_reg = 'h0;
     reg  [ 1:0]              S_ARBURST_reg= 'h0;
     reg  [ 3:0]              S_ARCACHE_reg= 'h0;
     reg  [ 2:0]              S_ARPROT_reg = 'h0;
     reg  [AXI_WIDTH_SID-1:0] S_RID_reg    = 'h0;
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_DA-1:0] dataR='h0;
     reg  [ADDR_LENGTH+1:0]  addrR='h0; // address of each transfer within a burst
     `ifdef AMBA_AXI4
     reg  [ 8:0] beatRA='h0; // keeps num of transfers within a burst for address
     `else
     reg  [ 4:0] beatRA='h0; // keeps num of transfers within a burst for address
     `endif
     //-----------------------------------------------------------
     localparam STR_IDLE          = 'h0,
                STR_READ_ARB      = 'h1,
                STR_READ_ADR      = 'h2,
                STR_READ_DAT      = 'h3,
                STR_READ_DAT_WAIT = 'h4;
     reg [2:0] stateR=STR_IDLE; // synthesis attribute keep stateR is "true"
     //-----------------------------------------------------------
     always @ (posedge ACLK or negedge ARESETn) begin
     if (ARESETn==1'b0) begin
         S_ARADDR_reg  <=  'h0;
         S_ARLEN_reg   <=  'h0;
         S_ARLOCK_reg  <=  'b0;
         S_ARSIZE_reg  <=  'b0;
         S_ARBURST_reg <=  'b0;
         S_ARCACHE_reg <=  'h0;
         S_ARPROT_reg  <=  'b0;
         S_ARREADY     <= 1'b0;
         S_RID_reg     <=  'h0;
         S_RID         <=  'h0;
         S_RDATA       <=  'h0;
         S_RRESP       <= 2'b01;
         S_RLAST       <= 1'b0;
         S_RVALID      <= 1'b0;
         dataR       <=  'h0;
         addrR       <=  'h0;
         beatRA      <=  'h0;
         TR_REQ      <= 1'b0;
         TR_ADDR     <= 8'h0;
         TR_RDEN     <= 1'b0;
         stateR      <= STR_IDLE;
     end else begin
     case (stateR)
     STR_IDLE: begin
         if ((S_ARVALID==1'b1)&&(S_ARREADY==1'b1)) begin
              S_ARADDR_reg  <= S_ARADDR ;
              S_ARLEN_reg   <= S_ARLEN  ;
              S_ARSIZE_reg  <= S_ARSIZE ;
              S_ARBURST_reg <= S_ARBURST;
              S_ARLOCK_reg  <= S_ARLOCK ;
              `ifdef AMBA_AXI_CACHE
              S_ARCACHE_reg <= S_ARCACHE;
              `else
              S_ARCACHE_reg <= 'h0;
              `endif
              `ifdef AMBA_AXI_PROT
              S_ARPROT_reg  <= S_ARPROT ;
              `else
              S_ARPROT_reg  <= 'h0;
              `endif
              S_ARREADY     <= 1'b0;
              S_RID_reg     <= S_ARID;
              addrR       <= S_ARADDR[ADDR_LENGTH+1:0];
              beatRA      <=  'h0;
              TR_RDEN     <= 1'b0;
              TR_REQ      <= 1'b1;
              if (TR_GRT) stateR <= STR_READ_ADR;
              else        stateR <= STR_READ_ARB;
              // synthesis translate_off
              if (S_ARLEN!=='h0) $display($time,,"%m ERROR burst not allowed");
              if (S_ARSIZE!=='h2) $display($time,,"%m ERROR partial not allowed");
              // synthesis translate_on
         end else begin
             S_ARREADY <= 1'b1;
             TR_RDEN <= 1'b0;
             TR_REQ  <= 1'b0;
         end
         end // STR_IDLE
     STR_READ_ARB: begin
         if (TR_GRT) begin
              stateR  <= STR_READ_ADR;
              TR_RDEN <= 1'b1;
              TR_ADDR <= {addrR[ADDR_LENGTH-1:2],2'b0};
              addrR   <= get_next_addr_rd(addrR,S_ARSIZE_reg,S_ARBURST_reg,S_ARLEN_reg);
              stateR  <= STR_READ_ADR;
         end
         end // STR_ARB
     STR_READ_ADR: begin
         TR_RDEN <= 1'b0;
         stateR  <= STR_READ_DAT;
         end // STR_READ_ADR
     STR_READ_DAT: begin
         S_RID    <= S_RID_reg;
         if (AXI_WIDTH_DA==128) begin
             case (addrR[3:2])
             2'b00: begin S_RDATA[127:96] <= 32'h0;
                          S_RDATA[ 95:64] <= 32'h0;
                          S_RDATA[ 63:32] <= 32'h0;
                          S_RDATA[ 31:0 ] <= TR_RDATA;
                    end
             2'b01: begin S_RDATA[127:96] <= 32'h0;
                          S_RDATA[ 95:64] <= 32'h0;
                          S_RDATA[ 63:32] <= TR_RDATA;
                          S_RDATA[ 31:0 ] <= 32'h0;
                    end
             2'b10: begin S_RDATA[127:96] <= 32'h0;
                          S_RDATA[ 95:64] <= TR_RDATA;
                          S_RDATA[ 63:32] <= 32'h0;
                          S_RDATA[ 31:0 ] <= 32'h0;
                    end
             2'b11: begin S_RDATA[127:96] <= TR_RDATA;
                          S_RDATA[ 95:64] <= 32'h0;
                          S_RDATA[ 63:32] <= 32'h0;
                          S_RDATA[ 31:0 ] <= 32'h0;
                    end
             endcase
         end else if (AXI_WIDTH_DA==64) begin
             if (addrR[2]) begin
                 S_RDATA[63:32] <= TR_RDATA;
                 S_RDATA[31:0 ] <= 32'h0;
             end else begin
                 S_RDATA[63:32] <= 32'h0;
                 S_RDATA[31:0 ] <= TR_RDATA;
             end
         end else begin
             S_RDATA  <= TR_RDATA;
         end
         S_RRESP  <= 2'b00;
         S_RVALID <= 1'b1;
         if (S_ARLEN_reg==beatRA) begin
             S_RLAST  <= 1'b1;
             TR_REQ <= 1'b0;
         end
         stateR <= STR_READ_DAT_WAIT;
         end // STR_READ_DAT
     STR_READ_DAT_WAIT: begin
         if (S_RREADY) begin
             beatRA <= beatRA + 'h1;
             S_RVALID <= 1'b0;
             S_RLAST  <= 1'b0;
             if (S_ARLEN_reg==beatRA) begin
                 // note S_ARLEN 0 means one-beat
                 stateR <= STR_IDLE;
             end else begin
                 TR_RDEN <= 1'b1;
                 TR_ADDR <= {addrR[ADDR_LENGTH-1:2],2'b0};
                 addrR   <= get_next_addr_rd(addrR,S_ARSIZE_reg,S_ARBURST_reg,S_ARLEN_reg);
                 stateR  <= STR_READ_ADR;
             end
         end
         end // STR_READ_DAT_WAIT
     endcase
     end // if
     end // always
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
     function [ADDR_LENGTH+1:0] get_next_addr_rd;
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
          2'b00: get_next_addr_rd = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_rd = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH+1:AXI_WIDTH_DSB];
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
