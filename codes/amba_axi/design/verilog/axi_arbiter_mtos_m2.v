//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi_arbiter_mtos_m2.v
//----------------------------------------------------------------
// VERSION: 2011.03.12.
//----------------------------------------------------------------
`timescale 1ns/1ns
`include "axi_arbiter_fifo_sync.v"

//----------------------------------------------------------------
module axi_arbiter_mtos_m2
   // synopsys translate_off
   `protect
   // synopsys translate_on
     #(parameter WIDTH_CID=4  // Channel ID width in bits
                 , WIDTH_ID =4 // Transaction ID
                 , WIDTH_SID=(WIDTH_CID+WIDTH_ID)
                 , NUM = 2
                 )
(
       input  wire                  ARESETn
     , input  wire                  ACLK
     //-----------------------------------------------------------
     , input  wire  [NUM-1:0]       AWSELECT  // selected by address decoder
     , input  wire  [NUM-1:0]       AWVALID
     , input  wire  [NUM-1:0]       AWREADY
     , input  wire  [NUM-1:0]       AWLOCK    // lock-bit only not exclusive-bit
     , output wire  [NUM-1:0]       AWGRANT
     , input  wire  [WIDTH_SID-1:0] AWSID0    // {master_id,trans_id}
     , input  wire  [WIDTH_SID-1:0] AWSID1    // {master_id,trans_id}
     //-----------------------------------------------------------
     , input  wire  [NUM-1:0]       WVALID
     , input  wire  [NUM-1:0]       WLAST
     , input  wire  [NUM-1:0]       WREADY
     , output reg   [NUM-1:0]       WGRANT
     , input  wire  [WIDTH_SID-1:0] WSID0   // {master_id,trans_id}
     , input  wire  [WIDTH_SID-1:0] WSID1   // {master_id,trans_id}
     //-----------------------------------------------------------
     , input  wire  [NUM-1:0]       ARSELECT  // selected by address decoder
     , input  wire  [NUM-1:0]       ARVALID
     , input  wire  [NUM-1:0]       ARLOCK    // lock-bit only not exclusive-bit
     , input  wire  [NUM-1:0]       ARREADY
     , output wire  [NUM-1:0]       ARGRANT
     , input  wire  [WIDTH_SID-1:0] ARSID0    // {master_id,trans_id}
     , input  wire  [WIDTH_SID-1:0] ARSID1    // {master_id,trans_id}
     //-----------------------------------------------------------
     , input  wire  [WIDTH_CID-1:0] MID0  // master0 id
     , input  wire  [WIDTH_CID-1:0] MID1  // master0 id
);
     //-----------------------------------------------------------
     reg                  locked, unlock;
     reg  [WIDTH_SID-1:0] locksid; // {master_id,trans_id}
     //-----------------------------------------------------------
     wire [WIDTH_SID-1:0] granted_arsid = ({WIDTH_SID{ARGRANT[0]}}&ARSID0)
                                        | ({WIDTH_SID{ARGRANT[1]}}&ARSID1);
     reg  [NUM-1:0] argrant_reg;
     //-----------------------------------------------------------
     // The atomic access should consist of a read followed by a write.
     // The atomic access should be a single burst transfer.
     //-----------------------------------------------------------
     // read-address arbiter
     //-----------------------------------------------------------
     reg [1:0] stateAR;
     localparam STAR_RUN    = 'h0,
                STAR_WAIT   = 'h1,
                STAR_LOCK   = 'h2;
     always @ (posedge ACLK or negedge ARESETn) begin
           if (ARESETn==1'b0) begin
               locked      <= 1'b0;
               locksid     <=  'h0;
               argrant_reg <= 'h0;
               stateAR <= STAR_RUN;
           end else begin
               case (stateAR)
               STAR_RUN: begin
                    if (|(ARGRANT&ARLOCK)) begin // note that ARLOCK={M1_ARLOCK[1],M1_ALOCK[1]}
                        locked      <= 1'b1;
                        locksid     <= granted_arsid;
                        argrant_reg <= ARGRANT;
                        stateAR     <= STAR_LOCK;
                    end else begin
                        if (|ARGRANT) begin
                           // prevent the case that
                           // the granted-one is not completed dueo to ~ARREADY
                           // and new higher-priority-one joined,
                           // then things can go wrong.
                           if (~|(ARGRANT&ARREADY)) begin
                               argrant_reg <= ARGRANT;
                               stateAR     <= STAR_WAIT;
                           end
                        end
                    end
                    end // STAR_RUN
               STAR_WAIT: begin
                    if (|(ARGRANT&ARVALID&ARREADY)) begin
                        stateAR <= STAR_RUN;
                    end
                    end // STAR_WAIT
               STAR_LOCK: begin
                    if (unlock) begin
                        locked      <= 1'b0;
                        locksid     <=  'h0;
                        argrant_reg <=  'h0;
                        stateAR     <= STAR_RUN;
                    end
                    end // STAR_LOCK
               endcase
           end
     end
     //-----------------------------------------------------------
     assign ARGRANT = (stateAR==STAR_RUN) ? priority_sel(ARSELECT&ARVALID)
                                          : argrant_reg;
     //-----------------------------------------------------------
     // write-address arbiter
     //-----------------------------------------------------------
     wire [WIDTH_SID-1:0] fifo_push_din   = (AWGRANT[0]==1'b1) ? AWSID0
                                          : (AWGRANT[1]==1'b1) ? AWSID1
                                          : 'h0;
     wire                 fifo_push_valid = |(AWGRANT&AWREADY);
     wire                 fifo_pop_ready;
     wire                 fifo_pop_valid;
     wire [WIDTH_SID-1:0] fifo_pop_dout ;
     //-----------------------------------------------------------
     reg [NUM-1:0] awgrant_reg;
     //-----------------------------------------------------------
     reg [1:0] stateAW;
     localparam STAW_RUN    = 'h0,
                STAW_WAIT   = 'h1,
                STAW_LOCK   = 'h2;
     always @ (posedge ACLK or negedge ARESETn) begin
           if (ARESETn==1'b0) begin
               awgrant_reg <=  'h0;
               unlock      <= 1'b0;
               stateAW     <= STAW_RUN;
           end else begin
               case (stateAW)
               STAW_RUN: begin
                    if (~locked) begin
                        if (|AWGRANT) begin
                            if (~|(AWGRANT&AWREADY)) begin
                               awgrant_reg <= AWGRANT;
                               stateAW     <= STAW_WAIT;
                            end
                        end
                    end else begin
                        if (locksid[WIDTH_SID-1:WIDTH_ID]==MID0) begin
                           if (AWSELECT[0]&AWVALID[0]) begin
                               if (locksid[WIDTH_SID-1:WIDTH_ID]==AWSID0[WIDTH_SID-1:WIDTH_ID]) begin
                                   awgrant_reg <= 2'b01;
                                   if (~AWLOCK[0]) unlock <= 1'b1;
                                   else            unlock <= 1'b0;
                                   stateAW <= STAW_LOCK;
                               end else begin
                                   // synopsys translate_off
                                   `ifdef RIGOR
                                   $display($time,,"%m ERROR un-expected write-request during lock 0x%x",
                                                    AWSID0);
                                   `endif
                                   // synopsys translate_on
                               end
                           end
                        end else if (locksid[WIDTH_SID-1:WIDTH_ID]==MID1) begin
                           if (AWSELECT[1]&AWVALID[1]) begin
                               if (locksid[WIDTH_SID-1:WIDTH_ID]==AWSID1[WIDTH_SID-1:WIDTH_ID]) begin
                                   awgrant_reg <= 2'b10;
                                   if (~AWLOCK[1]) unlock <= 1'b1;
                                   else            unlock <= 1'b0;
                                   stateAW <= STAW_LOCK;
                               end else begin
                                   // synopsys translate_off
                                   `ifdef RIGOR
                                   $display($time,,"%m ERROR un-expected write-request during lock 0x%x",
                                                    AWSID1);
                                   `endif
                                   // synopsys translate_on
                               end
                           end
                        end
                        // synopsys translate_off
                        `ifdef RIGOR
                        else begin
                             $display($time,,"%m ERROR un-expected MID for lock 0x%x",
                                              locksid[WIDTH_SID-1:WIDTH_ID]);
                        end
                        `endif
                        // synopsys translate_on
                    end
                    end // STAW_RUN
               STAW_WAIT: begin
                    if (|(AWGRANT&AWVALID&AWREADY)) begin
                       awgrant_reg <= 'h0;
                       stateAW     <= STAW_RUN;
                    end
                    end // STAW_WAIT
               STAW_LOCK: begin
                    if (|(AWGRANT&AWVALID&AWREADY)) begin
                       awgrant_reg <=  'h0;
                       unlock      <= 1'b0;
                       stateAW     <= STAW_RUN;
                    end
                    end // STAW_LOCK
               endcase
           end
     end
     //-----------------------------------------------------------
     assign AWGRANT = ((stateAW==STAW_RUN)&~locked) ? priority_sel(AWSELECT&AWVALID)
                                                    : awgrant_reg;
     //-----------------------------------------------------------
     axi_arbiter_fifo_sync #(.FDW(WIDTH_SID), .FAW(4))
     Uaxi_arbiter_fifo_sync
     (
           .rstn     (ARESETn)
         , .clr      (1'b0   )
         , .clk      (ACLK   )
         , .wr_rdy   (               )
         , .wr_vld   (fifo_push_valid)
         , .wr_din   (fifo_push_din  )
         , .rd_rdy   (fifo_pop_ready )
         , .rd_vld   (fifo_pop_valid )
         , .rd_dout  (fifo_pop_dout  )
         , .full     (               )
         , .empty    ()
         , .fullN    ()
         , .emptyN   ()
         , .item_cnt ()
         , .room_cnt ()
     );
     //-----------------------------------------------------------
     wire active_wvalid = |(WGRANT&WVALID);
     wire active_wready = |WREADY;
     wire active_wlast  = |(WGRANT&WLAST);
     //-----------------------------------------------------------
     assign fifo_pop_ready = fifo_pop_valid
                           & active_wvalid
                           & active_wready
                           & active_wlast;
     //-----------------------------------------------------------
     always @ ( * ) begin
          if (~fifo_pop_valid) begin
              WGRANT = 2'b00;
          end else begin
              if (fifo_pop_dout[WIDTH_SID-1:WIDTH_ID]==MID0) begin
                  WGRANT = 2'b01;
              end else if (fifo_pop_dout[WIDTH_SID-1:WIDTH_ID]==MID1) begin
                  WGRANT = 2'b10;
              end else begin
                  WGRANT = 2'b00;
              end
          end
     end
     // synopsys translate_off
     `ifdef RIGOR
     always @ (negedge ACLK or negedge ARESETn) begin
          if (ARESETn==1'b1) begin
              if (fifo_pop_valid&~|WGRANT) begin
                  $display($time,,"%m ERROR FIFO valid, but none granted WGRANT");
              end
          end
     end
     `endif
     // synopsys translate_on
     //-----------------------------------------------------------
     function [NUM-1:0] priority_sel;
          input [NUM-1:0] request;
     begin
          casex (request)
          2'b00: priority_sel = 2'b00;
          2'bx1: priority_sel = 2'b01;
          2'b10: priority_sel = 2'b10;
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
// 2011.03.12: 'locksid[WIDTH_SID-1:WIDTH_ID]' used to check lock pair.
// 2011.01.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
