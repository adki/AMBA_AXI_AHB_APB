//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi_arbiter_stom_s2.v
//----------------------------------------------------------------
// VERSION: 2011.01.03.
//----------------------------------------------------------------
//   0: highest priority
// NUM: default slave
//----------------------------------------------------------------
`timescale 1ns/1ns

//----------------------------------------------------------------
module axi_arbiter_stom_s2
   // synopsys translate_off
   `protect
   // synopsys translate_on
     #(parameter NUM = 2)
(
       input  wire           ARESETn
     , input  wire           ACLK
     //-----------------------------------------------------------
     , input  wire  [NUM:0]  BSELECT  // selected by comparing trans_id
     , input  wire  [NUM:0]  BVALID
     , input  wire  [NUM:0]  BREADY
     , output wire  [NUM:0]  BGRANT
     //-----------------------------------------------------------
     , input  wire  [NUM:0]  RSELECT  // selected by comparing trans_id
     , input  wire  [NUM:0]  RVALID
     , input  wire  [NUM:0]  RREADY
     , input  wire  [NUM:0]  RLAST
     , output wire  [NUM:0]  RGRANT
);
     //-----------------------------------------------------------
     // read-data arbiter
     //-----------------------------------------------------------
     reg [NUM:0] rgrant_reg;
     //-----------------------------------------------------------
     reg stateR;
     localparam STR_RUN    = 'h0,
                STR_WAIT   = 'h1;
     always @ (posedge ACLK or negedge ARESETn) begin
           if (ARESETn==1'b0) begin
               rgrant_reg  <= 'h0;
               stateR      <= STR_RUN;
           end else begin
               case (stateR)
               STR_RUN: begin
                    if (|RGRANT) begin
                       if (~|(RGRANT&RREADY&RLAST)) begin
                           rgrant_reg <= RGRANT;
                           stateR     <= STR_WAIT;
                       end
                    end
                    end // STR_RUN
               STR_WAIT: begin
                    if (|(RGRANT&RVALID&RREADY&RLAST)) begin
                        rgrant_reg <= 'h0;
                        stateR     <= STR_RUN;
                    end
                    end // STR_WAIT
               endcase
           end
     end
     //-----------------------------------------------------------
     assign RGRANT = (stateR==STR_RUN) ? priority_sel(RSELECT&RVALID)
                                       : rgrant_reg;
     //-----------------------------------------------------------
     // write-response arbiter
     //-----------------------------------------------------------
     reg [NUM:0] bgrant_reg;
     //-----------------------------------------------------------
     reg stateB;
     localparam STB_RUN    = 'h0,
                STB_WAIT   = 'h1;
     always @ (posedge ACLK or negedge ARESETn) begin
           if (ARESETn==1'b0) begin
               bgrant_reg  <= 'h0;
               stateB      <= STB_RUN;
           end else begin
               case (stateB)
               STB_RUN: begin
                    if (|BGRANT) begin
                       if (~|(BGRANT&BREADY)) begin
                           bgrant_reg <= BGRANT;
                           stateB     <= STB_WAIT;
                       end
                    end
                    end // STB_RUN
               STB_WAIT: begin
                    if (|(BGRANT&BVALID&BREADY)) begin
                        bgrant_reg <= 'h0;
                        stateB     <= STB_RUN;
                    end
                    end // STB_WAIT
               endcase
           end
     end
     //-----------------------------------------------------------
     assign BGRANT = (stateB==STB_RUN) ? priority_sel(BSELECT&BVALID)
                                       : bgrant_reg;
     //-----------------------------------------------------------
     function [NUM:0] priority_sel;
        input [NUM:0] request;
     begin
          casex (request)
          3'b000: priority_sel = 3'b000;
          3'bxx1: priority_sel = 3'b001;
          3'bx10: priority_sel = 3'b010;
          3'b100: priority_sel = 3'b100;
          endcase
     end
     endfunction
     //-----------------------------------------------------------
   // synopsys translate_off
   `endprotect
   // synopsys translate_on
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.01.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
