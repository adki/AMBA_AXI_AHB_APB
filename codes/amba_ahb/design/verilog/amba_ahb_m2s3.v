//--------------------------------------------------------
// Copyright (c) 2009-2011 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// VERSION: 2011.03.20.
//--------------------------------------------------------
`include "ahb_arbiter_m2.v"
`include "ahb_m2s_m2.v"
`timescale 1ns/1ns

module amba_ahb_m2s3
#(parameter P_HSEL0_START=16'h0000, P_HSEL0_SIZE=16'h0010,
            P_HSEL1_START=16'h1000, P_HSEL1_SIZE=16'h0010,
            P_HSEL2_START=16'h2000, P_HSEL2_SIZE=16'h0010)
(
  input  wire        HRESETn    ,
  input  wire        HCLK       ,

  input  wire        M_HBUSREQ_0,
  output wire        M_HGRANT_0 ,
  input  wire [31:0] M_HADDR_0  ,
  input  wire [ 1:0] M_HTRANS_0 ,
  input  wire [ 2:0] M_HSIZE_0  ,
  input  wire [ 2:0] M_HBURST_0 ,
  input  wire [ 3:0] M_HPROT_0  ,
  input  wire        M_HWRITE_0 ,
  input  wire [31:0] M_HWDATA_0 ,
  input  wire        M_HBUSREQ_1,
  output wire        M_HGRANT_1 ,
  input  wire [31:0] M_HADDR_1  ,
  input  wire [ 1:0] M_HTRANS_1 ,
  input  wire [ 2:0] M_HSIZE_1  ,
  input  wire [ 2:0] M_HBURST_1 ,
  input  wire [ 3:0] M_HPROT_1  ,
  input  wire        M_HWRITE_1 ,
  input  wire [31:0] M_HWDATA_1 ,
  output wire [31:0] M_HRDATA   ,
  output wire        M_HREADY   ,
  output wire [ 1:0] M_HRESP    ,

  output wire [31:0] HADDR      ,
  output wire [31:0] HWDATA     ,
  output wire [ 1:0] HTRANS     ,
  output wire [ 2:0] HSIZE      ,
  output wire [ 2:0] HBURST     ,
  output wire        HWRITE     ,
  output wire [3:0]  HPROT      ,
  output wire        HREADY     ,
  output wire        HSEL_0     ,
  input  wire [31:0] HRDATA_0   ,
  input  wire [ 1:0] HRESP_0    ,
  input  wire        HREADY_0   ,
  output wire        HSEL_1     ,
  input  wire [31:0] HRDATA_1   ,
  input  wire [ 1:0] HRESP_1    ,
  input  wire        HREADY_1   ,
  output wire        HSEL_2     ,
  input  wire [31:0] HRDATA_2   ,
  input  wire [ 1:0] HRESP_2    ,
  input  wire        HREADY_2   ,

  input  wire        REMAP      
);
  //--------------------------------------------------
  wire [3:0] M_HMASTER;
  ahb_arbiter_m2 Uahb_arbiter (
       .HRESETn   (HRESETn    ),
       .HCLK      (HCLK       ),
       .HREADY    (M_HREADY   ),
       .HBUSREQ_0 (M_HBUSREQ_0),
       .HBUSREQ_1 (M_HBUSREQ_1),
       .HGRANT_0  (M_HGRANT_0 ),
       .HGRANT_1  (M_HGRANT_1 ),
       .HMASTER   (M_HMASTER  )
  );
  //--------------------------------------------------
  wire  [31:0] M_HADDR;
  wire  [1:0]  M_HTRANS;
  wire  [2:0]  M_HSIZE;
  wire  [2:0]  M_HBURST;
  wire  [3:0]  M_HPROT;
  wire         M_HWRITE;
  wire  [31:0] M_HWDATA;
  ahb_m2s_m2 Uahb_m2s (
       .HRESETn  (HRESETn  ),
       .HCLK     (HCLK     ),
       .HREADY   (M_HREADY   ),
       .HMASTER  (M_HMASTER  ),
       .HADDR    (M_HADDR    ),
       .HPROT    (M_HPROT    ),
       .HTRANS   (M_HTRANS   ),
       .HWRITE   (M_HWRITE   ),
       .HSIZE    (M_HSIZE    ),
       .HBURST   (M_HBURST   ),
       .HWDATA   (M_HWDATA   ),
       .HADDR_0  (M_HADDR_0  ),
       .HPROT_0  (M_HPROT_0  ),
       .HTRANS_0 (M_HTRANS_0 ),
       .HWRITE_0 (M_HWRITE_0 ),
       .HSIZE_0  (M_HSIZE_0  ),
       .HBURST_0 (M_HBURST_0 ),
       .HWDATA_0 (M_HWDATA_0 ),
       .HADDR_1  (M_HADDR_1  ),
       .HPROT_1  (M_HPROT_1  ),
       .HTRANS_1 (M_HTRANS_1 ),
       .HWRITE_1 (M_HWRITE_1 ),
       .HSIZE_1  (M_HSIZE_1  ),
       .HBURST_1 (M_HBURST_1 ),
       .HWDATA_1 (M_HWDATA_1 )
  );
  //--------------------------------------------------
  ahb_lite_s3 #(.P_HSEL0_START(P_HSEL0_START), .P_HSEL0_SIZE(P_HSEL0_SIZE),
                .P_HSEL1_START(P_HSEL1_START), .P_HSEL1_SIZE(P_HSEL1_SIZE),
                .P_HSEL2_START(P_HSEL2_START), .P_HSEL2_SIZE(P_HSEL2_SIZE))
  Uahb_lite
  (
       .HRESETn (HRESETn),
       .HCLK    (HCLK   ),

       .M_HADDR   (M_HADDR  ),
       .M_HTRANS  (M_HTRANS ),
       .M_HWRITE  (M_HWRITE ),
       .M_HSIZE   (M_HSIZE  ),
       .M_HBURST  (M_HBURST ),
       .M_HPROT   (M_HPROT  ),
       .M_HWDATA  (M_HWDATA ),
       .M_HRDATA  (M_HRDATA ),
       .M_HRESP   (M_HRESP  ),
       .M_HREADY  (M_HREADY ),

       .HADDR   (HADDR  ),
       .HTRANS  (HTRANS ),
       .HSIZE   (HSIZE  ),
       .HBURST  (HBURST ),
       .HWRITE  (HWRITE ),
       .HPROT   (HPROT  ),
       .HWDATA  (HWDATA ),
       .HREADY  (HREADY ),
       .HSEL0   (HSEL_0  ),
       .HRDATA0 (HRDATA_0),
       .HRESP0  (HRESP_0 ),
       .HREADY0 (HREADY_0),
       .HSEL1   (HSEL_1  ),
       .HRDATA1 (HRDATA_1),
       .HRESP1  (HRESP_1 ),
       .HREADY1 (HREADY_1),
       .HSEL2   (HSEL_2  ),
       .HRDATA2 (HRDATA_2),
       .HRESP2  (HRESP_2 ),
       .HREADY2 (HREADY_2),

       .REMAP   (REMAP)
  );

endmodule
//--------------------------------------------------------
// Revision history
//
// 2011.03.20: Started by Ando Ki.
//--------------------------------------------------------
