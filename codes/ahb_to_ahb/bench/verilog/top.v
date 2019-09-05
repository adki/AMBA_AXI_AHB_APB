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
   wire        T_HBUSREQ;
   wire        T_HGRANT = T_HBUSREQ; // no arbiter
   wire [31:0] T_HADDR     ;
   wire [3:0]  T_HPROT     ;
   wire        T_HLOCK     ;
   wire [1:0]  T_HTRANS    ;
   wire        T_HWRITE    ;
   wire [2:0]  T_HSIZE     ;
   wire [2:0]  T_HBURST    ;
   wire [31:0] T_HWDATA    ;
   wire        T_HREADY    ;
   wire [31:0] T_HRDATA    ;
   wire [1:0]  T_HRESP     ;
   wire        T_HSEL      = T_HTRANS[1];
   wire        M_HBUSREQ;
   wire        M_HGRANT = M_HBUSREQ; // no arbiter
   wire [31:0] M_HADDR     ;
   wire [3:0]  M_HPROT     ;
   wire        M_HLOCK     ;
   wire [1:0]  M_HTRANS    ;
   wire        M_HWRITE    ;
   wire [2:0]  M_HSIZE     ;
   wire [2:0]  M_HBURST    ;
   wire [31:0] M_HWDATA    ;
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
   bfm_ahb #(.START_ADDR(0),.DEPTH_IN_BYTES(32'h100))
   u_bfm_ahb (
         .HRESETn (HRESETn  )
       , .HCLK    (HCLK     )
       , .HBUSREQ (T_HBUSREQ)
       , .HGRANT  (T_HGRANT )
       , .HADDR   (T_HADDR  )
       , .HPROT   (T_HPROT  )
       , .HLOCK   (T_HLOCK  )
       , .HTRANS  (T_HTRANS )
       , .HWRITE  (T_HWRITE )
       , .HSIZE   (T_HSIZE  )
       , .HBURST  (T_HBURST )
       , .HWDATA  (T_HWDATA )
       , .HRDATA  (T_HRDATA )
       , .HRESP   (T_HRESP  )
       , .HREADY  (T_HREADY )
       , .IRQ     (1'b0   )
   );
   //----------------------------------------------------
   ahb2ahb u_ahb2ahb (
       .HRESETn    (HRESETn   )
     , .HCLK       (HCLK      )
     , .sHSEL      (T_HSEL    )
     , .sHADDR     (T_HADDR   )
     , .sHTRANS    (T_HTRANS  )
     , .sHWRITE    (T_HWRITE  )
     , .sHSIZE     (T_HSIZE   )
     , .sHBURST    (T_HBURST  )
     , .sHWDATA    (T_HWDATA  )
     , .sHRDATA    (T_HRDATA  )
     , .sHRESP     (T_HRESP   )
     , .sHREADYin  (T_HREADY  )
     , .sHREADYout (T_HREADY  )
     , .mHBUSREQ   (M_HBUSREQ )
     , .mHGRANT    (M_HGRANT  )
     , .mHADDR     (M_HADDR   )
     , .mHTRANS    (M_HTRANS  )
     , .mHWRITE    (M_HWRITE  )
     , .mHSIZE     (M_HSIZE   )
     , .mHBURST    (M_HBURST  )
     , .mHWDATA    (M_HWDATA  )
     , .mHRDATA    (M_HRDATA  )
     , .mHRESP     (M_HRESP   )
     , .mHREADY    (M_HREADY  )
   );
   //----------------------------------------------------
   ahb_lite_s3 #(.P_HSEL0_START(16'h0000),.P_HSEL0_SIZE(16'h0100)
                ,.P_HSEL1_START(16'h1000),.P_HSEL1_SIZE(16'h0100)
                ,.P_HSEL2_START(16'h2000),.P_HSEL2_SIZE(16'h0100))
   u_ahb_lite (
        .HRESETn (HRESETn )
      , .HCLK    (HCLK    )
      , .M_HADDR (M_HADDR )
      , .M_HTRANS(M_HTRANS)
      , .M_HWRITE(M_HWRITE)
      , .M_HSIZE (M_HSIZE )
      , .M_HBURST(M_HBURST)
      , .M_HPROT (M_HPROT )
      , .M_HWDATA(M_HWDATA)
      , .M_HRDATA(M_HRDATA)
      , .M_HRESP (M_HRESP )
      , .M_HREADY(M_HREADY)
      , .HWRITE  (S_HWRITE  )
      , .HADDR   (S_HADDR   )
      , .HTRANS  (S_HTRANS  )
      , .HSIZE   (S_HSIZE   )
      , .HBURST  (S_HBURST  )
      , .HPROT   (S_HPROT   )
      , .HWDATA  (S_HWDATA  )
      , .HREADY  (S_HREADY  )
      , .HSEL0   (S_HSEL      [0])
      , .HRESP0  (S_HRESP     [0])
      , .HRDATA0 (S_HRDATA    [0])
      , .HREADY0 (S_HREADYout [0])
      , .HSEL1   (S_HSEL      [1])
      , .HRESP1  (S_HRESP     [1])
      , .HRDATA1 (S_HRDATA    [1])
      , .HREADY1 (S_HREADYout [1])
      , .HSEL2   (S_HSEL      [2])
      , .HRESP2  (S_HRESP     [2])
      , .HRDATA2 (S_HRDATA    [2])
      , .HREADY2 (S_HREADYout [2])
      , .REMAP   (1'b0)
   );
   //----------------------------------------------------
   generate
   genvar GM;
   for (GM=0; GM<3; GM=GM+1) begin :BM_BLK
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
          , .HSEL      (S_HSEL     [GM])
          , .HRDATA    (S_HRDATA   [GM])
          , .HRESP     (S_HRESP    [GM])
          , .HREADYout (S_HREADYout[GM])
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
