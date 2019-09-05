//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef HCLK_FREQ
`define HCLK_FREQ       50000000
`endif
`ifndef PCLK_FREQ
`define PCLK_FREQ       50000000
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
   //------------------------------------------------
   localparam P_NUM = 3;
   reg         PCLK      = 1'b0;
   wire        PRESETn   = HRESETn;
   wire        PENABLE ;
   wire [31:0] PADDR   ;
   wire        PWRITE  ;
   wire [31:0] PWDATA  ;
   wire [31:0] PRDATA0 ;
   wire [31:0] PRDATA1 ;
   wire [31:0] PRDATA2 ;
   wire [P_NUM-1:0]       PSEL   ;
   `ifdef AMBA_APB3
   wire [P_NUM-1:0]       PREADY ;
   wire [P_NUM-1:0]       PSLVERR;
   `endif
   `ifdef AMBA_APB4
   wire [ 2:0] PPROT   ;
   wire [ 3:0] PSTRB   ;
   `endif
   wire [32*P_NUM-1:0] PRDATA;
   assign PRDATA0 = PRDATA[31: 0];
   assign PRDATA1 = PRDATA[63:32];
   assign PRDATA2 = PRDATA[95:64];
   //------------------------------------------------
   ahb_to_apb_s3 #(.P_PSEL0_START(16'h0000),.P_PSEL0_SIZE(16'h0010)
                  ,.P_PSEL1_START(16'h1000),.P_PSEL1_SIZE(16'h0010)
                  ,.P_PSEL2_START(16'h2000),.P_PSEL2_SIZE(16'h0010))
   u_ahb_to_apb (
         .HRESETn        (HRESETn  )
       , .HCLK           (HCLK     )
       , .HSEL           (HSEL     )
       , .HADDR          (HADDR    )
       , .HTRANS         (HTRANS   )
       , .HPROT          (HPROT    )
       , .HWRITE         (HWRITE   )
       , .HSIZE          (HSIZE    )
       , .HBURST         (HBURST   )
       , .HWDATA         (HWDATA   )
       , .HRDATA         (HRDATA   )
       , .HRESP          (HRESP    )
       , .HREADYin       (HREADY   )
       , .HREADYout      (HREADY   )
       , .PCLK           (PCLK     )
       , .PRESETn        (PRESETn  )
       , .PENABLE        (PENABLE  )
       , .PADDR          (PADDR    )
       , .PWRITE         (PWRITE   )
       , .PWDATA         (PWDATA   )
       , .PSEL0          (PSEL[0]  )
       , .PRDATA0        (PRDATA0  )
       `ifdef AMBA_APB3
       , .PREADY0        (PREADY[0]     )
       , .PSLVERR0       (PSLVERR[0]    )
       `endif
       , .PSEL1          (PSEL[1]      )
       , .PRDATA1        (PRDATA1    )
       `ifdef AMBA_APB3
       , .PREADY1        (PREADY[1])
       , .PSLVERR1       (PSLVERR[1])
       `endif
       , .PSEL2          (PSEL[2]   )
       , .PRDATA2        (PRDATA2   )
       `ifdef AMBA_APB3
       , .PREADY2        (PREADY[2] )
       , .PSLVERR2       (PSLVERR[2])
       `endif
       `ifdef AMBA_APB4
       , .PPROT         (PPROT    )
       , .PSTRB         (PSTRB    )
       `endif
       , .CLOCK_RATIO   (2'b0) // 0=1:1, 3=async
   );
   //----------------------------------------------------
   generate
   genvar pn;
   for (pn=0; pn<P_NUM; pn=pn+1) begin : P_BLOCK
        mem_apb #(.SIZE_IN_BYTES(1024)  // memory depth
                 ,.DELAY        (DELAY)) // access delay if any for AMBA3/4
        u_mem_apb (
              .PRESETn   (PRESETn      )
            , .PCLK      (PCLK         )
            , .PSEL      (PSEL     [pn])
            , .PADDR     (PADDR        )
            , .PENABLE   (PENABLE      )
            , .PWRITE    (PWRITE       )
            , .PWDATA    (PWDATA       )
            , .PRDATA    (PRDATA   [32*(pn+1)-1:32*pn])
            `ifdef AMBA3
            , .PREADY    (PREADY   [pn])
            , .PSLVERR   (PSLVERR  [pn])
            `endif
            `ifdef AMBA4
            , .PPROT     (PPROT        )
            , .PSTRB     (PSTRB        )
            `endif
        );
   end
   endgenerate
   //-----------------------------------------------------
   localparam HCLK_FREQ=`HCLK_FREQ;
   localparam HCLK_PERIOD_HALF=1000000000/(HCLK_FREQ*2);
   //-----------------------------------------------------
   always #HCLK_PERIOD_HALF HCLK <= ~HCLK;
   //-----------------------------------------------------
   localparam PCLK_FREQ=`PCLK_FREQ;
   localparam PCLK_PERIOD_HALF=1000000000/(PCLK_FREQ*2);
   //-----------------------------------------------------
   always #PCLK_PERIOD_HALF PCLK <= ~PCLK;
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
        @ (posedge PCLK);
        @ (posedge PCLK); stamp_x = $time;
        @ (posedge PCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge PCLK); $display("%m PCLK %f nsec %f Mhz", delta, 1000.0/delta);
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
