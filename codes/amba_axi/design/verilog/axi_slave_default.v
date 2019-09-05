//----------------------------------------------------------------
//  Copyright (c) 2010 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi_slave_default.v
//----------------------------------------------------------------
// VERSION: 2010.12.30.
//----------------------------------------------------------------
`timescale 1ns/1ns

module axi_slave_default
   // synopsys translate_off
   `protect
   // synopsys translate_on
     #(parameter WIDTH_CID=4        // Channel ID width in bits
               , WIDTH_ID=4         // ID width in bits
               , WIDTH_AD=32        // address width
               , WIDTH_DA=32        // data width
               , WIDTH_DS=WIDTH_DA/8  // data strobe width
               , WIDTH_SID=WIDTH_CID+WIDTH_ID
      )
(
       input  wire                 ARESETn
     , input  wire                 ACLK
     , input  wire [WIDTH_SID-1:0] AWID
     , input  wire [WIDTH_AD-1:0]  AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]          AWLEN
     , input  wire                 AWLOCK
     `else
     , input  wire [ 3:0]          AWLEN
     , input  wire [ 1:0]          AWLOCK
     `endif
     , input  wire [ 2:0]          AWSIZE
     , input  wire [ 1:0]          AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]          AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]          AWPROT
     `endif
     , input  wire                 AWVALID
     , output reg                  AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]          AWQOS
     , input  wire [ 3:0]          AWREGION
     `endif
     , input  wire [WIDTH_SID-1:0] WID
     , input  wire [WIDTH_DA-1:0]  WDATA
     , input  wire [WIDTH_DS-1:0]  WSTRB
     , input  wire                 WLAST
     , input  wire                 WVALID
     , output reg                  WREADY
     , output reg  [WIDTH_SID-1:0] BID
     , output wire [ 1:0]          BRESP
     , output reg                  BVALID
     , input  wire                 BREADY
     , input  wire [WIDTH_SID-1:0] ARID
     , input  wire [WIDTH_AD-1:0]  ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]          ARLEN
     , input  wire                 ARLOCK
     `else
     , input  wire [ 3:0]          ARLEN
     , input  wire [ 1:0]          ARLOCK
     `endif
     , input  wire [ 2:0]          ARSIZE
     , input  wire [ 1:0]          ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]          ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]          ARPROT
     `endif
     , input  wire                 ARVALID
     , output reg                  ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]          ARQOS
     , input  wire [ 3:0]          ARREGION
     `endif
     , output reg  [WIDTH_SID-1:0] RID
     , output wire [WIDTH_DA-1:0]  RDATA
     , output wire [ 1:0]          RRESP
     , output reg                  RLAST
     , output reg                  RVALID
     , input  wire                 RREADY
);
     //-----------------------------------------------------------
     // write case
     //-----------------------------------------------------------
     assign BRESP = 2'b11; // DECERR: decode error
     reg [WIDTH_SID-1:0] awid_reg;
     `ifdef AMBA_AXI4
     reg [8:0] countW, awlen_reg;
     `else
     reg [4:0] countW, awlen_reg;
     `endif
     //-----------------------------------------------------------
     reg [1:0] stateW;
     localparam STW_IDLE   = 'h0,
                STW_RUN    = 'h1,
                STW_WAIT   = 'h2,
                STW_RSP    = 'h3;
     always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             AWREADY   <= 1'b0;
             WREADY    <= 1'b0;
             BID       <=  'h0;
             BVALID    <= 1'b0;
             countW    <=  'h0;
             awlen_reg <=  'h0;
             awid_reg  <=  'h0;
             stateW    <= STW_IDLE;
         end else begin
             case (stateW)
             STW_IDLE: begin
                 if (AWVALID==1'b1) begin
                     AWREADY <= 1'b1;
                     stateW  <= STW_RUN;
                 end
                 end // STW_IDLE
             STW_RUN: begin
                 if ((AWVALID==1'b1)&&(AWREADY==1'b1)) begin
                      AWREADY   <= 1'b0;
                      WREADY    <= 1'b1;
                      awlen_reg <= {1'b0,AWLEN};
                      awid_reg  <= AWID;
                      stateW    <= STW_WAIT;
                 end else begin
                 end
                 end // STW_IDLE
             STW_WAIT: begin
                 if (WVALID==1'b1) begin
                     if ((countW>=awlen_reg)||(WLAST==1'b1)) begin
                         BID    <= awid_reg;
                         BVALID <= 1'b1;
                         WREADY <= 1'b0;
                         countW <= 'h0;
                         stateW <= STW_RSP;
                         // synopsys translate_off
                         if (WLAST==1'b0) begin
                             $display($time,,"%m Error expecting WLAST");
                         end
                         // synopsys translate_on
                     end else begin
                         countW <= countW + 1;
                     end
                 end
                 // synopsys translate_off
                 if ((WVALID==1'b1)&&(WID!=awid_reg)) begin
                     $display($time,,"%m Error AWID(0x%x):WID(0x%x) mismatch", awid_reg, WID);
                 end
                 // synopsys translate_on
                 end // STW_WAIT
             STW_RSP: begin
                 if (BREADY==1'b1) begin
                     BVALID  <= 1'b0;
                     if (AWVALID==1'b1) begin
                         AWREADY <= 1'b1;
                         stateW  <= STW_RUN;
                     end else begin
                         stateW  <= STW_IDLE;
                     end
                 end
                 end // STW_RSP
             endcase
         end
     end
     //-----------------------------------------------------------
     // read case
     //-----------------------------------------------------------
     assign RRESP = 2'b11; // DECERR; decode error
     assign RDATA = ~'h0;
     reg [WIDTH_SID-1:0] arid_reg;
     `ifdef AMBA_AXI4
     reg [8:0] countR, arlen_reg;
     `else
     reg [4:0] countR, arlen_reg;
     `endif
     //-----------------------------------------------------------
     reg [1:0] stateR;
     localparam STR_IDLE   = 'h0,
                STR_RUN    = 'h1,
                STR_WAIT   = 'h2,
                STR_END    = 'h3;
     always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             ARREADY   <= 1'b0;
             RID       <=  'h0;
             RLAST     <= 1'b0;
             RVALID    <= 1'b0;
             arid_reg  <=  'h0;
             arlen_reg <=  'h0;
             countR    <=  'h0;
             stateR    <= STR_IDLE;
         end else begin
             case (stateR)
             STR_IDLE: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end
                 end // STR_IDLE
             STR_RUN: begin
                 if ((ARVALID==1'b1)&&(ARREADY==1'b1)) begin
                      ARREADY   <= 1'b0;
                      arlen_reg <= ARLEN+1;
                      arid_reg  <= ARID;
                      RID       <= ARID;
                      RVALID    <= 1'b1;
                      RLAST     <= (ARLEN=='h0) ? 1'b1 : 1'b0;
                      countR    <=  'h2;
                      stateR    <= STR_WAIT;
                 end
                 end // STR_IDLE
             STR_WAIT: begin
                 if (RREADY==1'b1) begin
                     if (countR>=(arlen_reg+1)) begin
                         RVALID  <= 1'b0;
                         RLAST   <= 1'b0;
                         countR  <= 'h0;
                         stateR  <= STR_END;
                     end else begin
                         if (countR==arlen_reg) RLAST  <= 1'b1;
                         countR <= countR + 1;
                     end
                 end
                 end // STR_WAIT
             STR_END: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end else begin
                      stateR    <= STR_IDLE;
                 end
                 end // STR_END
             endcase
         end
     end
     //-----------------------------------------------------------
   // synopsys translate_off
   `endprotect
   // synopsys translate_on
endmodule

//----------------------------------------------------------------
// Revision History
//
// 2010.12.30: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
