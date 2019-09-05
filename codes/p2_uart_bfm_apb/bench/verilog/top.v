//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef CLK_FREQ
`define CLK_FREQ       50000000
`endif

module top ;
   //------------------------------------------------
   reg               PRESETn     = 1'b0;
   reg               PCLK        = 1'b0;
   wire              PSEL    ;
   wire  [31:0]      PADDR   ;
   wire              PENABLE ;
   wire              PWRITE  ;
   wire  [31:0]      PWDATA  ;
   wire  [31:0]      PRDATA  ;
   `ifdef AMBA3
   wire              PREADY  ;
   wire              PSLVERR ;
   `endif
   `ifdef AMBA4
   wire  [ 2:0]      PPROT   ;
   wire  [ 3:0]      PSTRB   ; // mind PWDATA[31:0]
   `endif
   //------------------------------------------------
   bfm_apb_s1
   u_bfm_apb_s1 (
         .PRESETn  (PRESETn)
       , .PCLK     (PCLK   )
       , .PSEL     (PSEL   )
       , .PADDR    (PADDR  )
       , .PENABLE  (PENABLE)
       , .PWRITE   (PWRITE )
       , .PWDATA   (PWDATA )
       , .PRDATA0  (PRDATA )
     `ifdef AMBA3
       , .PREADY   (PREADY )
       , .PSLVERR  (PSLVERR)
     `endif
     `ifdef AMBA4
       , .PPROT    (PPROT)
       , .PSTRB    (PSTRB)
     `endif
   );
   //-----------------------------------------------------
   wire srx, stx;
   uart_apb u_uart_apb (
         .PRESETn   (PRESETn  )
       , .PCLK      (PCLK     )
       , .PSEL      (PSEL     )
       , .PENABLE   (PENABLE  )
       , .PADDR     (PADDR    )
       , .PWRITE    (PWRITE   )
       , .PRDATA    (PRDATA   )
       , .PWDATA    (PWDATA   )
       , .interrupt (         ) // interrupt request (active-high)
       , .srx       (srx      ) // serial output
       , .stx       (stx      ) // serial input
   );
   //-----------------------------------------------------
   tty #(.BAUD_RATE(115200), .LOOPBACK(1))
   u_tty (
         .STX (srx)
       , .SRX (stx)
   );
   //-----------------------------------------------------
   localparam CLK_FREQ=`CLK_FREQ;
   localparam CLK_PERIOD_HALF=1000000000/(CLK_FREQ*2);
   //-----------------------------------------------------
   always #CLK_PERIOD_HALF PCLK <= ~PCLK;
   //-----------------------------------------------------
   real stamp_x, stamp_y, delta;
   initial begin
       PRESETn <= 1'b0;
       repeat (5) @ (posedge PCLK);
       `ifdef RIGOR
        @ (posedge PCLK);
        @ (posedge PCLK); stamp_x = $time;
        @ (posedge PCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge PCLK); $display("%m PCLK %f nsec %f Mhz", delta, 1000.0/delta);
       `endif
       repeat (5) @ (posedge PCLK);
       PRESETn <= 1'b1;
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
