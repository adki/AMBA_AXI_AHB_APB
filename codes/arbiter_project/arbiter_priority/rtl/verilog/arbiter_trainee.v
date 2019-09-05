//------------------------------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All rights reserved by Ando Ki.
//
// adki@dynalith.com
//------------------------------------------------------------------------------
// arbiter.v
//------------------------------------------------------------------------------
// VERSION = 2015.09.08.
//------------------------------------------------------------------------------
// req[0] = high priority
//------------------------------------------------------------------------------

module arbiter
     #(parameter WIDTH=5, BITW=log2(WIDTH))
(
       input  wire              rst_n
     , input  wire              clk
     , input  wire  [WIDTH-1:0] req
     , output reg   [WIDTH-1:0] grt={WIDTH{1'b0}}
     , output reg   [BITW   :0] id={BITW+1{1'b0}} // msb indicates validity
     , output reg   [WIDTH-1:0] pre_grt // one-cyle advanced
     , output reg   [BITW   :0] pre_id // one-cyle advanced
);
    //--------------------------------------------------------------------------
    make your own priority-based arbiter here
    //--------------------------------------------------------------------------
    function integer log2;
       input integer number;
    begin
       log2=0;
       while(2**log2<number) log2=log2+1;
    end
    endfunction // log2
endmodule
//------------------------------------------------------------------------------
// Revision history
//
// 2015.09.08: Started by Ando Ki (adki@dynalith.com)
//------------------------------------------------------------------------------
