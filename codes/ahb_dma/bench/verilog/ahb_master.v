//--------------------------------------------------------
// Copyright (c) 2004 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`timescale 1ns/1ns

module ahb_master
     #(parameter SADDR=32'h0000_0000)
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
   reg [31:0] data_burst_wr[0:1023];
   reg [31:0] data_burst_rd[0:1023];
   reg [31:0] rdata;
   integer    sadr, idx;
   integer    error;
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
       //---------------------------
       while (1) begin
          error = 0;
          for (sadr=SADDR; sadr<SADDR+32'h0000_0010; sadr=sadr+4) begin
               ahb_write(sadr, 4, sadr );
               ahb_read (sadr, 4, rdata);
               if (rdata!=sadr) begin
                   error = error+1;
                   $display($time,,"%m ERROR");
               end
          end
          if (error==0) $display($time,,"%m single OK");
          error = 0;
          for (sadr=SADDR; sadr<SADDR+32'h0000_0040; sadr=sadr+4*8) begin
               for (idx=0; idx<8; idx=idx+1) begin
                    data_burst_wr[idx] = sadr;
               end
               ahb_write_burst(sadr, 8);
               ahb_read_burst (sadr, 8);
               for (idx=0; idx<8; idx=idx+1) begin
                    if (data_burst_rd[idx]!=data_burst_wr[idx]) begin
                       error = error+1;
                       $display($time,,"%m ERROR");
                    end
               end
          end
          if (error==0) $display($time,,"%m burst OK");
       end
       //---------------------------
       repeat (20) @ (posedge HCLK);
       $finish(2);
   end
   //---------------------------------------------------------
   `include "ahb_tasks.v"
endmodule
//--------------------------------------------------------
