//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
`include "stimulus.v"
`include "check.v"
`timescale 1ns/1ns

module top;
  //-----------------------------------------------------
  `ifndef CYCLES
   localparam CYCLES=50;
  `else
   localparam CYCLES=`CYCLES;
  `endif
  //-----------------------------------------------------
  `ifndef WIDTH
  localparam WIDTH=32;
  `else
  localparam WIDTH=`WIDTH;
  `endif
  localparam BITW=log2(WIDTH);
  //-----------------------------------------------------
  `ifndef HOLD
  localparam HOLD=WIDTH;
  `else
  localparam HOLD=`HOLD;
  `endif
  //-----------------------------------------------------
  `ifndef INTV
  localparam INTV=WIDTH*3;
  `else
  localparam INTV=`INTV;
  `endif
  //-----------------------------------------------------
  reg  clk   = 1'b0; always  #10 clk   <= ~clk;
  reg  rst_n = 1'b0; initial #23 rst_n <= 1'b1;
  //----------------------------------------
  wire [WIDTH-1:0] #(1) req;
  wire [WIDTH-1:0] #(1) grt, pre_grt;
  wire                  vld, pre_vld;
  wire [BITW-1 :0] #(1) id , pre_id ;
  //----------------------------------------
  stimulus #(.WIDTH(WIDTH),.CYCLES(CYCLES)
            ,.HOLD (HOLD),.INTV(INTV))
  u_stimulus (
        .rst_n   ( rst_n )
       ,.clk     ( clk   )
       ,.req     ( req   )
       ,.grt     ( grt   )
  );
  //----------------------------------------
  arbiter #(.WIDTH(WIDTH))
  u_arbiter (
        .rst_n  ( rst_n    )
       ,.clk    ( clk      )
       ,.req    ( req      )
       ,.grt    ( grt      )
       ,.id     ( {vld,id} )
       ,.pre_grt( pre_grt  )
       ,.pre_id ( {pre_vld,pre_id} )
  );
  //----------------------------------------
  check #(.WIDTH(WIDTH))
  u_check (
        .rst_n  ( rst_n   )
       ,.clk    ( clk     )
       ,.req    ( req     )
       ,.grt    ( grt     )
       ,.id     ( {vld,id})
       ,.pre_grt( pre_grt )
       ,.pre_id ( {pre_vld,pre_id} )
  );
  //--------------------------------------------------
  `ifdef VCD
  initial begin
          $dumpfile("wave.vcd"); //$dumplimit(100000);
          $dumpvars(0);
  end
  `endif
   //-----------------------------------------------------
   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2
endmodule
//-------------------------------------------------------
// Revision history
//
// 2015.07.10: Re-written by Ando Ki (adki@dynalith.com)
//-------------------------------------------------------
