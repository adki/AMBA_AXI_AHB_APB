`ifndef AHB_M2S_M2_V
`define AHB_M2S_M2_V
/*********************************************************
 * Copyright (c) 2010 by Ando Ki.
 * All right reserved.
 *
 * http://www.dynalith.com
 * adki@dynalith.com
 *********************************************************/
/* AMBA AHB Master-to-Slave Mux
 */
`timescale 1ns/1ns

module ahb_m2s_m2 #(parameter NUM_MASTER = 3)
(
       input   wire        HRESETn
     , input   wire        HCLK
     , input   wire        HREADY
     , input   wire [3:0]  HMASTER
     , output  reg  [31:0] HADDR
     , output  reg  [3:0]  HPROT
     , output  reg  [1:0]  HTRANS
     , output  reg         HWRITE
     , output  reg  [2:0]  HSIZE
     , output  reg  [2:0]  HBURST
     , output  reg  [31:0] HWDATA
     , input   wire [31:0] HADDR_0
     , input   wire [3:0]  HPROT_0
     , input   wire [1:0]  HTRANS_0
     , input   wire        HWRITE_0
     , input   wire [2:0]  HSIZE_0
     , input   wire [2:0]  HBURST_0
     , input   wire [31:0] HWDATA_0
     , input   wire [31:0] HADDR_1
     , input   wire [3:0]  HPROT_1
     , input   wire [1:0]  HTRANS_1
     , input   wire        HWRITE_1
     , input   wire [2:0]  HSIZE_1
     , input   wire [2:0]  HBURST_1
     , input   wire [31:0] HWDATA_1
);
       //----------------------------
       reg [3:0] hmaster_delay;
       always @ (posedge HCLK or negedge HRESETn)
       begin
           if (HRESETn==1'b0) begin
                hmaster_delay <= 4'b0;
           end else begin
                if (HREADY) begin
                   hmaster_delay <= HMASTER;
                end
           end
       end
       //----------------------------
       always @ (HMASTER or HADDR_0 or HADDR_1)
           case (HMASTER)
           4'h0: HADDR = HADDR_0;
           4'h1: HADDR = HADDR_1;
           default: HADDR = ~32'b0;
           endcase
       always @ (HMASTER or HPROT_0 or HPROT_1)
           case (HMASTER)
           4'h0: HPROT = HPROT_0;
           4'h1: HPROT = HPROT_1;
           default: HPROT = 32'b0;
           endcase
       always @ (HMASTER or HTRANS_0 or HTRANS_1)
           case (HMASTER)
           4'h0: HTRANS = HTRANS_0;
           4'h1: HTRANS = HTRANS_1;
           default: HTRANS = 32'b0;
           endcase
       always @ (HMASTER or HWRITE_0 or HWRITE_1)
           case (HMASTER)
           4'h0: HWRITE = HWRITE_0;
           4'h1: HWRITE = HWRITE_1;
           default: HWRITE = 32'b0;
           endcase
       always @ (HMASTER or HSIZE_0 or HSIZE_1)
           case (HMASTER)
           4'h0: HSIZE = HSIZE_0;
           4'h1: HSIZE = HSIZE_1;
           default: HSIZE = 32'b0;
           endcase
       always @ (HMASTER or HBURST_0 or HBURST_1)
           case (HMASTER)
           4'h0: HBURST = HBURST_0;
           4'h1: HBURST = HBURST_1;
           default: HBURST = 32'b0;
           endcase
       always @ (hmaster_delay or HWDATA_0 or HWDATA_1)
           case (hmaster_delay)
           4'h0: HWDATA = HWDATA_0;
           4'h1: HWDATA = HWDATA_1;
           default: HWDATA = 32'b0;
           endcase
endmodule
`endif
