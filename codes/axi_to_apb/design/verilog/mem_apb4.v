//--------------------------------------------------------
// Copyright (c) 2009-2011 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// VERSION: 2011.01.29.
//--------------------------------------------------------
// Simplified memory with AMBA APB
//--------------------------------------------------------

`timescale 1ns/1ns

module mem_apb4 #(parameter AW=32, DW=32, LEN=8, DS=DW/8)
(
       input  wire          PRESETn
     , input  wire          PCLK
     , input  wire          PSEL
     , input  wire          PENABLE
     , input  wire [AW-1:0] PADDR
     , input  wire          PWRITE
     , output reg  [DW-1:0] PRDATA
     , input  wire [DW-1:0] PWDATA
     , output wire          PREADY
     , output wire          PSLVERR
     , input  wire [DS-1:0] PSTRB
     , input  wire [ 2:0]   PPROT
);
   //-----------------------------------------------------
   assign PREADY  = 1'b1;
   assign PSLVERR = 1'b0;
   //-----------------------------------------------------
   localparam DEPTH = 1<<(LEN-2);
   reg  [DW-1:0] mem[0:DEPTH-1];
   wire [DW-1:0] val;
   reg  [ 7:0]   tmp[0:DS-1];
wire [ 7:0] a, b, c, d;
assign a = tmp[0];
assign b = tmp[1];
assign c = tmp[2];
assign d = tmp[3];
   //-----------------------------------------------------
   wire [LEN-3:0] TA = PADDR[LEN-1:2];
   //-----------------------------------------------------
   // write
   //             ____      ____      ____
   // PCLK    ___|    |____|    |____|    |_
   //         ____ ___________________ _____
   // PADDR   ____X__A________________X_____
   //         ____ ___________________ _____
   // PWDATA  ____X__DW_______________X_____
   //              ___________________
   // PWRITE  ____|                   |_____
   //              ___________________
   // PSEL    ____|                   |_____
   //                        _________
   // PENABLE ______________|         |_____
   //
   integer idx;
   always @ (posedge PCLK or negedge PRESETn) begin
        if (PRESETn==1'b0) begin
            for (idx=0; idx<DS; idx=idx+1) begin
                 tmp[idx] <= 'h0;
            end
        end else begin
             if (PSEL & ~PENABLE) begin
                 for (idx=0; idx<DS; idx=idx+1) begin
                      tmp[idx] <= (PSTRB[idx]) ? (PWDATA>>(8*idx))
                                               : (mem[TA]>>(8*idx));
                 end
             end
             if (PSEL &  PENABLE &  PWRITE) begin
                 mem[TA] <= val;
             end
        end
   end
   generate
   genvar xy;
   for (xy=0; xy<DS; xy=xy+1) begin : XYZ
        assign val[xy*8+7:xy*8] = tmp[xy];
   end
   endgenerate
   //-----------------------------------------------------
   // read
   //             ____      ____      ____
   // PCLK    ___|    |____|    |____|    |_
   //         ____ ___________________ _____
   // PADDR   ____X__A________________X_____
   //         ____           _________ _____
   // PRDATA  ____XXXXXXXXXXX__DR_____X_____
   //         ____                     _____
   // PWRITE  ____|___________________|_____
   //              ___________________
   // PSEL    ____|                   |_____
   //                        _________
   // PENABLE ______________|         |_____
   //
   always @ (posedge PCLK or negedge PRESETn) begin
        if (PRESETn==1'b0) begin
            PRDATA <= ~'h0;
        end else begin
            PRDATA <= mem[TA];
        end
   end
   //-----------------------------------------------------
   // synopsys translate_off
   integer i;
   initial begin
           for (i=0; i<DEPTH; i=i+1) begin
               mem[i] = ~32'h0;
           end
   end
   `ifdef RIGOR
   always @ (posedge PCLK or negedge PRESETn) begin
        if (PRESETn==1'b0) begin
        end else begin
             if (PSEL & PENABLE) begin
                 if (TA>=DEPTH) $display($time,,"%m: ERROR: out-of-bound 0x%x",
                                                 PADDR);
             end
        end
   end
   `endif
   // synopsys translate_on
   //----------------------------------------------------------
endmodule

//--------------------------------------------------------
// 2011.01.29: AMBA APB 4 by Ando Ki
// 2009.08.17: Creator: Ando Ki
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
