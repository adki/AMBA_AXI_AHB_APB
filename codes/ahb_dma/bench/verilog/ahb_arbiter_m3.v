`ifndef AHB_ARBITER_M3_V
`define AHB_ARBITER_M3_V
/*********************************************************
 * Copyright (c) 2008 by Ando Ki.
 * All right reserved.
 *********************************************************/
/* A simplified arbiter for AMBA AHB
 *
 */
`timescale 1ns/1ns

module ahb_arbiter_m3 (
       HRESETn,
       HCLK,
       HREADY,
       HBUSREQ_0,
       HBUSREQ_1,
       HBUSREQ_2,
       HGRANT_0,
       HGRANT_1,
       HGRANT_2,
       HMASTER
);
parameter P_NUM = 3; // the number of masters
       input        HRESETn;   wire       HRESETn;  
       input        HCLK;      wire       HCLK;
       input        HREADY;    wire       HREADY;
       input        HBUSREQ_0; wire       HBUSREQ_0;
       input        HBUSREQ_1; wire       HBUSREQ_1;
       input        HBUSREQ_2; wire       HBUSREQ_2;
       output       HGRANT_0;  wire       HGRANT_0;
       output       HGRANT_1;  wire       HGRANT_1;
       output       HGRANT_2;  wire       HGRANT_2;
       output [3:0] HMASTER;   reg  [3:0] HMASTER;   
       //---------------------------------------------
       wire [0:2] hbusreq = {HBUSREQ_0,HBUSREQ_1,HBUSREQ_2};
       reg  [0:2] hgrant;
       assign {HGRANT_0, HGRANT_1, HGRANT_2} = hgrant;
       //---------------------------------------------
       always @ (posedge HCLK or negedge HRESETn) begin
          if (HRESETn==1'b0) hgrant <= 4'h0;
          else begin
               if (HREADY==1'b1) begin  // added by ADKI, 2008.12.08.
                  casex ({hbusreq,hgrant})
                      // priority
                      6'b1xx_000: hgrant <= 3'b100;
                      6'b01x_000: hgrant <= 3'b010;
                      6'b001_000: hgrant <= 3'b001;
                      // stay
                      6'b1xx_100: hgrant <= 3'b100;
                      6'bx1x_010: hgrant <= 3'b010;
                      6'bxx1_001: hgrant <= 3'b001;
                      // last
                      6'b000_xxx: hgrant <= 3'b000;
                      // last and handover
                      6'b01x_100: hgrant <= 3'b010;
                      6'b001_100: hgrant <= 3'b001;
                      6'b10x_010: hgrant <= 3'b100;
                      6'b001_010: hgrant <= 3'b001;
                      6'b1x0_001: hgrant <= 3'b100;
                      6'b010_001: hgrant <= 3'b010;
                      default   : hgrant <= 3'b000;
                  endcase
               end
          end
       end
       always @ (posedge HCLK or negedge HRESETn)
       begin
           if (HRESETn==1'b0) begin
               HMASTER <= 4'hF;
           end else begin
               if (HREADY==1'b1) begin
                  casex (hgrant)
                      3'b1xx:  HMASTER <= #1 4'h0;
                      3'b01x:  HMASTER <= #1 4'h1;
                      3'b001:  HMASTER <= #1 4'h2;
                      default: HMASTER <= #1 4'hF;
                  endcase
               end
           end
       end

// synopsys translate_off
`ifdef RIGOR
   wire [2:0] _hgrant = {HGRANT_0, HGRANT_1, HGRANT_2};
   always @ (posedge HCLK) begin
      if ((_hgrant!=3'b001)&&(_hgrant!=3'b010)&&(_hgrant!=3'b100)&&
          (_hgrant!=3'b000))
          $display($time,, "%m ERROR: more than one has been granted! 0x%x", _hgrant);
   end
`endif
// synopsys translate_on
endmodule
//********************************************************
// Revision history
//
// Dec. 08, 2008:
//      'hgrant' should be changed when HREADY is 1.
// May  05, 2008:
//      'hgrant' has been modified to reflect hand-over cases.
//********************************************************
`endif
