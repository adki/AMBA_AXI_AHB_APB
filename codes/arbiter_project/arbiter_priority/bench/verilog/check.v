//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
`timescale 1ns/1ns

module check
     #(parameter WIDTH=32, BITW=log2(WIDTH))
(
       input  wire             rst_n
     , input  wire             clk
     , input  wire [WIDTH-1:0] req
     , input  wire [WIDTH-1:0] grt
     , input  wire [BITW   :0] id
     , input  wire [WIDTH-1:0] pre_grt
     , input  wire [BITW   :0] pre_id
);
    //---------------------------------------------
    integer errors=0;
    integer bit_grt=0;
    reg     err_grt=1'b0;
    reg [WIDTH-1:0] req_dly;
    //---------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
    if (rst_n==1'b0) begin
    end else begin
        if (bit_grt>1) $display("%04d %m error %d grants", $time, bit_grt);
        if (err_grt)   $display("%04d %m error un-expected grant %X", $time, grt);
    end // if
    end // always
    //---------------------------------------------
    integer idx;
    always @ (posedge clk) begin
         bit_grt = 0;
         for (idx=0; idx<WIDTH; idx=idx+1) begin
              if (grt[idx]) begin
                  bit_grt = bit_grt + 1;
              end
         end
         if (bit_grt>1) errors = errors + 1;
    end
    //---------------------------------------------
    integer idy;
    always @ (posedge clk) begin
         req_dly <= req;
         for (idy=0; idy<WIDTH; idy=idy+1) begin
              if (grt[idy]) begin
                  if (req[idy]|req_dly[idy]) err_grt = 1'b0;
                  else err_grt = 1'b1;
              end
         end
    end
    //---------------------------------------------
    reg  [WIDTH-1:0] pre_grt_dly;
    reg  [BITW   :0] pre_id_dly;
    reg              rst_n_dly;
    //---------------------------------------------
    integer idz;
    always @ (posedge clk) begin
         pre_grt_dly <= pre_grt;
         pre_id_dly  <= pre_id ;
         rst_n_dly   <= rst_n  ;
         if ((rst_n==1'b1)&&(rst_n_dly==1'b1)) begin
            if (grt!==pre_grt_dly) $display("%04d pre grt error", $time);
            if (id !==pre_id_dly ) $display("%04d pre id error", $time);
         end // if
    end // always
    //---------------------------------------------
    function integer log2;
       input integer number;
       begin
          log2=0;
          while(2**log2<number) begin
             log2=log2+1;
          end
       end
    endfunction // log2
    //---------------------------------------------
endmodule
//-------------------------------------------------------
