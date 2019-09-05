`ifndef AHB_ARBITER_M2_V
`define AHB_ARBITER_M2_V
/*********************************************************
 * Copyright (c) 2010 by Ando Ki.
 * All right reserved.
 *
 * http://www.dynalith.com
 * adki@dynalith.com
 *********************************************************/
/* A simplified arbiter for AMBA AHB
 *
 */
`timescale 1ns/1ns

module ahb_arbiter_m2 #(parameter P_NUM = 2) // the number of masters
(
       input   wire       HRESETn
     , input   wire       HCLK
     , input   wire       HREADY
     , input   wire       HBUSREQ_0
     , input   wire       HBUSREQ_1
     , output  wire       HGRANT_0
     , output  wire       HGRANT_1
     , output  reg  [3:0] HMASTER
);
    //---------------------------------------------
    wire [0:1] hbusreq = {HBUSREQ_0,HBUSREQ_1};
    reg  [0:1] hgrant;
    assign {HGRANT_0, HGRANT_1} = hgrant;
    //---------------------------------------------
    always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==1'b0) hgrant <= 4'h0;
       else begin
            if (HREADY==1'b1) begin
               casex ({hbusreq,hgrant})
                   // priority
                   4'b1x_00: hgrant <= 2'b10;
                   4'b01_00: hgrant <= 2'b01;
                   // stay
                   4'b1x_10: hgrant <= 2'b10;
                   4'bx1_01: hgrant <= 2'b01;
                   // last
                   4'b00_xx: hgrant <= 2'b00;
                   // last and handover
                   4'b01_10: hgrant <= 2'b01;
                   4'b00_10: hgrant <= 2'b00;
                   4'b10_01: hgrant <= 2'b10;
                   4'b00_01: hgrant <= 2'b00;
                   default : hgrant <= 2'b00;
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
                   2'b1x:   HMASTER <= #1 4'h0;
                   2'b01:   HMASTER <= #1 4'h1;
                   default: HMASTER <= #1 4'hF;
               endcase
            end
        end
    end

// synopsys translate_off
`ifdef RIGOR
   wire [1:0] _hgrant = {HGRANT_0, HGRANT_1};
   always @ (posedge HCLK) begin
      if ((_hgrant!=2'b01)&&
	  (_hgrant!=2'b10)&&
	  (_hgrant!=2'b00))
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
