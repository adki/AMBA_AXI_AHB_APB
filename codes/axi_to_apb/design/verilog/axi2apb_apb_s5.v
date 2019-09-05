//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi2apb_apb_s5.v
//----------------------------------------------------------------
// VERSION: 2011.02.16.
//----------------------------------------------------------------
// Limitation
//  - APB only supports 32-bit data width.
//----------------------------------------------------------------
`timescale 1ns/1ns
`include "axi2apb_apb_if.v"

`ifdef  AMBA_APB4
`ifndef AMBA_APB3
`define AMBA_APB3
`endif
`endif

module axi2apb_apb_s5 #(parameter NUM_PSLAVE   = 5
                             , WIDTH_PAD    =32 // address width
                             , WIDTH_PDA    =32 // data width
                             , WIDTH_PDS    =(WIDTH_PDA/8) // data strobe width
                             , ADDR_PBASE0  =32'h0000_0000 , ADDR_PLENGTH0=12
                             , ADDR_PBASE1  =32'h0000_1000 , ADDR_PLENGTH1=12
                             , ADDR_PBASE2  =32'h0000_2000 , ADDR_PLENGTH2=12
                             , ADDR_PBASE3  =32'h0000_3000 , ADDR_PLENGTH3=12
                             , ADDR_PBASE4  =32'h0000_4000 , ADDR_PLENGTH4=12
                    )
(
       input  wire                 PRESETn
     , input  wire                 PCLK
     , output wire [WIDTH_PAD-1:0] PADDR
     , output wire                 PENABLE
     , output wire                 PWRITE
     , output wire [WIDTH_PDA-1:0] PWDATA
     , output wire                 PSEL_0
     , output wire                 PSEL_1
     , output wire                 PSEL_2
     , output wire                 PSEL_3
     , output wire                 PSEL_4
     , input  wire [WIDTH_PDA-1:0] PRDATA_0
     , input  wire [WIDTH_PDA-1:0] PRDATA_1
     , input  wire [WIDTH_PDA-1:0] PRDATA_2
     , input  wire [WIDTH_PDA-1:0] PRDATA_3
     , input  wire [WIDTH_PDA-1:0] PRDATA_4
     //-----------------------------------------------------------
     `ifdef AMBA_APB3
     , input  wire                 PREADY_0
     , input  wire                 PREADY_1
     , input  wire                 PREADY_2
     , input  wire                 PREADY_3
     , input  wire                 PREADY_4
     , input  wire                 PSLVERR_0
     , input  wire                 PSLVERR_1
     , input  wire                 PSLVERR_2
     , input  wire                 PSLVERR_3
     , input  wire                 PSLVERR_4
     `endif
     `ifdef AMBA_APB4
     , output wire [WIDTH_PDS-1:0] PSTRB
     , output wire [ 2:0]          PPROT
     `endif
     //-----------------------------------------------------------
     , input  wire                 REQ
     , output wire                 ACK    // need sync
     , input  wire [WIDTH_PAD-1:0] ADDR
     , input  wire                 WR
     , input  wire [31:0]          DATAW
     , output wire [31:0]          DATAR
     , input  wire [ 3:0]          BE
     , input  wire [ 2:0]          PROT
     , output wire                 ERROR
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     wire [NUM_PSLAVE-1:0]    SEL        ;
     wire [NUM_PSLAVE-1:0]    PSEL_all   ;
     wire [NUM_PSLAVE-1:0]    PENABLE_all;
     wire [NUM_PSLAVE-1:0]    PWRITE_all ;
     wire [WIDTH_PDA-1:0]     PRDATA     ;
     `ifdef AMBA_APB3
     wire [NUM_PSLAVE-1:0]    PREADY_all ;
     wire [NUM_PSLAVE-1:0]    PSLVERR_all;
     `endif
     //-----------------------------------------------------------
     assign SEL[0] = (ADDR[WIDTH_PAD-1:ADDR_PLENGTH0] == ADDR_PBASE0[WIDTH_PAD-1:ADDR_PLENGTH0]);
     assign SEL[1] = (ADDR[WIDTH_PAD-1:ADDR_PLENGTH1] == ADDR_PBASE1[WIDTH_PAD-1:ADDR_PLENGTH1]);
     assign SEL[2] = (ADDR[WIDTH_PAD-1:ADDR_PLENGTH2] == ADDR_PBASE2[WIDTH_PAD-1:ADDR_PLENGTH2]);
     assign SEL[3] = (ADDR[WIDTH_PAD-1:ADDR_PLENGTH3] == ADDR_PBASE3[WIDTH_PAD-1:ADDR_PLENGTH3]);
     assign SEL[4] = (ADDR[WIDTH_PAD-1:ADDR_PLENGTH4] == ADDR_PBASE4[WIDTH_PAD-1:ADDR_PLENGTH4]);
     //-----------------------------------------------------------
     assign {PSEL_4,PSEL_3,PSEL_2,PSEL_1,PSEL_0} = PSEL_all;
     assign PENABLE = |PENABLE_all;
     assign PWRITE  = |PWRITE_all;
     assign PRDATA = {WIDTH_PDA{SEL[4]}}&PRDATA_4
                   | {WIDTH_PDA{SEL[3]}}&PRDATA_3
                   | {WIDTH_PDA{SEL[2]}}&PRDATA_2
                   | {WIDTH_PDA{SEL[1]}}&PRDATA_1
                   | {WIDTH_PDA{SEL[0]}}&PRDATA_0;
     `ifdef AMBA_APB3
     assign PREADY_all  = {PREADY_4,PREADY_3,PREADY_2,PREADY_1,PREADY_0};
     assign PSLVERR_all = {PSLVERR_4,PSLVERR_3,PSLVERR_2,PSLVERR_1,PSLVERR_0};
     `endif
     //-----------------------------------------------------------
     axi2apb_apb_if #(.NUM_PSLAVE(NUM_PSLAVE)
                     ,.WIDTH_PAD (WIDTH_PAD ) // address width
                     ,.WIDTH_PDA (WIDTH_PDA ) // data width
                       )
     Uaxi2apb_apb_if (
            .PRESETn  (PRESETn    )
          , .PCLK     (PCLK       )
          , .PSEL     (PSEL_all   )
          , .PENABLE  (PENABLE_all)
          , .PWRITE   (PWRITE_all )
          , .PADDR    (PADDR      )
          , .PWDATA   (PWDATA     )
          , .PRDATA   (PRDATA     )
     `ifdef AMBA_APB3
          , .PREADY   (PREADY_all )
          , .PSLVERR  (PSLVERR_all)
     `endif
     `ifdef AMBA_APB4
          , .PSTRB    (PSTRB  )
          , .PPROT    (PPROT  )
     `endif
          , .SEL      (SEL    )
          , .REQ      (REQ    )
          , .ACK      (ACK    )
          , .ADDR     (ADDR   )
          , .WR       (WR     )
          , .DATAW    (DATAW  )
          , .DATAR    (DATAR  )
          , .BE       (BE     )
          , .PROT     (PROT   )
          , .ERROR    (ERROR  )
     );
     //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.02.18: Re-written by Ando Ki
// 2011.01.29: Staryted by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
