//--------------------------------------------------------
// Copyright (c) 2004 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`timescale 1ns/1ns

module ahb_test
(
      input  wire         HRESETn
    , input  wire         HCLK
    , output reg          HBUSREQ
    , input  wire         HGRANT
    , output reg  [31:0]  HADDR
    , output reg  [ 1:0]  HTRANS
    , output reg          HWRITE
    , output reg  [ 2:0]  HSIZE
    , output reg  [ 2:0]  HBURST
    , output reg  [31:0]  HWDATA
    , input  wire [31:0]  HRDATA
    , input  wire [ 1:0]  HRESP
    , input  wire         HREADY
);
   //---------------------------------------------------------
   localparam CSRA_NAME0   = 32'hA000_0000 + 8'h00,
              CSRA_NAME1   = 32'hA000_0000 + 8'h04,
              CSRA_NAME2   = 32'hA000_0000 + 8'h08,
              CSRA_NAME3   = 32'hA000_0000 + 8'h0C,
              CSRA_COMP0   = 32'hA000_0000 + 8'h10,
              CSRA_COMP1   = 32'hA000_0000 + 8'h14,
              CSRA_COMP2   = 32'hA000_0000 + 8'h18,
              CSRA_COMP3   = 32'hA000_0000 + 8'h1C,
              CSRA_VERSION = 32'hA000_0000 + 8'h20,
              CSRA_CONTROL = 32'hA000_0000 + 8'h30,
              CSRA_NUM     = 32'hA000_0000 + 8'h40,
              CSRA_SOURCE  = 32'hA000_0000 + 8'h44,
              CSRA_DEST    = 32'hA000_0000 + 8'h48;
   //---------------------------------------------------------
   reg [31:0] data_burst_wr[0:1023];
   reg [31:0] data_burst_rd[0:1023];
   reg [31:0] rdata;
   integer    sadr, idx;
   //---------------------------------------------------------
   initial begin
       HBUSREQ= 0;
       HADDR  = 0;
       HTRANS = 0;
       HWRITE = 0;
       HSIZE  = 0;
       HBURST = 0;
       HWDATA = 0;
       wait  (HRESETn==1'b0);
       wait  (HRESETn==1'b1);
       repeat (20) @ (posedge HCLK);
       csr_test;
       //---------------------------
       // single cases
if (1) begin
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0000, 32'h1000_1000, 16'h10, 5'h1, 8'h0);
end
       //---------------------------
       // burst cases
if (1) begin
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0000, 32'h1000_1000, 16'h10, 5'h4, 8'h1);
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0000, 32'h1000_1000, 16'h20, 5'h8, 8'h2);
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0000, 32'h1000_1000, 16'h40, 5'h10, 8'h3);
end
       //---------------------------
       // mis-aligned
if (1) begin
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0000, 32'h1000_1000, 16'h13, 5'h4, 8'h1);
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0001, 32'h1000_1001, 16'h13, 5'h4, 8'h2);
       repeat (20) @ (posedge HCLK);
       one_dma_test(32'h1000_0001, 32'h1000_1001, 16'h15, 5'h4, 8'h3);
end
       //---------------------------
       repeat (20) @ (posedge HCLK);
       $finish(2);
   end
   //---------------------------------------------------------
   // fill, DMA, test
   task one_dma_test;
   input [31:0] src;
   input [31:0] dst;
   input [15:0] bnum;
   input [ 4:0] burst; // 1, 4, 8, 16
   input [ 7:0] offset;
   reg [31:0] ad, dat, exp;
   reg [ 3:0] be;
   integer err;
   begin
       dat = 32'h0403_0201 + {4{offset}};
       for (ad=src; ad<(src+bnum); ad=ad+1) begin
            be = (ad[1:0]==0) ? 4'b0001
               : (ad[1:0]==1) ? 4'b0010
               : (ad[1:0]==2) ? 4'b0100
               :                4'b1000;
            u_mem.write(ad, dat, be);
            if (ad[1:0]==0) dat[ 7: 0] = dat[ 7: 0] + 4;
            if (ad[1:0]==1) dat[15: 8] = dat[15: 8] + 4;
            if (ad[1:0]==2) dat[23:16] = dat[23:16] + 4;
            if (ad[1:0]==3) dat[31:24] = dat[31:24] + 4;
       end
       one_dma(src, dst, bnum, burst);
       err=0;
       exp = 32'h0403_0201 + {4{offset}};
       for (ad=dst; ad<(dst+bnum); ad=ad+1) begin
            u_mem.read(ad, dat);
//$display($time,,"%m exp=0x%08X dat=0x%08X", exp, dat);
            if (ad[1:0]==0) begin 
                 if (dat[ 7: 0]!==exp[ 7: 0]) begin err=err+1;
                 end 
            end
            if (ad[1:0]==1) begin 
                 if (dat[15: 8]!==exp[15: 8]) begin err=err+1; 
                 end
            end
            if (ad[1:0]==2) begin 
                 if (dat[23:16]!==exp[23:16]) begin err=err+1; 
                 end
            end
            if (ad[1:0]==3) begin 
                 if (dat[31:24]!==exp[31:24]) begin err=err+1; 
            end
            end
            if (ad[1:0]==0) exp[ 7: 0] = exp[ 7: 0] + 4;
            if (ad[1:0]==1) exp[15: 8] = exp[15: 8] + 4;
            if (ad[1:0]==2) exp[23:16] = exp[23:16] + 4;
            if (ad[1:0]==3) exp[31:24] = exp[31:24] + 4;
       end
       if (err>0) $display($time,,"%m mismatch %d", err);
       else       $display($time,,"%m OK");
   end
   endtask
   //---------------------------------------------------------
   task one_dma;
   input [31:0] src;
   input [31:0] dst;
   input [15:0] bnum;
   input [ 4:0] burst; // 1, 4, 8, 16
   reg [31:0] value;
   begin
     value = 32'h8000_0001; // enable
     ahb_write(CSRA_CONTROL, 4, value);
     ahb_write(CSRA_SOURCE, 4, src);
     ahb_write(CSRA_DEST, 4, dst);
     value = bnum | (burst<<16) | (1<<31);
     ahb_write(CSRA_NUM, 4, value);
     while (value&32'h8000_0000) begin
        ahb_read(CSRA_NUM, 4, value);
     end
   end
   endtask
   //---------------------------------------------------------
   task csr_test;
   reg [31:0] value;
   begin
     ahb_read(CSRA_NAME0  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_NAME1  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_NAME2  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_NAME3  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_COMP0  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_COMP1  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_COMP2  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_COMP3  , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_VERSION, 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_CONTROL, 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_NUM    , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_SOURCE , 4, value); $display($time,,"%m 0x%08X", value);
     ahb_read(CSRA_DEST   , 4, value); $display($time,,"%m 0x%08X", value);
   end
   endtask
   //---------------------------------------------------------
   `include "ahb_tasks.v"
endmodule
//--------------------------------------------------------
