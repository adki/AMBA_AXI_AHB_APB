//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef CLK_FREQ
`define CLK_FREQ       50000000
`endif
`ifndef MEM_DELAY
`define MEM_DELAY 0
`endif
`ifndef SIZE_IN_BYTES
`define SIZE_IN_BYTES 1024
`endif

module top ;
   //------------------------------------------------
   localparam SIZE_IN_BYTES=`SIZE_IN_BYTES // memory size
            , DELAY        =`MEM_DELAY; // access delay if any for AMBA3/4
   //------------------------------------------------
   reg         HRESETn= 1'b0;
   reg         HCLK   = 1'b0;
   wire        HBUSREQ;
   wire        HGRANT = HBUSREQ; // no arbiter
   wire [31:0] HADDR  ;
   wire [3:0]  HPROT  ;
   wire        HLOCK  ;
   wire [1:0]  HTRANS ;
   wire        HWRITE ;
   wire [2:0]  HSIZE  ;
   wire [2:0]  HBURST ;
   wire [31:0] HWDATA ;
   wire [31:0] HRDATA ;
   wire [1:0]  HRESP  ;
   wire        HREADY ;
   wire        HSEL   = HTRANS[1]; // no address decoder
   //------------------------------------------------
   bfm_ahb #(.START_ADDR(0),.DEPTH_IN_BYTES(32'h100))
   u_bfm_ahb (
         .HRESETn (HRESETn)
       , .HCLK    (HCLK   )
       , .HBUSREQ (HBUSREQ)
       , .HGRANT  (HGRANT )
       , .HADDR   (HADDR  )
       , .HPROT   (HPROT  )
       , .HLOCK   (HLOCK  )
       , .HTRANS  (HTRANS )
       , .HWRITE  (HWRITE )
       , .HSIZE   (HSIZE  )
       , .HBURST  (HBURST )
       , .HWDATA  (HWDATA )
       , .HRDATA  (HRDATA )
       , .HRESP   (HRESP  )
       , .HREADY  (HREADY )
       , .IRQ     (1'b0   )
   );
   //----------------------------------------------------
   mem_ahb #(.SIZE_IN_BYTES(SIZE_IN_BYTES),.DELAY(DELAY))
   u_mem_ahb (
         .HRESETn   (HRESETn)
       , .HCLK      (HCLK   )
       , .HSEL      (HSEL   )
       , .HADDR     (HADDR  )
       , .HTRANS    (HTRANS )
       , .HWRITE    (HWRITE )
       , .HSIZE     (HSIZE  )
       , .HBURST    (HBURST )
       , .HWDATA    (HWDATA )
       , .HRDATA    (HRDATA )
       , .HRESP     (HRESP  )
       , .HREADYin  (HREADY )
       , .HREADYout (HREADY )
   );
   //-----------------------------------------------------
   localparam CLK_FREQ=`CLK_FREQ;
   localparam CLK_PERIOD_HALF=1000000000/(CLK_FREQ*2);
   //-----------------------------------------------------
   always #CLK_PERIOD_HALF HCLK <= ~HCLK;
   //-----------------------------------------------------
   real stamp_x, stamp_y, delta;
   initial begin
       HRESETn <= 1'b0;
       repeat (5) @ (posedge HCLK);
       `ifdef RIGOR
        @ (posedge HCLK);
        @ (posedge HCLK); stamp_x = $time;
        @ (posedge HCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge HCLK); $display("%m HCLK %f nsec %f Mhz", delta, 1000.0/delta);
       `endif
       repeat (5) @ (posedge HCLK);
       HRESETn <= 1'b1;
   end
   //------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0);
   end
   `endif
endmodule
//--------------------------------------------------------
// Revision history:
//
// 2013.01.31.: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
