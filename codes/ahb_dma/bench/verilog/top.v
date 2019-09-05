//--------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// top.v
//--------------------------------------------------------
// VERSION = 2014.04.29.
//--------------------------------------------------------
// Macros
//--------------------------------------------------------
// Note:
//--------------------------------------------------------
`timescale 1ns/1ns

module top;
   //--------------------------------------------------------
   `ifdef VCD
   initial begin
         $display("VCD dump enable.");
         $dumpfile("wave.vcd");
         $dumpvars(0);
   end
   `endif
   //--------------------------------------------------------
   reg CLK50M = 1'b0;
   localparam CLK50_FREQ=50000000.0;
   localparam CLK50_PERIOD_HALF=1000000000.0/(CLK50_FREQ*2);
   always #CLK50_PERIOD_HALF CLK50M <= ~CLK50M;
   //--------------------------------------------------------
   reg         HRESETn    =1'b0; initial begin #100; HRESETn = 1'b1; end
   wire        HCLK       =CLK50M;
   wire        M0_HBUSREQ ;
   wire        M0_HGRANT  ;
   wire [31:0] M0_HADDR   ;
   wire [ 1:0] M0_HTRANS  ;
   wire [ 2:0] M0_HSIZE   ;
   wire [ 2:0] M0_HBURST  ;
   wire [ 3:0] M0_HPROT   ;
   wire        M0_HWRITE  ;
   wire [31:0] M0_HWDATA  ;
   wire        M1_HBUSREQ ;
   wire        M1_HGRANT  ;
   wire [31:0] M1_HADDR   ;
   wire [ 1:0] M1_HTRANS  ;
   wire [ 2:0] M1_HSIZE   ;
   wire [ 2:0] M1_HBURST  ;
   wire [ 3:0] M1_HPROT   ;
   wire        M1_HWRITE  ;
   wire [31:0] M1_HWDATA  ;
   wire        M2_HBUSREQ ;
   wire        M2_HGRANT  ;
   wire [31:0] M2_HADDR   ;
   wire [ 1:0] M2_HTRANS  ;
   wire [ 2:0] M2_HSIZE   ;
   wire [ 2:0] M2_HBURST  ;
   wire [ 3:0] M2_HPROT   ;
   wire        M2_HWRITE  ;
   wire [31:0] M2_HWDATA  ;
   wire [31:0] M_HRDATA   ;
   wire        M_HREADY   ;
   wire [ 1:0] M_HRESP    ;
   wire [31:0] S_HADDR    ;
   wire [31:0] S_HWDATA   ;
   wire [ 1:0] S_HTRANS   ;
   wire [ 2:0] S_HSIZE    ;
   wire [ 2:0] S_HBURST   ;
   wire        S_HWRITE   ;
   wire [3:0]  S_HPROT    ;
   wire        S_HREADY   ;
   wire        S0_HSEL    ;
   wire [31:0] S0_HRDATA  ;
   wire [ 1:0] S0_HRESP   ;
   wire        S0_HREADY  ;
   wire        S1_HSEL    ;
   wire [31:0] S1_HRDATA  ;
   wire [ 1:0] S1_HRESP   ;
   wire        S1_HREADY  ;
   wire        S2_HSEL    ;
   wire [31:0] S2_HRDATA  ;
   wire [ 1:0] S2_HRESP   ;
   wire        S2_HREADY  ;
   wire        IRQ;
   //--------------------------------------------------------
   amba_ahb_m3s3 #(.P_HSEL0_START(16'hA000),.P_HSEL0_SIZE(16'h0010), // DMA
                   .P_HSEL1_START(16'h1000),.P_HSEL1_SIZE(16'h0010), // MEM
                   .P_HSEL2_START(16'h2000),.P_HSEL2_SIZE(16'h0010))
   u_ahb (
       .HRESETn     (HRESETn   )
     , .HCLK        (HCLK      )
     , .M_HBUSREQ_0 (M0_HBUSREQ)
     , .M_HGRANT_0  (M0_HGRANT )
     , .M_HADDR_0   (M0_HADDR  )
     , .M_HTRANS_0  (M0_HTRANS )
     , .M_HSIZE_0   (M0_HSIZE  )
     , .M_HBURST_0  (M0_HBURST )
     , .M_HPROT_0   (M0_HPROT  )
     , .M_HWRITE_0  (M0_HWRITE )
     , .M_HWDATA_0  (M0_HWDATA )
     , .M_HBUSREQ_1 (M1_HBUSREQ)
     , .M_HGRANT_1  (M1_HGRANT )
     , .M_HADDR_1   (M1_HADDR  )
     , .M_HTRANS_1  (M1_HTRANS )
     , .M_HSIZE_1   (M1_HSIZE  )
     , .M_HBURST_1  (M1_HBURST )
     , .M_HPROT_1   (M1_HPROT  )
     , .M_HWRITE_1  (M1_HWRITE )
     , .M_HWDATA_1  (M1_HWDATA )
     , .M_HBUSREQ_2 (M2_HBUSREQ)
     , .M_HGRANT_2  (M2_HGRANT )
     , .M_HADDR_2   (M2_HADDR  )
     , .M_HTRANS_2  (M2_HTRANS )
     , .M_HSIZE_2   (M2_HSIZE  )
     , .M_HBURST_2  (M2_HBURST )
     , .M_HPROT_2   (M2_HPROT  )
     , .M_HWRITE_2  (M2_HWRITE )
     , .M_HWDATA_2  (M2_HWDATA )
     , .M_HRDATA    (M_HRDATA  )
     , .M_HREADY    (M_HREADY  )
     , .M_HRESP     (M_HRESP   )
     , .HADDR       (S_HADDR   )
     , .HWDATA      (S_HWDATA  )
     , .HTRANS      (S_HTRANS  )
     , .HSIZE       (S_HSIZE   )
     , .HBURST      (S_HBURST  )
     , .HWRITE      (S_HWRITE  )
     , .HPROT       (S_HPROT   )
     , .HREADY      (S_HREADY  )
     , .HSEL_0      (S0_HSEL   )
     , .HRDATA_0    (S0_HRDATA )
     , .HRESP_0     (S0_HRESP  )
     , .HREADY_0    (S0_HREADY )
     , .HSEL_1      (S1_HSEL   )
     , .HRDATA_1    (S1_HRDATA )
     , .HRESP_1     (S1_HRESP  )
     , .HREADY_1    (S1_HREADY )
     , .HSEL_2      (S2_HSEL   )
     , .HRDATA_2    (S2_HRDATA )
     , .HRESP_2     (S2_HRESP  )
     , .HREADY_2    (S2_HREADY )
     , .REMAP       (1'b0      )
   );
   //--------------------------------------------------------
   dma_ahb_simple
   u_dma (
       .HRESETn     (HRESETn    )
     , .HCLK        (HCLK       )
     , .S_HADDR     (S_HADDR    )
     , .S_HTRANS    (S_HTRANS   )
     , .S_HWRITE    (S_HWRITE   )
     , .S_HSIZE     (S_HSIZE    )
     , .S_HBURST    (S_HBURST   )
     , .S_HWDATA    (S_HWDATA   )
     , .S_HREADYin  (S_HREADY   )
     , .S_HSEL      (S0_HSEL     )
     , .S_HRDATA    (S0_HRDATA   )
     , .S_HRESP     (S0_HRESP    )
     , .S_HREADYout (S0_HREADY   )
     , .IRQ         (IRQ        )
     , .M_HBUSREQ   (M0_HBUSREQ  )
     , .M_HGRANT    (M0_HGRANT   )
     , .M_HADDR     (M0_HADDR    )
     , .M_HTRANS    (M0_HTRANS   )
     , .M_HWRITE    (M0_HWRITE   )
     , .M_HSIZE     (M0_HSIZE    )
     , .M_HBURST    (M0_HBURST   )
     , .M_HPROT     (M0_HPROT    )
     , .M_HWDATA    (M0_HWDATA   )
     , .M_HRDATA    (M_HRDATA   )
     , .M_HRESP     (M_HRESP    )
     , .M_HREADY    (M_HREADY   )
   );
   //--------------------------------------------------------
   mem_ahb #(.ADD_WIDTH(20) // 1K depth
            ,.DELAY(7)
            ,.INIT(0))
   u_mem (
       .HRESETn   (HRESETn  )
     , .HCLK      (HCLK     )
     , .HADDR     (S_HADDR  )
     , .HTRANS    (S_HTRANS )
     , .HWRITE    (S_HWRITE )
     , .HSIZE     (S_HSIZE  )
     , .HBURST    (S_HBURST )
     , .HWDATA    (S_HWDATA )
     , .HREADYin  (S_HREADY )
     , .HSEL      (S1_HSEL  )
     , .HRDATA    (S1_HRDATA)
     , .HRESP     (S1_HRESP )
     , .HREADYout (S1_HREADY)
   ); 
   //--------------------------------------------------------
   mem_ahb #(.ADD_WIDTH(20) // 1K depth
            ,.DELAY(0)
            ,.INIT(0))
   u_memX (
       .HRESETn   (HRESETn  )
     , .HCLK      (HCLK     )
     , .HADDR     (S_HADDR  )
     , .HTRANS    (S_HTRANS )
     , .HWRITE    (S_HWRITE )
     , .HSIZE     (S_HSIZE  )
     , .HBURST    (S_HBURST )
     , .HWDATA    (S_HWDATA )
     , .HREADYin  (S_HREADY )
     , .HSEL      (S2_HSEL  )
     , .HRDATA    (S2_HRDATA)
     , .HRESP     (S2_HRESP )
     , .HREADYout (S2_HREADY)
   ); 
   //--------------------------------------------------------
   ahb_test
   u_test (
      .HRESETn (HRESETn  )
    , .HCLK    (HCLK     )
    , .HBUSREQ (M1_HBUSREQ)
    , .HGRANT  (M1_HGRANT )
    , .HADDR   (M1_HADDR  )
    , .HTRANS  (M1_HTRANS )
    , .HWRITE  (M1_HWRITE )
    , .HSIZE   (M1_HSIZE  )
    , .HBURST  (M1_HBURST )
    , .HWDATA  (M1_HWDATA )
    , .HRDATA  (M_HRDATA  )
    , .HRESP   (M_HRESP   )
    , .HREADY  (M_HREADY  )
   );
   //--------------------------------------------------------
   ahb_master #(.SADDR(32'h2000_0000))
   u_master (
      .HRESETn (HRESETn  )
    , .HCLK    (HCLK     )
    , .HBUSREQ (M2_HBUSREQ)
    , .HGRANT  (M2_HGRANT )
    , .HADDR   (M2_HADDR  )
    , .HTRANS  (M2_HTRANS )
    , .HWRITE  (M2_HWRITE )
    , .HSIZE   (M2_HSIZE  )
    , .HBURST  (M2_HBURST )
    , .HWDATA  (M2_HWDATA )
    , .HRDATA  (M_HRDATA  )
    , .HRESP   (M_HRESP   )
    , .HREADY  (M_HREADY  )
   );
   //--------------------------------------------------------
   initial begin
        repeat ( 3) @ (posedge HCLK);
        HRESETn= #1 1'b1;
        repeat (10) @ (posedge HCLK);
        //repeat (100) @ (posedge HCLK);
        //$finish(2);
   end
   //--------------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2014.01.26: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
