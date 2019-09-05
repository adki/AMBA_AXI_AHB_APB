//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// mem_apb_s3.h
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
// Macros and parameters:
//     SIZE_IN_BYTES: Size of memory in bytes
//     DELAY:         The number of clocks until HREADY
//--------------------------------------------------------
`timescale 1ns/1ns

`ifdef AMBA4
`ifndef AMBA3
ERROR AMBA3 shouldb edefined when AMBA4 is defined
`endif
`endif

module mem_apb
     #(parameter SIZE_IN_BYTES=1024  // memory depth
               , DELAY=0           ) // access delay if any for AMBA3/4
(
       input   wire          PRESETn
     , input   wire          PCLK
     , input   wire          PSEL
     , input   wire  [31:0]  PADDR
     , input   wire          PENABLE
     , input   wire          PWRITE
     , input   wire  [31:0]  PWDATA
     , output  reg   [31:0]  PRDATA
     `ifdef AMBA3
     , output  reg           PREADY
     , output  reg           PSLVERR
     `endif
     `ifdef AMBA4
     , input   wire  [ 2:0]  PPROT
     , input   wire  [ 3:0]  PSTRB
     `endif
);
    //----------------------------------------------------
    to be fillld
    //----------------------------------------------------
endmodule

//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
