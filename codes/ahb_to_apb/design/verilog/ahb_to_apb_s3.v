//--------------------------------------------------------
// Copyright (c) 2009-2011 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// VERSION: 2011.05.05.
//--------------------------------------------------------
// a simplified version of AMBA AHB-to-APB bus bridge
//--------------------------------------------------------
`timescale 1ns/1ns
`include "ahb_to_apb_controller.v"

module ahb_to_apb_s3
     #(parameter P_PSEL0_START = 16'hC000, P_PSEL0_SIZE  = 16'h0010,
                 P_PSEL1_START = 16'hC010, P_PSEL1_SIZE  = 16'h0010,
                 P_PSEL2_START = 16'hC020, P_PSEL2_SIZE  = 16'h0010)
(
       input  wire        HRESETn
     , input  wire        HCLK
     , input  wire        HSEL
     , input  wire [31:0] HADDR
     , input  wire [ 1:0] HTRANS
     , input  wire [ 3:0] HPROT
     , input  wire        HWRITE
     , input  wire [ 2:0] HSIZE
     , input  wire [ 2:0] HBURST
     , input  wire [31:0] HWDATA
     , output wire [31:0] HRDATA
     , output wire [ 1:0] HRESP
     , input  wire        HREADYin
     , output wire        HREADYout
     , input  wire        PCLK
     , input  wire        PRESETn
     , output wire        PENABLE
     , output wire [31:0] PADDR
     , output wire        PWRITE
     , output wire [31:0] PWDATA
     , output wire        PSEL0
     , input  wire [31:0] PRDATA0
     `ifdef AMBA_APB3
     , input  wire        PREADY0
     , input  wire        PSLVERR0
     `endif
     , output wire        PSEL1
     , input  wire [31:0] PRDATA1
     `ifdef AMBA_APB3
     , input  wire        PREADY1
     , input  wire        PSLVERR1
     `endif
     , output wire        PSEL2
     , input  wire [31:0] PRDATA2
     `ifdef AMBA_APB3
     , input  wire        PREADY2
     , input  wire        PSLVERR2
     `endif
     `ifdef AMBA_APB4
     , output wire [ 2:0] PPROT
     , output wire [ 3:0] PSTRB
     `endif
     , input  wire [ 1:0] CLOCK_RATIO // 0=1:1, 3=async
);
   //-----------------------------------------------------
   wire        PSEL   ;
   reg  [31:0] PRDATA ;
   `ifdef AMBA_APB3
   reg         PREADY ;
   reg         PSLVERR;
   `endif
   //-----------------------------------------------------
   wire [2:0] _psel = {PSEL2,PSEL1,PSEL0};
   //-----------------------------------------------------
    ahb_to_apb_controller Uahb_to_apb_controller (
          .HRESETn   (HRESETn)
        , .HCLK      (HCLK)
        , .HSEL      (HSEL)
        , .HADDR     (HADDR)
        , .HTRANS    (HTRANS)
        , .HPROT     (HPROT)
        , .HWRITE    (HWRITE)
        , .HSIZE     (HSIZE)
        , .HBURST    (HBURST)
        , .HWDATA    (HWDATA)
        , .HRDATA    (HRDATA)
        , .HRESP     (HRESP)
        , .HREADYin  (HREADYin)
        , .HREADYout (HREADYout)

        , .PCLK      (PCLK)
        , .PRESETn   (PRESETn)
        , .PSEL      (PSEL)
        , .PENABLE   (PENABLE)
        , .PADDR     (PADDR)
        , .PWRITE    (PWRITE)
        , .PRDATA    (PRDATA)
        , .PWDATA    (PWDATA)

        `ifdef AMBA_APB3
        , .PREADY    (PREADY )
        , .PSLVERR   (PSLVERR)
        `endif
        `ifdef AMBA_APB4
        , .PPROT     (PPROT)
        , .PSTRB     (PSTRB)
        `endif

        , .CLOCK_RATIO(CLOCK_RATIO)
   );
   //-----------------------------------------------------
   apb_decoder_s3 #(3, P_PSEL0_START, P_PSEL0_SIZE,
                       P_PSEL1_START, P_PSEL1_SIZE,
                       P_PSEL2_START, P_PSEL2_SIZE)
               Uapb_decoder (
                     // input       // output
                     .PSELin(PSEL),
                     .PADDR( PADDR), .PSELout1(PSEL0),
                                     .PSELout2(PSEL1),
                                     .PSELout3(PSEL2)
   );
   //-----------------------------------------------------
   always @ (_psel or
             PRDATA0 or PRDATA1 or PRDATA2) begin
    case(_psel)
      3'b001: PRDATA = PRDATA0;
      3'b010: PRDATA = PRDATA1;
      3'b100: PRDATA = PRDATA2;
      default: PRDATA = 32'b0;
    endcase
   end
   //-----------------------------------------------------
   `ifdef AMBA_APB3
   always @ (_psel or
             PREADY0 or PREADY1 or PREADY2 ) begin
    case(_psel)
      3'b001: PREADY = PREADY0;
      3'b010: PREADY = PREADY1;
      3'b100: PREADY = PREADY2;
      default:  PREADY = 1'b1  ;
    endcase
   end
   always @ (_psel or
             PSLVERR0 or PSLVERR1 or PSLVERR2 ) begin
    case(_psel)
      3'b001: PSLVERR = PSLVERR0;
      3'b010: PSLVERR = PSLVERR1;
      3'b100: PSLVERR = PSLVERR2;
      default: PSLVERR = 1'b0    ;
    endcase
   end
   `endif
   //-----------------------------------------------------
