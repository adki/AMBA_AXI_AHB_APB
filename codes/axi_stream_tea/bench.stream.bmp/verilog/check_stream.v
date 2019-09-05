//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
`timescale 1ns/1ns

module check_stream
     #(parameter STREAM_WIDTH_DATA=64
               , STREAM_WIDTH_DS=(STREAM_WIDTH_DATA/8)
               , STREAM_WIDTH_TID=8
               , STREAM_WIDTH_TDEST=3
               , STREAM_WIDTH_TUSER=1
       )
(
       input   wire                           ARESETn
     , input   wire                           ACLK
     //--------------------------------------------------
     , input   wire                           en_S_TREADY
     , input   wire                           en_S_TVALID
     , input   wire  [STREAM_WIDTH_DATA-1:0]  en_S_TDATA
     , input   wire  [STREAM_WIDTH_DS-1:0]    en_S_TSTRB
     , input   wire  [STREAM_WIDTH_DS-1:0]    en_S_TKEEP
     , input   wire                           en_S_TLAST
     , input   wire  [STREAM_WIDTH_TID-1:0]   en_S_TID
     , input   wire  [STREAM_WIDTH_TDEST-1:0] en_S_TDEST
     `ifdef AMBA_AXI_TUSER
     , input   wire  [STREAM_WIDTH_TUSER-1:0] en_S_TUSER
     `endif
     //----------------------------------------------------
     , input   wire                           de_S_TREADY
     , input   wire                           de_S_TVALID
     , input   wire  [STREAM_WIDTH_DATA-1:0]  de_S_TDATA
     , input   wire  [STREAM_WIDTH_DS-1:0]    de_S_TSTRB
     , input   wire  [STREAM_WIDTH_DS-1:0]    de_S_TKEEP
     , input   wire                           de_S_TLAST
     , input   wire  [STREAM_WIDTH_TID-1:0]   de_S_TID
     , input   wire  [STREAM_WIDTH_TDEST-1:0] de_S_TDEST
     `ifdef AMBA_AXI_TUSER
     , input   wire  [STREAM_WIDTH_TUSER-1:0] de_S_TUSER
     `endif
     //----------------------------------------------------
);
    //---------------------------------------------
    reg [63:0]  r_textI[0:127];
    reg [63:0]  r_textO;
    integer     idx, idy;
    //---------------------------------------------
    always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             r_textI[0] <= 64'b0;
             r_textI[1] <= 64'b0;
             idx        <= 0;
         end else begin
             if (en_S_TREADY&en_S_TVALID) begin
                 r_textI[idx] <= en_S_TDATA;
                 idx <= (idx+1)%128;
             end
         end
    end
    //---------------------------------------------
    always @ (posedge ACLK or negedge ARESETn) begin
         if (ARESETn==1'b0) begin
             r_textO <= 64'b0;
             idy     <= 0;
         end else begin
             if (de_S_TVALID&de_S_TREADY) begin
                 if (r_textI[idy]!=de_S_TDATA) begin
$display("%4d Error: %4d cryption check in=0x%x out=0x%x",
          $time, idy, r_textI[63], de_S_TDATA);
                 end else begin
`ifdef VERBOSE
$display("%4d OK: %4d   decryption after encryption check", $time, idy);
`endif
                 end
                 idy = (idy+1)%128;
             end
         end
    end
endmodule
