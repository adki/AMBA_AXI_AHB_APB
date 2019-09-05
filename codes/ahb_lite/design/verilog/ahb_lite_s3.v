//********************************************************
// Copyright (c) 2007-2009 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//********************************************************
// VERSION: 2009.12.28.
//********************************************************
`include "ahb_decoder_s3.v"
`include "ahb_s2m_s3.v"
`include "ahb_default_slave.v"
`timescale 1ns/1ns

module ahb_lite_s3
        #(parameter P_HSEL0_START = 16'h0000, P_HSEL0_SIZE  = 16'h0100,
                    P_HSEL1_START = 16'h1000, P_HSEL1_SIZE  = 16'h0100,
                    P_HSEL2_START = 16'h2000, P_HSEL2_SIZE  = 16'h0100)
(
        input   wire         HRESETn
      , input   wire         HCLK
      , input   wire  [31:0] M_HADDR
      , input   wire  [1:0]  M_HTRANS
      , input   wire         M_HWRITE
      , input   wire  [2:0]  M_HSIZE
      , input   wire  [2:0]  M_HBURST
      , input   wire  [3:0]  M_HPROT
      , input   wire  [31:0] M_HWDATA
      , output  wire  [31:0] M_HRDATA
      , output  wire  [1:0]  M_HRESP
      , output  wire         M_HREADY
      , output  wire         HWRITE
      , output  wire  [31:0] HADDR
      , output  wire  [1:0]  HTRANS
      , output  wire  [2:0]  HSIZE
      , output  wire  [2:0]  HBURST
      , output  wire  [3:0]  HPROT
      , output  wire  [31:0] HWDATA
      , output  wire         HREADY
      , output  wire         HSEL0
      , input   wire  [1:0]  HRESP0
      , input   wire  [31:0] HRDATA0
      , input   wire         HREADY0
      , output  wire         HSEL1
      , input   wire  [1:0]  HRESP1
      , input   wire  [31:0] HRDATA1
      , input   wire         HREADY1
      , output  wire         HSEL2
      , input   wire  [1:0]  HRESP2
      , input   wire  [31:0] HRDATA2
      , input   wire         HREADY2
      , input   wire         REMAP
);
   /*********************************************************/
   wire HSELd; // default slave
   wire [31:0] HRDATAd;
   wire [1:0]  HRESPd;
   wire        HREADYd;
   /*********************************************************/
   assign HADDR  = M_HADDR;
   assign HTRANS = M_HTRANS;
   assign HSIZE  = M_HSIZE;
   assign HBURST = M_HBURST;
   assign HWRITE = M_HWRITE;
   assign HPROT  = M_HPROT;
   assign HWDATA = M_HWDATA;
   assign HREADY = M_HREADY;
   /*********************************************************/
   defparam
   Uahb_decoder.P_NUM         = 3, // how many slaves
   Uahb_decoder.P_ADDR_START0 = P_HSEL0_START,
   Uahb_decoder.P_ADDR_SIZE0  = P_HSEL0_SIZE ,
   Uahb_decoder.P_ADDR_START1 = P_HSEL1_START,
   Uahb_decoder.P_ADDR_SIZE1  = P_HSEL1_SIZE ,
   Uahb_decoder.P_ADDR_START2 = P_HSEL2_START,
   Uahb_decoder.P_ADDR_SIZE2  = P_HSEL2_SIZE ;
   ahb_decoder_s3 Uahb_decoder (
                  .HADDR(M_HADDR),
                  .HSELd(HSELd), // default
                  .HSEL0(HSEL0),
                  .HSEL1(HSEL1),
                  .HSEL2(HSEL2),
                  .REMAP(REMAP));
   /*********************************************************/
   ahb_s2m_s3 Uahb_s2m (
              .HRESETn(HRESETn),
              .HCLK   (HCLK),
              .HSEL0  (HSEL0),
              .HSEL1  (HSEL1),
              .HSEL2  (HSEL2),
              .HSELd  (HSELd),
              .HRDATA(M_HRDATA),
              .HRESP (M_HRESP),
              .HREADY(M_HREADY),
              .HRDATA0(HRDATA0),
              .HRESP0 (HRESP0 ),
              .HREADY0(HREADY0),
              .HRDATA1(HRDATA1),
              .HRESP1 (HRESP1 ),
              .HREADY1(HREADY1),
              .HRDATA2(HRDATA2),
              .HRESP2 (HRESP2 ),
              .HREADY2(HREADY2),
              .HRDATAd(HRDATAd),
              .HRESPd (HRESPd ),
              .HREADYd(HREADYd));

   /*********************************************************/
   ahb_default_slave 
              Uahb_default_slave (
              .HRESETn(HRESETn),
              .HCLK   (HCLK),
              .HSEL   (HSELd),
              .HADDR  (HADDR),
              .HTRANS (HTRANS),
              .HWRITE (HWRITE),
              .HSIZE  (HSIZE),
              .HBURST (HBURST),
              .HWDATA (HWDATA),
              .HRDATA(HRDATAd),
              .HRESP (HRESPd),
              .HREADYin(HREADY),
              .HREADYout(HREADYd));

   /*********************************************************/
endmodule
