/*********************************************************
 * Copyright (c) 2007 by Ando Ki.
 * All right reserved.
 *
 * http://www.dynalith.com
 * adki@dynalith.com
 *********************************************************/
/* AMBA AHB Slave-to-Master Mux
 */
`timescale 1ns/1ns

module ahb_s2m_s3 (
       input   wire        HRESETn
     , input   wire        HCLK
     , input   wire        HSEL0
     , input   wire        HSEL1
     , input   wire        HSEL2
     , input   wire        HSELd
     , output  reg  [31:0] HRDATA
     , output  reg  [1:0]  HRESP
     , output  reg         HREADY
     , input   wire [31:0] HRDATA0
     , input   wire [1:0]  HRESP0
     , input   wire        HREADY0
     , input   wire [31:0] HRDATA1
     , input   wire [1:0]  HRESP1
     , input   wire        HREADY1
     , input   wire [31:0] HRDATA2
     , input   wire [1:0]  HRESP2
     , input   wire        HREADY2
     , input   wire [31:0] HRDATAd
     , input   wire [1:0]  HRESPd
     , input   wire        HREADYd
);
 /********************************************************/
  localparam D_HSEL0 = 4'b0001;
  localparam D_HSEL1 = 4'b0010;
  localparam D_HSEL2 = 4'b0100;
  localparam D_HSELd = 4'b1000;
  wire [3:0] _hsel = {HSELd,HSEL2,HSEL1,HSEL0};
  reg  [3:0] _hsel_reg;

  always @ (negedge HRESETn or posedge HCLK) begin
    if (~HRESETn)   _hsel_reg <= 'h0;
    else if(HREADY) _hsel_reg <= _hsel; // default HREADY must be 1'b1
  end

  always @ (_hsel_reg or HREADY0 or HREADY1 or HREADY2 or HREADYd) begin
    case(_hsel_reg) // synopsys full_case parallel_case
      D_HSEL0: HREADY = HREADY0; // default
      D_HSEL1: HREADY = HREADY1;
      D_HSEL2: HREADY = HREADY2;
      D_HSELd: HREADY = HREADYd;
      default: HREADY = 1'b1;
    endcase
  end

  always @ (_hsel_reg or HRDATA0 or HRDATA1 or HRDATA2 or HRDATAd) begin
    case(_hsel_reg) // synopsys full_case parallel_case
      D_HSEL0: HRDATA = HRDATA0;
      D_HSEL1: HRDATA = HRDATA1;
      D_HSEL2: HRDATA = HRDATA2;
      D_HSELd: HRDATA = HRDATAd;
      default: HRDATA = 32'b0;
    endcase
  end

  always @ (_hsel_reg or HRESP0 or HRESP1 or HRESP2 or HRESPd) begin
    case(_hsel_reg) // synopsys full_case parallel_case
      D_HSEL0: HRESP = HRESP0;
      D_HSEL1: HRESP = HRESP1;
      D_HSEL2: HRESP = HRESP2;
      D_HSELd: HRESP = HRESPd;
      default: HRESP = 2'b01; //`HRESP_ERROR;
    endcase
  end

endmodule

//-------------------------------------------------------------------
// Revision history:
//
// Jan. 05, 2010: started by Ando Ki.
//-------------------------------------------------------------------
