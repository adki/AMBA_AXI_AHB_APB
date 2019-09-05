//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi2apb_apb_if.v
//----------------------------------------------------------------
// VERSION: 2011.02.25.
//----------------------------------------------------------------
// Limitation
//  - APB only supports 32-bit data width.
//----------------------------------------------------------------
`timescale 1ns/1ns

`ifdef  AMBA_APB4
`ifndef AMBA_APB3
`define AMBA_APB3
`endif
`endif

//----------------------------------------------------------------
module axi2apb_apb_if
     #(parameter NUM_PSLAVE   = 8
               , WIDTH_PAD    =32 // address width
               , WIDTH_PDA    =32 // data width
               , WIDTH_PDS    =(WIDTH_PDA/8) // data strobe width
               )
(
       input  wire                  PRESETn
     , input  wire                  PCLK
     , output reg  [NUM_PSLAVE-1:0] PSEL
     , output reg  [NUM_PSLAVE-1:0] PENABLE
     , output reg  [NUM_PSLAVE-1:0] PWRITE
     , output reg  [WIDTH_PAD-1:0]  PADDR
     , output reg  [WIDTH_PDA-1:0]  PWDATA
     , input  wire [WIDTH_PDA-1:0]  PRDATA
     //-----------------------------------------------------------
     `ifdef AMBA_APB3
     , input  wire [NUM_PSLAVE-1:0] PREADY
     , input  wire [NUM_PSLAVE-1:0] PSLVERR
     `endif
     `ifdef AMBA_APB4
     , output reg  [WIDTH_PDS-1:0]  PSTRB
     , output reg  [ 2:0]           PPROT
     `endif
     //-----------------------------------------------------------
     , input  wire [NUM_PSLAVE-1:0] SEL
     //-----------------------------------------------------------
     , input  wire                 REQ
     , output reg                  ACK    // need sync
     , input  wire [WIDTH_PAD-1:0] ADDR
     , input  wire                 WR
     , input  wire [31:0]          DATAW
     , output reg  [31:0]          DATAR
     , input  wire [ 3:0]          BE
     , input  wire [ 2:0]          PROT
     , output reg                  ERROR
     //-----------------------------------------------------------
);
     //-----------------------------------------------------------
     // synopsys translate_off
     initial begin
             if (WIDTH_PAD!=32) $display("%m ERROR APB address width should be 32, but %2d", WIDTH_PAD);
             if (WIDTH_PDA!=32) $display("%m ERROR APB data width should be 32, but %2d", WIDTH_PDA);
     end
     // synopsys translate_on
     //-----------------------------------------------------------
     `ifndef AMBA_APB3
     wire [NUM_PSLAVE-1:0] PREADY  = {NUM_PSLAVE{1'b1}};
     wire [NUM_PSLAVE-1:0] PSLVERR = {NUM_PSLAVE{1'b0}};
     `endif
     `ifndef AMBA_APB4
     reg  [WIDTH_PDS-1:0]  PSTRB;
     reg  [ 2:0]           PPROT;
     `endif
     //-----------------------------------------------------------
     reg req_sync0, req_sync;
     always @ (posedge PCLK or negedge PRESETn) begin
            if (PRESETn==1'b0) begin
                req_sync  <= 1'b0;
                req_sync0 <= 1'b0;
            end else begin
                req_sync  <= req_sync0;
                req_sync0 <= REQ;
            end
     end
     //-----------------------------------------------------------
     reg [1:0] state;
     localparam ST_IDLE  = 'h0,
                ST_ADDR  = 'h1,
                ST_WAIT  = 'h2,
                ST_END   = 'h3;
     //-----------------------------------------------------------
     always @ (posedge PCLK or negedge PRESETn) begin
            if (PRESETn==1'b0) begin
                PSEL      <=  'h0;
                PENABLE   <=  'h0;
                PWRITE    <=  'h0;
                PADDR     <=  'h0;
                PWDATA    <=  'h0;
                PSTRB     <=  'h0;
                PPROT     <=  'h0;
                ACK       <=  'b0;
                ERROR     <=  'b0;
                DATAR     <=  'h0;
                state     <= ST_IDLE;
            end else begin
                case (state)
                ST_IDLE: begin
                   if (req_sync) begin
                       PSEL   <= SEL;
                       PWRITE <= {NUM_PSLAVE{WR}}&SEL;
                       PADDR  <= ADDR;
                       PWDATA <= DATAW;
                       PSTRB  <= {WIDTH_PDS{WR}}&BE;
                       PPROT  <= PROT;
                       state  <= ST_ADDR;
                   end
                   end // STW_IDLE
                ST_ADDR: begin
                   PENABLE  <= SEL;
                   state    <= ST_WAIT;
                   end // ST_ADDR
                ST_WAIT: begin
                   if (PREADY) begin
                       ERROR     <= PSLVERR;
                       PSEL      <=  'h0;
                       PENABLE   <=  'h0;
                       DATAR     <= PRDATA;
                       ACK       <= 1'b1;
                       state     <= ST_END;
                   end
                   end // ST_WAIT
                ST_END: begin
                   if (req_sync==1'b0) begin
                       ACK      <= 1'b0;
                       state    <= ST_IDLE;
                   end
                   end // ST_END
                endcase
            end
     end
     //-----------------------------------------------------------
     // synopsys translate_off
     integer idx, pnum;
     always @ (negedge PCLK or negedge PRESETn) begin
          if (PRESETn==1'b1) begin
              pnum = 0;
              for (idx=0; idx<NUM_PSLAVE; idx=idx+1) begin
                   if (PSEL[idx]) pnum = pnum + 1;
              end
              if (pnum>1)  $display($time,,"%m ERROR more than one APB slave selected %b", PSEL);
          end
     end
     // synopsys translate_on
     //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.02.25: 'PRESETn' added by Ando Ki.
//             It is related to 'PCLK'.
// 2011.02.18: Re-written by Ando Ki
// 2011.01.29: Staryted by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
