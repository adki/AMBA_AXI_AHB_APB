//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef CLK_FREQ
`define CLK_FREQ       50000000
`endif
`ifndef MEM_DELAY
`define MEM_DELAY 0
`endif
`ifndef SIZE_IN_BYTES
`define SIZE_IN_BYTES 1024
`endif

module top ;
   //------------------------------------------------
   localparam SIZE_IN_BYTES=`SIZE_IN_BYTES // memory size
            , DELAY        =`MEM_DELAY; // access delay if any for AMBA3/4
   //------------------------------------------------
   reg         HRESETn= 1'b0;
   reg         HCLK   = 1'b0;
   wire        M_HBUSREQ   [0:1];
   wire        M_HGRANT    [0:1];
   wire [31:0] M_HADDR     [0:1];
   wire [3:0]  M_HPROT     [0:1];
   wire        M_HLOCK     [0:1];
   wire [1:0]  M_HTRANS    [0:1];
   wire        M_HWRITE    [0:1];
   wire [2:0]  M_HSIZE     [0:1];
   wire [2:0]  M_HBURST    [0:1];
   wire [31:0] M_HWDATA    [0:1];
   wire        M_HREADY    ;
   wire [31:0] M_HRDATA    ;
   wire [1:0]  M_HRESP     ;
   wire [31:0] S_HADDR     ;
   wire [3:0]  S_HPROT     ;
   wire [1:0]  S_HTRANS    ;
   wire        S_HWRITE    ;
   wire [2:0]  S_HSIZE     ;
   wire [2:0]  S_HBURST    ;
   wire [31:0] S_HWDATA    ;
   wire        S_HREADY    ;
   wire [31:0] S_HRDATA    [0:2];
   wire [1:0]  S_HRESP     [0:2];
   wire        S_HREADYout [0:2];
   wire        S_HSEL      [0:2];
   //------------------------------------------------
   generate
   genvar GM;
   for (GM=0; GM<2; GM=GM+1) begin :GM_BLK
      bfm_ahb #(.START_ADDR((16'h1000*GM)<<16),.DEPTH_IN_BYTES(32'h100))
      u_bfm_ahb (
            .HRESETn (HRESETn  )
          , .HCLK    (HCLK     )
          , .HBUSREQ (M_HBUSREQ[GM])
          , .HGRANT  (M_HGRANT [GM])
          , .HADDR   (M_HADDR  [GM])
          , .HPROT   (M_HPROT  [GM])
          , .HLOCK   (M_HLOCK  [GM])
          , .HTRANS  (M_HTRANS [GM])
          , .HWRITE  (M_HWRITE [GM])
          , .HSIZE   (M_HSIZE  [GM])
          , .HBURST  (M_HBURST [GM])
          , .HWDATA  (M_HWDATA [GM])
          , .HRDATA  (M_HRDATA     )
          , .HRESP   (M_HRESP      )
          , .HREADY  (M_HREADY     )
          , .IRQ     (1'b0         )
      );
   end
   endgenerate
   //----------------------------------------------------
   amba_ahb_m2s3 #(.P_HSEL0_START(16'h0000),.P_HSEL0_SIZE(16'h0100)
                  ,.P_HSEL1_START(16'h1000),.P_HSEL1_SIZE(16'h0100)
                  ,.P_HSEL2_START(16'h2000),.P_HSEL2_SIZE(16'h0100))
   u_amba_ahb (
        .HRESETn (HRESETn )
      , .HCLK    (HCLK    )
      , .M_HBUSREQ_0 (M_HBUSREQ[0])
      , .M_HGRANT_0  (M_HGRANT [0])
      , .M_HADDR_0   (M_HADDR  [0])
      , .M_HTRANS_0  (M_HTRANS [0])
      , .M_HWRITE_0  (M_HWRITE [0])
      , .M_HSIZE_0   (M_HSIZE  [0])
      , .M_HBURST_0  (M_HBURST [0])
      , .M_HPROT_0   (M_HPROT  [0])
      , .M_HWDATA_0  (M_HWDATA [0])
      , .M_HBUSREQ_1 (M_HBUSREQ[1])
      , .M_HGRANT_1  (M_HGRANT [1])
      , .M_HADDR_1   (M_HADDR  [1])
      , .M_HTRANS_1  (M_HTRANS [1])
      , .M_HWRITE_1  (M_HWRITE [1])
      , .M_HSIZE_1   (M_HSIZE  [1])
      , .M_HBURST_1  (M_HBURST [1])
      , .M_HPROT_1   (M_HPROT  [1])
      , .M_HWDATA_1  (M_HWDATA [1])
      , .M_HRDATA    (M_HRDATA    )
      , .M_HRESP     (M_HRESP     )
      , .M_HREADY    (M_HREADY    )
      , .HWRITE  (S_HWRITE  )
      , .HADDR   (S_HADDR   )
      , .HTRANS  (S_HTRANS  )
      , .HSIZE   (S_HSIZE   )
      , .HBURST  (S_HBURST  )
      , .HPROT   (S_HPROT   )
      , .HWDATA  (S_HWDATA  )
      , .HREADY  (S_HREADY  )
      , .HSEL_0  (S_HSEL      [0])
      , .HRESP_0 (S_HRESP     [0])
      , .HRDATA_0(S_HRDATA    [0])
      , .HREADY_0(S_HREADYout [0])
      , .HSEL_1  (S_HSEL      [1])
      , .HRESP_1 (S_HRESP     [1])
      , .HRDATA_1(S_HRDATA    [1])
      , .HREADY_1(S_HREADYout [1])
      , .HSEL_2  (S_HSEL      [2])
      , .HRESP_2 (S_HRESP     [2])
      , .HRDATA_2(S_HRDATA    [2])
      , .HREADY_2(S_HREADYout [2])
      , .REMAP   (1'b0)
   );
   //----------------------------------------------------
   generate
   genvar GS;
   for (GS=0; GS<3; GS=GS+1) begin :GS_BLK
      mem_ahb #(.SIZE_IN_BYTES(SIZE_IN_BYTES),.DELAY(DELAY))
      u_mem_ahb (
            .HRESETn   (HRESETn)
          , .HCLK      (HCLK   )
          , .HADDR     (S_HADDR  )
          , .HTRANS    (S_HTRANS )
          , .HWRITE    (S_HWRITE )
          , .HSIZE     (S_HSIZE  )
          , .HBURST    (S_HBURST )
          , .HWDATA    (S_HWDATA )
          , .HREADYin  (S_HREADY )
          , .HSEL      (S_HSEL     [GS])
          , .HRDATA    (S_HRDATA   [GS])
          , .HRESP     (S_HRESP    [GS])
          , .HREADYout (S_HREADYout[GS])
      );
   end
   endgenerate
   //-----------------------------------------------------
   localparam CLK_FREQ=`CLK_FREQ;
   localparam CLK_PERIOD_HALF=1000000000/(CLK_FREQ*2);
   //-----------------------------------------------------
   always #CLK_PERIOD_HALF HCLK <= ~HCLK;
   //-----------------------------------------------------
   real stamp_x, stamp_y, delta;
   initial begin
       HRESETn <= 1'b0;
       repeat (5) @ (posedge HCLK);
       `ifdef RIGOR
        @ (posedge HCLK);
        @ (posedge HCLK); stamp_x = $time;
        @ (posedge HCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge HCLK); $display("%m HCLK %f nsec %f Mhz", delta, 1000.0/delta);
       `endif
       repeat (5) @ (posedge HCLK);
       HRESETn <= 1'b1;
   end
   //------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0);
   end
   `endif
endmodule
//--------------------------------------------------------
// Revision history:
//
// 2013.01.31.: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
