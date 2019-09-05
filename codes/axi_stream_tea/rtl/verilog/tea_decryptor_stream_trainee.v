//--------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`include "tea_decryptor_core.v"
`timescale 1ns/1ns

module tea_decryptor_stream
     #(parameter STREAM_WIDTH_DATA=64
               , STREAM_WIDTH_DS=(STREAM_WIDTH_DATA/8)
               , STREAM_WIDTH_TID=8
               , STREAM_WIDTH_TDEST=3
               , STREAM_WIDTH_TUSER=1
               , TEA_KEY=128'hABAB_ABAB_ABAB_ABAB_ABAB_ABAB_ABAB_ABAB
               , DELTA=32'h9E3779B9
               )
(
       input   wire                           ARESETn
     , input   wire                           ACLK
     //--------------------------------------------------
     , output  wire                           S_TREADY
     , input   wire                           S_TVALID
     , input   wire  [STREAM_WIDTH_DATA-1:0]  S_TDATA
     , input   wire  [STREAM_WIDTH_DS-1:0]    S_TSTRB
     , input   wire  [STREAM_WIDTH_DS-1:0]    S_TKEEP
     , input   wire                           S_TLAST
     , input   wire  [STREAM_WIDTH_TID-1:0]   S_TID
     , input   wire  [STREAM_WIDTH_TDEST-1:0] S_TDEST
     `ifdef AMBA_AXI_TUSER
     , input   wire  [STREAM_WIDTH_TUSER-1:0] S_TUSER
     `endif
     //----------------------------------------------------
     , input   wire                           M_TREADY
     , output  wire                           M_TVALID
     , output  wire  [STREAM_WIDTH_DATA-1:0]  M_TDATA
     , output  wire  [STREAM_WIDTH_DS-1:0]    M_TSTRB
     , output  wire  [STREAM_WIDTH_DS-1:0]    M_TKEEP
     , output  wire                           M_TLAST
     , output  wire  [STREAM_WIDTH_TID-1:0]   M_TID  
     , output  wire  [STREAM_WIDTH_TDEST-1:0] M_TDEST
     `ifdef AMBA_AXI_TUSER
     , output  wire  [STREAM_WIDTH_TUSER-1:0] M_TUSER
     `endif
     //--------------------------------------------------
);
    //-----------------------------------------------------
    .....
    //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2015.07.29: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
