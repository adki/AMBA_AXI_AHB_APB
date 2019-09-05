`ifndef AXI_BRIDGE_CORE_V
`define AXI_BRIDGE_CORE_V
//--------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//--------------------------------------------------------
// axi_bridge_async.v
//--------------------------------------------------------
// VERSION = 2012.01.02.
//--------------------------------------------------------
// NOTE
//--------------------------------------------------------
`timescale 1ns/1ns

module axi_bridge_core
     #(parameter AXI_WIDTH_CID=4         // Channel ID
               , AXI_WIDTH_ID =4         // ID width in bits
               , AXI_WIDTH_AD =32        // address width
               , AXI_WIDTH_DA =32        // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               , ASYNC        =1'b0 // Async (S_ACLK/M_ACLK) when 1'b1
               )
(
       input  wire                     ARESETn
     //-----------------------------------------------------------
     , input  wire                     S_ACLK
     , input  wire [AXI_WIDTH_SID-1:0] S_AWID
     , input  wire [AXI_WIDTH_AD-1:0]  S_AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S_AWLEN
     , input  wire                     S_AWLOCK
     `else
     , input  wire [ 3:0]              S_AWLEN
     , input  wire [ 1:0]              S_AWLOCK
     `endif
     , input  wire [ 2:0]              S_AWSIZE
     , input  wire [ 1:0]              S_AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S_AWPROT
     `endif
     , input  wire                     S_AWVALID
     , output wire                     S_AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S_AWQOS
     , input  wire [ 3:0]              S_AWREGION
     `endif
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] S_WID
     , input  wire [AXI_WIDTH_DA-1:0]  S_WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  S_WSTRB
     , input  wire                     S_WLAST
     , input  wire                     S_WVALID
     , output wire                     S_WREADY
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] S_BID
     , output wire [ 1:0]              S_BRESP
     , output wire                     S_BVALID
     , input  wire                     S_BREADY
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] S_ARID
     , input  wire [AXI_WIDTH_AD-1:0]  S_ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S_ARLEN
     , input  wire                     S_ARLOCK
     `else
     , input  wire [ 3:0]              S_ARLEN
     , input  wire [ 1:0]              S_ARLOCK
     `endif
     , input  wire [ 2:0]              S_ARSIZE
     , input  wire [ 1:0]              S_ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S_ARPROT
     `endif
     , input  wire                     S_ARVALID
     , output wire                     S_ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S_ARQOS
     , input  wire [ 3:0]              S_ARREGION
     `endif
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] S_RID
     , output wire [AXI_WIDTH_DA-1:0]  S_RDATA
     , output wire [ 1:0]              S_RRESP
     , output wire                     S_RLAST
     , output wire                     S_RVALID
     , input  wire                     S_RREADY
     //-----------------------------------------------------------
     , input  wire                     M_ACLK
     , output wire [AXI_WIDTH_SID-1:0] M_AWID
     , output wire [AXI_WIDTH_AD-1:0]  M_AWADDR
     `ifdef AMBA_AXI4
     , output wire [ 7:0]              M_AWLEN
     , output wire                     M_AWLOCK
     `else
     , output wire [ 3:0]              M_AWLEN
     , output wire [ 1:0]              M_AWLOCK
     `endif
     , output wire [ 2:0]              M_AWSIZE
     , output wire [ 1:0]              M_AWBURST
     `ifdef AMBA_AXI_CACHE
     , output wire [ 3:0]              M_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output wire [ 2:0]              M_AWPROT
     `endif
     , output wire                     M_AWVALID
     , input  wire                     M_AWREADY
     `ifdef AMBA_AXI4
     , output wire [ 3:0]              M_AWQOS
     , output wire [ 3:0]              M_AWREGION
     `endif
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] M_WID
     , output wire [AXI_WIDTH_DA-1:0]  M_WDATA
     , output wire [AXI_WIDTH_DS-1:0]  M_WSTRB
     , output wire                     M_WLAST
     , output wire                     M_WVALID
     , input  wire                     M_WREADY
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] M_BID
     , input  wire [ 1:0]              M_BRESP
     , input  wire                     M_BVALID
     , output wire                     M_BREADY
     //-----------------------------------------------------------
     , output wire [AXI_WIDTH_SID-1:0] M_ARID
     , output wire [AXI_WIDTH_AD-1:0]  M_ARADDR
     `ifdef AMBA_AXI4
     , output wire [ 7:0]              M_ARLEN
     , output wire                     M_ARLOCK
     `else
     , output wire [ 3:0]              M_ARLEN
     , output wire [ 1:0]              M_ARLOCK
     `endif
     , output wire [ 2:0]              M_ARSIZE
     , output wire [ 1:0]              M_ARBURST
     `ifdef AMBA_AXI_CACHE
     , output wire [ 3:0]              M_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output wire [ 2:0]              M_ARPROT
     `endif
     , output wire                     M_ARVALID
     , input  wire                     M_ARREADY
     `ifdef AMBA_AXI4
     , output wire [ 3:0]              M_ARQOS
     , output wire [ 3:0]              M_ARREGION
     `endif
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_SID-1:0] M_RID
     , input  wire [AXI_WIDTH_DA-1:0]  M_RDATA
     , input  wire [ 1:0]              M_RRESP
     , input  wire                     M_RLAST
     , input  wire                     M_RVALID
     , output wire                     M_RREADY
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     `ifdef AMBA_AXI4
     localparam FAW = 9;
     `else
     localparam FAW = 5;
     `endif
     //-----------------------------------------------------------
     localparam WIDTH_AW = 0
                         + AXI_WIDTH_SID    // S_AWID
                         + AXI_WIDTH_AD     // S_AWADDR
                         `ifdef AMBA_AXI4
                         +  8               // S_AWLEN
                         +  1               // S_AWLOCK
                         `else
                         +  4               // S_AWLEN
                         +  2               // S_AWLOCK
                         `endif
                         +  3               // S_AWSIZE
                         +  2               // S_AWBURST
                         `ifdef AMBA_AXI_CACHE
                         +  4               // S_AWCACHE
                         `endif
                         `ifdef AMBA_AXI_PROT
                         +  3               // S_AWPROT
                         `endif
                         `ifdef AMBA_AXI4
                         +  4               // S_AWQOS
                         +  4               // S_AWREGION
                         `endif
                         ;
     //-----------------------------------------------------------
     wire [WIDTH_AW-1:0] S_AW = {  S_AWID
                                ,  S_AWADDR
                                `ifdef AMBA_AXI4
                                ,  S_AWLEN
                                ,  S_AWLOCK
                                `else
                                ,  S_AWLEN
                                ,  S_AWLOCK
                                `endif
                                ,  S_AWSIZE
                                ,  S_AWBURST
                                `ifdef AMBA_AXI_CACHE
                                ,  S_AWCACHE
                                `endif
                                `ifdef AMBA_AXI_PROT
                                ,  S_AWPROT
                                `endif
                                `ifdef AMBA_AXI4
                                ,  S_AWQOS
                                ,  S_AWREGION
                                `endif
                              };
     wire [WIDTH_AW-1:0] M_AW ;
     assign                   {    M_AWID
                                ,  M_AWADDR
                                `ifdef AMBA_AXI4
                                ,  M_AWLEN
                                ,  M_AWLOCK
                                `else
                                ,  M_AWLEN
                                ,  M_AWLOCK
                                `endif
                                ,  M_AWSIZE
                                ,  M_AWBURST
                                `ifdef AMBA_AXI_CACHE
                                ,  M_AWCACHE
                                `endif
                                `ifdef AMBA_AXI_PROT
                                ,  M_AWPROT
                                `endif
                                `ifdef AMBA_AXI4
                                ,  M_AWQOS
                                ,  M_AWREGION
                                `endif
                              } = M_AW;
     //-----------------------------------------------------------
     wire S_AW_full;
     // synthesis translate_off
     always @ (posedge S_ACLK) begin
          if (S_AWREADY&S_AWVALID&S_AW_full)
          $display($time,,"%m ERROR AW BUFF Full");
     end
     // synthesis translate_on
     //-----------------------------------------------------------
     generate
     if (ASYNC==1'b1) begin : AXI_BRIDGE_AW
     axi_bridge_async_fifo #(.FDW(WIDTH_AW),
                             .FAW(FAW     ))
     Ufifo_aw (
          .rst      (~ARESETn )
        , .clr      (1'b0     )
        , .wr_clk   (S_ACLK   )
        , .wr_rdy   (S_AWREADY)
        , .wr_vld   (S_AWVALID)
        , .wr_din   (S_AW     )
        , .rd_clk   (M_ACLK   )
        , .rd_rdy   (M_AWREADY)
        , .rd_vld   (M_AWVALID)
        , .rd_dout  (M_AW     )
        , .full     (S_AW_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end else begin
     axi_bridge_sync_fifo #(.FDW(WIDTH_AW),
                            .FAW(FAW     ))
     Ufifo_aw (
          .rst      (~ARESETn )
        , .clr      (1'b0     )
        , .clk      (S_ACLK   )
        , .wr_rdy   (S_AWREADY)
        , .wr_vld   (S_AWVALID)
        , .wr_din   (S_AW     )
        , .rd_rdy   (M_AWREADY)
        , .rd_vld   (M_AWVALID)
        , .rd_dout  (M_AW     )
        , .full     (S_AW_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end
     endgenerate
     //-----------------------------------------------------------
     localparam WIDTH_W  = 0
                         + AXI_WIDTH_SID    // S_WID
                         + AXI_WIDTH_DA     // S_WDATA
                         + AXI_WIDTH_DS     // S_WSTRB
                         +  1               // S_WLAST
                         ;
     //-----------------------------------------------------------
     wire [WIDTH_W-1:0] S_W = { S_WID
                              , S_WDATA
                              , S_WSTRB
                              , S_WLAST
                              };
     //-----------------------------------------------------------
     wire [WIDTH_W-1:0] M_W ;
     assign { M_WID
            , M_WDATA
            , M_WSTRB
            , M_WLAST
            } = M_W;
     //-----------------------------------------------------------
     wire S_W_full;
     // synthesis translate_off
     always @ (posedge S_ACLK) begin
          if (S_WREADY&S_WVALID&S_AW_full)
          $display($time,,"%m ERROR W BUFF Full");
     end
     // synthesis translate_on
     //-----------------------------------------------------------
     generate
     if (ASYNC==1'b1) begin : AXI_BRIDGE_W
     axi_bridge_async_fifo #(.FDW(WIDTH_W),
                             .FAW(FAW    ))
     Ufifo_w (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .wr_clk   (S_ACLK  )
        , .wr_rdy   (S_WREADY)
        , .wr_vld   (S_WVALID)
        , .wr_din   (S_W     )
        , .rd_clk   (M_ACLK  )
        , .rd_rdy   (M_WREADY)
        , .rd_vld   (M_WVALID)
        , .rd_dout  (M_W     )
        , .full     (S_W_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end else begin
     axi_bridge_sync_fifo #(.FDW(WIDTH_W),
                            .FAW(FAW    ))
     Ufifo_w (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .clk      (S_ACLK  )
        , .wr_rdy   (S_WREADY)
        , .wr_vld   (S_WVALID)
        , .wr_din   (S_W     )
        , .rd_rdy   (M_WREADY)
        , .rd_vld   (M_WVALID)
        , .rd_dout  (M_W     )
        , .full     (S_W_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end
     endgenerate
     //-----------------------------------------------------------
     localparam WIDTH_B  = 0
                         + AXI_WIDTH_SID    // S_BID
                         +  2               // S_BRESP
                         ;
     //-----------------------------------------------------------
     wire [WIDTH_B-1:0] S_B;
     assign { S_BID
            , S_BRESP
            } = S_B;
     //-----------------------------------------------------------
     wire [WIDTH_B-1:0] M_B = { M_BID
                              , M_BRESP
                              };
     //-----------------------------------------------------------
     wire M_B_full;
     // synthesis translate_off
     always @ (posedge M_ACLK) begin
          if (M_BREADY&M_BVALID&M_B_full)
          $display($time,,"%m ERROR S BUFF Full");
     end
     // synthesis translate_on
     //-----------------------------------------------------------
     generate
     if (ASYNC==1'b1) begin : AXI_BRIDGE_B
     axi_bridge_async_fifo #(.FDW(WIDTH_B),
                             .FAW(FAW    ))
     Ufifo_b (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .wr_clk   (M_ACLK  )
        , .wr_rdy   (M_BREADY)
        , .wr_vld   (M_BVALID)
        , .wr_din   (M_B     )
        , .rd_clk   (S_ACLK  )
        , .rd_rdy   (S_BREADY)
        , .rd_vld   (S_BVALID)
        , .rd_dout  (S_B     )
        , .full     (M_B_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end else begin
     axi_bridge_sync_fifo #(.FDW(WIDTH_B),
                             .FAW(FAW    ))
     Ufifo_b (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .clk      (M_ACLK  )
        , .wr_rdy   (M_BREADY)
        , .wr_vld   (M_BVALID)
        , .wr_din   (M_B     )
        , .rd_rdy   (S_BREADY)
        , .rd_vld   (S_BVALID)
        , .rd_dout  (S_B     )
        , .full     (M_B_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end
     endgenerate
     //-----------------------------------------------------------
     localparam WIDTH_AR = 0
                        + AXI_WIDTH_SID    // S_ARID
                        + AXI_WIDTH_AD     // S_ARADDR
                        `ifdef AMBA_AXI4
                        +  8               // S_ARLEN
                        +  1               // S_ARLOCK
                        `else
                        +  4               // S_ARLEN
                        +  2               // S_ARLOCK
                        `endif
                        +  3               // S_ARSIZE
                        +  2               // S_ARBURST
                        `ifdef AMBA_AXI_CACHE
                        +  4               // S_ARCACHE
                        `endif
                        `ifdef AMBA_AXI_PROT
                        +  3               // S_ARPROT
                        `endif
                        `ifdef AMBA_AXI4
                        +  4               // S_ARQOS
                        +  4               // S_ARREGION
                        `endif
                        ;
     //-----------------------------------------------------------
     wire [WIDTH_AR-1:0] S_AR = {  S_ARID
                                ,  S_ARADDR
                                `ifdef AMBA_AXI4
                                ,  S_ARLEN
                                ,  S_ARLOCK
                                `else
                                ,  S_ARLEN
                                ,  S_ARLOCK
                                `endif
                                ,  S_ARSIZE
                                ,  S_ARBURST
                                `ifdef AMBA_AXI_CACHE
                                ,  S_ARCACHE
                                `endif
                                `ifdef AMBA_AXI_PROT
                                ,  S_ARPROT
                                `endif
                                `ifdef AMBA_AXI4
                                ,  S_ARQOS
                                ,  S_ARREGION
                                `endif
                                };
     //-----------------------------------------------------------
     wire [WIDTH_AR-1:0] M_AR ;
     assign                     {  M_ARID
                                ,  M_ARADDR
                                `ifdef AMBA_AXI4
                                ,  M_ARLEN
                                ,  M_ARLOCK
                                `else
                                ,  M_ARLEN
                                ,  M_ARLOCK
                                `endif
                                ,  M_ARSIZE
                                ,  M_ARBURST
                                `ifdef AMBA_AXI_CACHE
                                ,  M_ARCACHE
                                `endif
                                `ifdef AMBA_AXI_PROT
                                ,  M_ARPROT
                                `endif
                                `ifdef AMBA_AXI4
                                ,  M_ARQOS
                                ,  M_ARREGION
                                `endif
                                } = M_AR;
     //-----------------------------------------------------------
     wire S_AR_full;
     // synthesis translate_off
     always @ (posedge S_ACLK) begin
          if (S_ARREADY&S_ARVALID&S_AR_full)
          $display($time,,"%m ERROR AR BUFF Full");
     end
     // synthesis translate_on
     //-----------------------------------------------------------
     generate
     if (ASYNC==1'b1) begin : AXI_BRIDGE_AR
     axi_bridge_async_fifo #(.FDW(WIDTH_AR),
                             .FAW(FAW     ))
     Ufifo_ar (
          .rst      (~ARESETn )
        , .clr      (1'b0     )
        , .wr_clk   (S_ACLK   )
        , .wr_rdy   (S_ARREADY)
        , .wr_vld   (S_ARVALID)
        , .wr_din   (S_AR     )
        , .rd_clk   (M_ACLK   )
        , .rd_rdy   (M_ARREADY)
        , .rd_vld   (M_ARVALID)
        , .rd_dout  (M_AR     )
        , .full     (S_AR_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end else begin
     axi_bridge_sync_fifo #(.FDW(WIDTH_AR),
                             .FAW(FAW     ))
     Ufifo_ar (
          .rst      (~ARESETn )
        , .clr      (1'b0     )
        , .clk      (S_ACLK   )
        , .wr_rdy   (S_ARREADY)
        , .wr_vld   (S_ARVALID)
        , .wr_din   (S_AR     )
        , .rd_rdy   (M_ARREADY)
        , .rd_vld   (M_ARVALID)
        , .rd_dout  (M_AR     )
        , .full     (S_AR_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end
     endgenerate
     //-----------------------------------------------------------
     localparam WIDTH_R  = 0
                         + AXI_WIDTH_SID   // S_RID
                         + AXI_WIDTH_DA    // S_RDATA
                         +  2              // S_RRESP
                         +  1              // S_RLAST
                         ;
     //-----------------------------------------------------------
     wire [WIDTH_R-1:0]  S_R;
     assign              { S_RID
                         , S_RDATA
                         , S_RRESP
                         , S_RLAST
                         } = S_R;
     //-----------------------------------------------------------
     wire [WIDTH_R-1:0]  M_R = { M_RID
                               , M_RDATA
                               , M_RRESP
                               , M_RLAST
                               };
     //-----------------------------------------------------------
     wire M_R_full;
     // synthesis translate_off
     always @ (posedge M_ACLK) begin
          if (M_RREADY&M_RVALID&M_B_full)
          $display($time,,"%m ERROR R BUFF Full");
     end
     // synthesis translate_on
     //-----------------------------------------------------------
     generate
     if (ASYNC==1'b1) begin : AXI_BRIDGE_R
     axi_bridge_async_fifo #(.FDW(WIDTH_R),
                             .FAW(FAW    ))
     Ufifo_r (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .wr_clk   (M_ACLK  )
        , .wr_rdy   (M_RREADY)
        , .wr_vld   (M_RVALID)
        , .wr_din   (M_R     )
        , .rd_clk   (S_ACLK  )
        , .rd_rdy   (S_RREADY)
        , .rd_vld   (S_RVALID)
        , .rd_dout  (S_R     )
        , .full     (M_R_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end else begin
     axi_bridge_sync_fifo #(.FDW(WIDTH_R),
                            .FAW(FAW    ))
     Ufifo_r (
          .rst      (~ARESETn)
        , .clr      (1'b0    )
        , .clk      (M_ACLK  )
        , .wr_rdy   (M_RREADY)
        , .wr_vld   (M_RVALID)
        , .wr_din   (M_R     )
        , .rd_rdy   (S_RREADY)
        , .rd_vld   (S_RVALID)
        , .rd_dout  (S_R     )
        , .full     (M_R_full)
        , .empty    ()
        , .fullN    ()
        , .emptyN   ()
        , .wr_cnt   ()
        , .rd_cnt   ()
     );
     end
     endgenerate
     //-----------------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2012.01.02: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
`endif