endmodule // ahb_apb

//--------------------------------------------------------
module apb_decoder_s3
     #(parameter P_NUM         = 3, // how many slaves
                 P_ADDR_START1 = 'hC000, P_ADDR_SIZE1  = 'h0001,
                 P_ADDR_START2 = 'hC010, P_ADDR_SIZE2  = 'h0001,
                 P_ADDR_START3 = 'hC020, P_ADDR_SIZE3  = 'h0001)
(
       input  wire        PSELin
     , input  wire [31:0] PADDR
     , output reg         PSELout1
     , output reg         PSELout2
     , output reg         PSELout3
);
   //-----------------------------------------------------
   // decoder
   localparam P_ADDR_END1 = P_ADDR_START1 + P_ADDR_SIZE1 - 1;
   localparam P_ADDR_END2 = P_ADDR_START2 + P_ADDR_SIZE2 - 1;
   localparam P_ADDR_END3 = P_ADDR_START3 + P_ADDR_SIZE3 - 1;
`ifdef RIGOR
// synopsys translate_off
   wire [2:0] _psel = {PSELout3,PSELout2,PSELout1};
// synopsys translate_on
`endif
   wire [15:0] tpaddr = PADDR[31:16];
   always @ (tpaddr or PSELin) begin
      if (P_NUM>0&&tpaddr>=P_ADDR_START1&&tpaddr<=P_ADDR_END1) PSELout1 <= 1'b1&PSELin;
      else                                                   PSELout1 <= 1'b0;
      if (P_NUM>1&&tpaddr>=P_ADDR_START2&&tpaddr<=P_ADDR_END2) PSELout2 <= 1'b1&PSELin;
      else                                                   PSELout2 <= 1'b0;
      if (P_NUM>2&&tpaddr>=P_ADDR_START3&&tpaddr<=P_ADDR_END3) PSELout3 <= 1'b1&PSELin;
      else                                                   PSELout3 <= 1'b0;

`ifdef RIGOR
// synopsys translate_off
    if ((_psel!=3'b001)&&(_psel!=3'b010)&&
        (_psel!=3'b100)&&
        (_psel!=3'b000))
        $display($time,, "ERROR: more than one has been selected! 0x%x", _psel);
// synopsys translate_on
`endif
   end // always

// synopsys translate_off
   initial begin
      if ((P_NUM>0)&&(P_ADDR_START1>=P_ADDR_END1))
          $display("ERROR: address range for PSEL0: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
      if ((P_NUM>1)&&(P_ADDR_START2>=P_ADDR_END2))
          $display("ERROR: address range for PSEL1: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
      if ((P_NUM>2)&&(P_ADDR_START3>=P_ADDR_END3))
          $display("ERROR: address range for PSEL2: from 0x%x to 0x%x", P_ADDR_START3, P_ADDR_END3);
   end // initial
   initial begin
          $display("Info: %m PSEL0: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START1, P_ADDR_END1);
          $display("Info: %m PSEL1: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START2, P_ADDR_END2);
          $display("Info: %m PSEL2: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START3, P_ADDR_END3);
   end // initial
// synopsys translate_on

endmodule // ahb_apb_decoder
//--------------------------------------------------------
// Revision history
//
// 2011.03.20: Starte based on ahb_to_apb_s4.v by Ando Ki.
//--------------------------------------------------------
