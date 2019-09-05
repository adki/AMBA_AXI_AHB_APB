//********************************************************
// Copyright (c) 2007-2009 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//********************************************************
// VERSION: 2010.01.05.
//********************************************************
// Address decoder for AMBA AHB
//********************************************************
`timescale 1ns/1ns

module ahb_decoder_s3 #(parameter P_NUM         = 3, // how many slaves
                                  P_ADDR_START0 = 'h0000, P_ADDR_SIZE0  = 'h0010,
                                  P_ADDR_START1 = 'h0010, P_ADDR_SIZE1  = 'h0010,
                                  P_ADDR_START2 = 'h0020, P_ADDR_SIZE2  = 'h0010)
(
       input   wire [31:0] HADDR
     , output  wire        HSELd // default slave
     , output  wire        HSEL0
     , output  wire        HSEL1
     , output  wire        HSEL2
     , input   wire        REMAP
);
   /*********************************************************/
   localparam P_ADDR_END0 = P_ADDR_START0 + P_ADDR_SIZE0 - 1;
   localparam P_ADDR_END1 = P_ADDR_START1 + P_ADDR_SIZE1 - 1;
   localparam P_ADDR_END2 = P_ADDR_START2 + P_ADDR_SIZE2 - 1;
   /*********************************************************/
   reg ihseld, ihsel0, ihsel1, ihsel2;
   assign HSELd = ihseld;
   assign HSEL0 = (REMAP) ? ihsel1 : ihsel0;
   assign HSEL1 = (REMAP) ? ihsel0 : ihsel1;
   assign HSEL2 = ihsel2;
   /*********************************************************/
   wire [15:0] thaddr = HADDR[31:16];
   always @ (thaddr) begin // must be blocking assignment
      if ((P_NUM>0)&&(thaddr>=P_ADDR_START0)&&(thaddr<=P_ADDR_END0)) ihsel0 <= 1'b1;
      else                                                           ihsel0 <= 1'b0;
      if ((P_NUM>1)&&(thaddr>=P_ADDR_START1)&&(thaddr<=P_ADDR_END1)) ihsel1 <= 1'b1;
      else                                                           ihsel1 <= 1'b0;
      if ((P_NUM>2)&&(thaddr>=P_ADDR_START2)&&(thaddr<=P_ADDR_END2)) ihsel2 <= 1'b1;
      else                                                           ihsel2 <= 1'b0;

      if (((P_NUM>0)&&(thaddr>=P_ADDR_START0)&&(thaddr<=P_ADDR_END0))||
          ((P_NUM>1)&&(thaddr>=P_ADDR_START1)&&(thaddr<=P_ADDR_END1))||
          ((P_NUM>2)&&(thaddr>=P_ADDR_START2)&&(thaddr<=P_ADDR_END2))) ihseld <= 1'b0;
      else                                                             ihseld <= 1'b1;

   end // always

// synopsys translate_off
`ifdef RIGOR
   wire [P_NUM:0] _hsel = {HSEL2,HSEL1,HSEL0,HSELd};
   always @ (_hsel) begin // must be blocking assignment
      if ((_hsel!=4'b0001)&&(_hsel!=4'b0010)&&(_hsel!=4'b0100)&&
          (_hsel!=4'b1000)&&(_hsel!=4'b0000))
          $display($time,, "%m ERROR: more than one has been selected! 0x%x", _hsel);
   end // always
   always @ (REMAP) begin
          //$display($time,, "%m Info: REMAP changed from %d to %d.", ~REMAP, REMAP);
          if (REMAP==1'b0) begin
             if ((P_NUM>0)&&(P_ADDR_START0>=P_ADDR_END0)&&(REMAP==0))
                 $display("%m ERROR: address range for HSEL0: from 0x%x to 0x%x", P_ADDR_START0, P_ADDR_END0);
             if ((P_NUM>1)&&(P_ADDR_START1>=P_ADDR_END1)&&(REMAP==0))
                 $display("%m ERROR: address range for HSEL1: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
             if ((P_NUM>2)&&(P_ADDR_START2>=P_ADDR_END2)&&(REMAP==0))
                 $display("%m ERROR: address range for HSEL2: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
          end else begin
             if ((P_NUM>0)&&(P_ADDR_START1>=P_ADDR_END1)&&(REMAP==1))
                 $display("%m ERROR: address range for HSEL0: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
             if ((P_NUM>1)&&(P_ADDR_START0>=P_ADDR_END0)&&(REMAP==1))
                 $display("%m ERROR: address range for HSEL1: from 0x%x to 0x%x", P_ADDR_START0, P_ADDR_END0);
             if ((P_NUM>2)&&(P_ADDR_START2>=P_ADDR_END2)&&(REMAP==1))
                 $display("%m ERROR: address range for HSEL2: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
          end
   end
`endif
// synopsys translate_on
// synopsys translate_off
   initial begin
      if (REMAP==1'b0) begin
         if ((P_NUM>0)&&(P_ADDR_START0>=P_ADDR_END0)&&(REMAP==0))
             $display("%m ERROR: address range for HSEL0: from 0x%x to 0x%x", P_ADDR_START0, P_ADDR_END0);
         if ((P_NUM>1)&&(P_ADDR_START1>=P_ADDR_END1)&&(REMAP==0))
             $display("%m ERROR: address range for HSEL1: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
         if ((P_NUM>2)&&(P_ADDR_START2>=P_ADDR_END2)&&(REMAP==0))
             $display("%m ERROR: address range for HSEL2: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
      end else begin
         if ((P_NUM>0)&&(P_ADDR_START1>=P_ADDR_END1)&&(REMAP==1))
             $display("%m ERROR: address range for HSEL0: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
         if ((P_NUM>1)&&(P_ADDR_START0>=P_ADDR_END0)&&(REMAP==1))
             $display("%m ERROR: address range for HSEL1: from 0x%x to 0x%x", P_ADDR_START0, P_ADDR_END0);
         if ((P_NUM>2)&&(P_ADDR_START2>=P_ADDR_END2)&&(REMAP==1))
             $display("%m ERROR: address range for HSEL2: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
      end
   end // initial
   initial begin
       $display("Info: %m HSEL0: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START0, P_ADDR_END0);
       $display("Info: %m HSEL1: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START1, P_ADDR_END1);
       $display("Info: %m HSEL2: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START2, P_ADDR_END2);
   end // initial
// synopsys translate_on
endmodule
