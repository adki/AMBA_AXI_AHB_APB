//--------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`timescale 1ns/1ns

module tea_encryptor_core
     #(parameter DELTA=32'h9E3779B9)
(
       input                resetn
     , input                clk
     , input   wire [127:0] key
     , input   wire [ 63:0] textI
     , input   wire         textI_vld
     , output  wire [ 63:0] textO
     , output  wire         textO_vld
);
    //-----------------------------------------------------
    wire [31:0] key0 = key[ 31: 0];
    wire [31:0] key1 = key[ 63:32];
    wire [31:0] key2 = key[ 95:64];
    wire [31:0] key3 = key[127:96];
    reg  [63:0] vld;
    reg  [31:0] sum   [0:63];
    reg  [31:0] textOy[0:63];
    reg  [31:0] textOz[0:63];
    integer idx;
    //-----------------------------------------------------
    always @ (posedge clk or negedge resetn) begin
    if (~resetn) begin
        for (idx=0; idx<64; idx=idx+1) begin
             vld   [idx] <=  1'b0;
             textOy[idx] <= 32'h0;
             textOz[idx] <= 32'h0;
             sum   [idx] <= 32'h0;
        end
    end else begin
        vld[0]    <= textI_vld;
        textOy[0] <= textI[31:0]
                    + ( ((textI[63:32]<<4)+key0)
                      ^ ( textI[63:32]+DELTA)
                      ^ ((textI[63:32]>>5)+key1));
        textOz[0] <= textI[63:32];
        sum   [0] <= DELTA;
        for (idx=1; idx<64; idx=idx+1) begin
             vld[idx] <= vld[idx-1];
             if (idx[0]==1'b1) begin
                 textOz[idx] <= textOz[idx-1]
                              + ( ((textOy[idx-1]<<4)+key2)
                                ^ ( textOy[idx-1]+sum[idx-1])
                                ^ ((textOy[idx-1] >> 5)+key3));
                 textOy[idx] <= textOy[idx-1];
                 sum   [idx] <= sum[idx-1]+DELTA;
             end else begin
                 textOz[idx] <= textOz[idx-1];
                 textOy[idx] <= textOy[idx-1]
                             + ( ((textOz[idx-1]<<4)+key0)
                               ^ ( textOz[idx-1]+sum[idx-1])
                               ^ ((textOz[idx-1]>>5)+key1));
                 sum   [idx] <= sum[idx-1];
             end
        end
    end // if
    end // always
    //-----------------------------------------------------
    assign textO_vld = vld[63];
    assign textO     = {textOz[63],textOy[63]};
    //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2013.07.29: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
