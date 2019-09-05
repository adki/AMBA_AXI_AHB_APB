//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
`timescale 1ns/1ns

module check(
       input  wire         resetn
     , input  wire         clk
     , input  wire [63:0]  textI
     , input  wire         textI_vld
     , input  wire [63:0]  textO
     , input  wire         textO_vld
);
    //---------------------------------------------
    reg [63:0]  r_textI[0:127];
    reg [63:0]  r_textO;
    integer     idx, idy;
    //---------------------------------------------
    always @ (posedge clk or negedge resetn) begin
         if (resetn==1'b0) begin
             r_textI[0] <= 64'b0;
             r_textI[1] <= 64'b0;
             idx        <= 0;
         end else begin
             if (textI_vld) begin
                 r_textI[idx] <= textI;
                 idx <= (idx+1)%128;
             end
         end
    end
    //---------------------------------------------
    always @ (posedge clk or negedge resetn) begin
         if (resetn==1'b0) begin
             r_textO <= 64'b0;
             idy        <= 0;
         end else begin
             if (textO_vld) begin
                 if (r_textI[idy]!=textO) begin
$display("%4d Error: %d cryption check in=0x%x out=0x%x",
          $time, idy, r_textI[63], textO);
                 end else begin
$display("%4d OK: %4d   decryption after encryption check", $time, idy);
                 end
                 idy = (idy+1)%128;
             end
         end
    end
endmodule
