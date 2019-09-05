//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------m
`timescale 1ns/1ns

module stimulus
     #(parameter WIDTH=32, CYCLES=50
               , HOLD=WIDTH, INTV=WIDTH*3)
(
       input   wire             rst_n
     , input   wire             clk
     , output  wire [WIDTH-1:0] req
     , input   wire [WIDTH-1:0] grt
);
    //---------------------------------------------
    wire [31:0] num_req[0:WIDTH-1];
    wire [31:0] num_grt[0:WIDTH-1];
    integer aa;
    //---------------------------------------------
    initial begin
         wait (rst_n==1'b0);
         wait (rst_n==1'b1);
         repeat (CYCLES) @ (posedge clk);
         if (top.u_check.errors>0) $display("%m error %d", top.u_check.errors);
         else                      $display("%m OK");
         $write("id  "); for (aa=0; aa<WIDTH; aa=aa+1) $write("[%04d]", aa); $write("\n");
         $write("req "); for (aa=0; aa<WIDTH; aa=aa+1) $write("[%04d]", num_req[aa]); $write("\n");
         $write("grt "); for (aa=0; aa<WIDTH; aa=aa+1) $write("[%04d]", num_grt[aa]); $write("\n");
         $finish(2);
    end
    //---------------------------------------------
    genvar idx;
    generate
    for (idx=0; idx<WIDTH; idx=idx+1) begin : blk
         stimulus_one #(.HOLD(WIDTH),.INTV(WIDTH*3))
         u_stim (
              .rst_n ( rst_n    )
             ,.clk   ( clk      )
             ,.req   ( req[idx] )
             ,.grt   ( grt[idx] )
         );
    end
    endgenerate
    //---------------------------------------------
    genvar idy;
    generate
    for (idy=0; idy<WIDTH; idy=idy+1) begin : blk_cnt
         count_rising
         u_grt (
              .rst_n ( rst_n        )
             ,.sig   ( req    [idy] )
             ,.num   ( num_req[idy] )
         );
         count_rising
         u_req (
              .rst_n ( rst_n        )
             ,.sig   ( grt    [idy] )
             ,.num   ( num_grt[idy] )
         );
    end
    endgenerate
    //---------------------------------------------
endmodule
//-------------------------------------------------------
module count_rising
(
       input  wire       rst_n
     , input  wire       sig
     , output reg [31:0] num=32'h0
);
     always @ (posedge sig) begin
          if (rst_n==1'b1) num = num + 1;
     end
endmodule
//-------------------------------------------------------
module stimulus_one
     #(parameter HOLD=32  // duration to keep 'req' 1 after getting 'grt'
               , INTV=32) // duration to the next 'req' after releasing 'req'
(
       input   wire  rst_n
     , input   wire  clk
     , output  reg   req=1'b0
     , input   wire  grt
);
    //---------------------------------------------
    reg [31:0] valA, valB;
    reg [31:0] delayA, delayB;
    //---------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
    if (rst_n==1'b0) begin
        req    = 1'b0;
        delayA =  'h0;
        delayB =  'h0;
    end else begin
        while (grt==1'b1) @ (posedge clk);
        req  = 1'b1;
        while (grt==1'b0) @ (posedge clk);
        valA = $random;
        delayA = valA%HOLD;
        repeat (delayA) @ (posedge clk);
        req  = 1'b0;
        valB = $random;
        delayB = valB%INTV;
        repeat (delayB) @ (posedge clk);
    end // if
    end // always
    //---------------------------------------------
endmodule
//-------------------------------------------------------
