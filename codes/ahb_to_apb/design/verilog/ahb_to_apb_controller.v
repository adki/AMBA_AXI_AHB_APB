`ifndef AHB_TO_APB_CONTROLLER_V
`define AHB_TO_APB_CONTROLLER_V
//--------------------------------------------------------
// Copyright (c) 2011 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// VERSION: 2011.03.30.
//--------------------------------------------------------
// AHB to AHB
//--------------------------------------------------------
`timescale 1ns/1ns

module ahb_to_apb_controller (
       input  wire        HRESETn
     , input  wire        HCLK
     , input  wire        HSEL
     , input  wire [31:0] HADDR
     , input  wire [ 1:0] HTRANS
     , input  wire [ 3:0] HPROT
     , input  wire        HWRITE
     , input  wire [ 2:0] HSIZE
     , input  wire [ 2:0] HBURST
     , input  wire [31:0] HWDATA
     , output reg  [31:0] HRDATA
     , output reg  [ 1:0] HRESP
     , input  wire        HREADYin
     , output reg         HREADYout
     , input  wire        PCLK
     , input  wire        PRESETn
     , output reg         PSEL
     , output reg         PENABLE
     , output wire [31:0] PADDR
     , output wire        PWRITE
     , input  wire [31:0] PRDATA
     , output wire [31:0] PWDATA
     `ifdef AMBA_APB3
     , input  wire        PREADY
     , input  wire        PSLVERR
     `endif
     `ifdef AMBA_APB4
     , output wire [ 2:0] PPROT
     , output wire [ 3:0] PSTRB
     `endif
     , input  wire [ 1:0] CLOCK_RATIO // 0=1:1, 3=async
);
   //-----------------------------------------------------
   `ifndef AMBA_APB3
   wire    PREADY  = 1'b1;
   wire    PSLVERR = 1'b0;
   `endif
   `ifndef AMBA_APB4
   wire [ 2:0] PPROT;
   wire [ 3:0] PSTRB;
   `endif
   //-----------------------------------------------------
   reg  [31:0] tADDR ;
   reg         tWRITE;
   reg  [31:0] tWDATA;
   reg  [31:0] tRDATA;
   reg         tREQ  ;
   reg         tACK  ;
   reg         tERROR;
   reg  [ 2:0] tPROT ;
   reg  [ 3:0] tSTRB ;
   //-----------------------------------------------------
   assign PADDR   = tADDR ;
   assign PWRITE  = tWRITE;
   assign PWDATA  = tWDATA;
   assign PPROT   = tPROT ;
   assign PSTRB   = tSTRB ;
   //-----------------------------------------------------
    reg        tACKsync, tACKsync0, tACKsync1;
    always @ (posedge HCLK or negedge HRESETn) begin
        if (HRESETn==0) begin
           tACKsync0 <= 1'b0;
           tACKsync1 <= 1'b0;
        end else begin
           tACKsync0 <= tACK;
           tACKsync1 <= tACKsync0;
        end
    end
    always @ ( * ) begin
        case (CLOCK_RATIO)
        2'b00: tACKsync = tACK;
        2'b01: tACKsync = tACKsync1;
        2'b10: tACKsync = tACKsync1;
        2'b11: tACKsync = tACKsync1;
        endcase
    end
   //-----------------------------------------------------
   reg [2:0] state;
   localparam STH_IDLE   =  'h0,
              STH_WRITE0 =  'h1,
              STH_WRITE1 =  'h2,
              STH_READ0  =  'h3,
              STH_WAIT   =  'h4;
   //-----------------------------------------------------
   // AHB bus wrapper
   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRDATA    <= 32'b0;
           HRESP     <=  2'b00; //`HRESP_OKAY;
           HREADYout <=  1'b1;
           tADDR     <= 32'h0;
           tWDATA    <= 32'h0;
           tWRITE    <=  1'b0;
           tPROT     <=  3'h0;
           tSTRB     <=  4'hF;
           tREQ      <=  1'b0;
           state     <= STH_IDLE;
       end else begin // if (HRESETn==0) begin
           case (state)
           STH_IDLE: begin
                if (HSEL && HREADYin) begin
                   case (HTRANS)
                   //`HTRANS_IDLE, `HTRANS_BUSY: begin
                   2'b00, 2'b01: begin
                          HREADYout <= 1'b1;
                          HRESP     <= 2'b00; //`HRESP_OKAY;
                          state     <= STH_IDLE;
                   end // HTRANS_IDLE or HTRANS_BUSY
                   //`HTRANS_NONSEQ, `HTRANS_SEQ: begin
                   2'b10, 2'b11: begin
                              HREADYout <= 1'b0;
                              HRESP     <= 2'b00; //`HRESP_OKAY;
                              tADDR     <= HADDR[31:0];
                              tWRITE    <= HWRITE;
                              tPROT     <= {~HPROT[0],1'b1,HPROT[1]};
                              tSTRB     <= get_strb(HADDR[1:0],HSIZE);
                              if (HWRITE) begin
                                  state <= STH_WRITE0;
                              end else begin
                                  tREQ  <= 1'b1;
                                  state <= STH_READ0;
                              end
                   end // HTRANS_NONSEQ or HTRANS_SEQ
                   endcase // HTRANS
                end else begin// if (HSEL && HREADYin)
                    HREADYout <= 1'b1;
                    HRESP     <= 2'b00; //`HRESP_OKAY;
                end
                end // STH_IDLE
           STH_WRITE0: begin
                     tWDATA    <= HWDATA;
                     tREQ      <= 1'b1;
                     state     <= STH_WRITE1;
                end // STH_WRITE0
           STH_WRITE1: begin
                     if (tACKsync ) begin
                         tREQ      <= 1'b0;
                         HRESP     <= {1'b0,tERROR};
                         tADDR     <= 32'b0;
                         tWDATA    <= 32'b0;
                         tWRITE    <= 1'b0;
                         if (CLOCK_RATIO==2'b00) begin
                             HREADYout <= 1'b1;
                             state     <= STH_IDLE;
                         end else begin
                             state     <= STH_WAIT;
                         end
                     end
                end // STH_WRITE1
           STH_READ0: begin
                    if (tACKsync ) begin
                         tREQ      <= 1'b0;
                         HRDATA    <= tRDATA;
                         HRESP     <= {1'b0,tERROR};
                         if (CLOCK_RATIO==2'b00) begin
                             HREADYout <= 1'b1;
                             state     <= STH_IDLE;
                         end else begin
                             state     <= STH_WAIT;
                         end
                    end
                end // STH_READ0
           STH_WAIT: begin
                if (tACKsync==1'b0) begin
                    HREADYout <= 1'b1;
                    state     <= STH_IDLE;
                end
                end // STH_WAIT
           endcase // state
       end // if (HRESETn==0)
   end // always
   //-----------------------------------------------------
   reg         tREQsync, tREQsync0, tREQsync1;
   always @ (posedge PCLK or negedge PRESETn) begin
       if (PRESETn==0) begin
          tREQsync0 <= 1'b0;
          tREQsync1 <= 1'b0;
       end else begin
          tREQsync0 <= tREQ;
          tREQsync1 <= tREQsync0;
       end
   end
   always @ ( * ) begin
       case (CLOCK_RATIO)
       2'b00: tREQsync = tREQ;
       2'b01: tREQsync = tREQsync1;
       2'b10: tREQsync = tREQsync1;
       2'b11: tREQsync = tREQsync1;
       endcase
   end
   //-----------------------------------------------------
   reg [1:0] pstate;
   localparam STP_IDLE  = 2'h0,
              STP_SETUP = 2'h1,
              STP_GO    = 2'h2,
              STP_WAIT  = 2'h3;
   //-----------------------------------------------------
   always @ (posedge PCLK or negedge PRESETn) begin
       if (PRESETn==0) begin
           PSEL    <=  1'b0;
           PENABLE <=  1'b0;
           tACK    <=  1'b0;
           tRDATA  <= 32'b0;
           tERROR  <=  1'b0;
           pstate  <= STP_IDLE;
       end else begin
           case (pstate)
           STP_IDLE: begin
               if (tREQsync ) begin
                     PSEL    <= 1'b1;
                     pstate  <= STP_SETUP;
               end
               end // STP_IDLE
           STP_SETUP: begin
               PENABLE <= 1'b1;
               pstate  <= STP_GO;
               end // STP_SETUP
           STP_GO: begin
               if (PREADY) begin
                  PENABLE <= 1'b0;
                  PSEL    <= 1'b0;
                  tACK    <= 1'b1;
                  tRDATA  <= PRDATA;
                  tERROR  <= PSLVERR;
                  pstate  <= STP_WAIT;
               end
               end // STP_GO
           STP_WAIT: begin
               if (CLOCK_RATIO==2'b0) begin
                   tACK   <= 1'b0;
                   pstate <= STP_IDLE;
               end else begin
                  if (tREQsync==1'b0) begin
                      tACK   <= 1'b0;
                      pstate <= STP_IDLE;
                  end
               end
               end // STP_WAIT
           endcase
       end // if (PRESETn==0)
   end // always @ (posedge PCLK or negedge PRESETn) begin
   //-----------------------------------------------------
   function [3:0] get_strb;
       input [1:0] add;   // address offset
       input [2:0] size;  // transfer size
       reg   [3:0] be;
       begin
          case ({size,add})
              `ifdef ENDIAN_BIG
              5'b010_00: be = 4'b1111; // word
              5'b001_00: be = 4'b1100; // halfword
              5'b001_10: be = 4'b0011; // halfword
              5'b000_00: be = 4'b1000; // byte
              5'b000_01: be = 4'b0100; // byte
              5'b000_10: be = 4'b0010; // byte
              5'b000_11: be = 4'b0001; // byte
              `else // little-endian -- default
              5'b010_00: be = 4'b1111; // word
              5'b001_00: be = 4'b0011; // halfword
              5'b001_10: be = 4'b1100; // halfword
              5'b000_00: be = 4'b0001; // byte
              5'b000_01: be = 4'b0010; // byte
              5'b000_10: be = 4'b0100; // byte
              5'b000_11: be = 4'b1000; // byte
              `endif
              default: begin
                       be = 4'b0;
              `ifdef RIGOR
              // synopsys translate_off
              $display($time,, "%m ERROR: undefined combination of HSIZE(%x) and HADDR[1:0](%x)",
                                                  size, add);
              // synopsys translate_on
              `endif
                       end
          endcase
          get_strb = be;
       end
   endfunction
   //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2011.03.30: AMBA_APB3 or AMBA_APB4 added by Ando Ki.
// 2011.03.20: Starte by Ando Ki.
//--------------------------------------------------------
`endif
