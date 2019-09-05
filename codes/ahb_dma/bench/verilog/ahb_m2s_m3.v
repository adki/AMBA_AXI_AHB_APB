`ifndef AHB_M2S_M3_V
`define AHB_M2S_M3_V
/*********************************************************
 * Copyright (c) 2007 by Ando Ki.
 * All right reserved.
 *
 * http://www.dynalith.com
 * adki@dynalith.com
 *********************************************************/
/* AMBA AHB Master-to-Slave Mux
 */
`timescale 1ns/1ns

module ahb_m2s_m3 (
       HRESETn,
       HCLK,
       HREADY,
       HMASTER,
       HADDR,
       HPROT,
       HTRANS,
       HWRITE,
       HSIZE,
       HBURST,
       HWDATA,
       HADDR_0, HPROT_0, HTRANS_0, HWRITE_0, HSIZE_0, HBURST_0, HWDATA_0,
       HADDR_1, HPROT_1, HTRANS_1, HWRITE_1, HSIZE_1, HBURST_1, HWDATA_1,
       HADDR_2, HPROT_2, HTRANS_2, HWRITE_2, HSIZE_2, HBURST_2, HWDATA_2
);
  parameter NUM_MASTER = 3;
       input         HRESETn;  wire        HRESETn; 
       input         HCLK;     wire        HCLK;
       input         HREADY;   wire        HREADY;
       input  [3:0]  HMASTER;  wire [3:0]  HMASTER;
       output [31:0] HADDR;    reg  [31:0] HADDR;
       output [3:0]  HPROT;    reg  [3:0]  HPROT;
       output [1:0]  HTRANS;   reg  [1:0]  HTRANS;
       output        HWRITE;   reg         HWRITE;
       output [2:0]  HSIZE;    reg  [2:0]  HSIZE;
       output [2:0]  HBURST;   reg  [2:0]  HBURST;
       output [31:0] HWDATA;   reg  [31:0] HWDATA;
       input  [31:0] HADDR_0;  wire [31:0] HADDR_0;
       input  [3:0]  HPROT_0;  wire [3:0]  HPROT_0;
       input  [1:0]  HTRANS_0; wire [1:0]  HTRANS_0;
       input         HWRITE_0; wire        HWRITE_0;
       input  [2:0]  HSIZE_0;  wire [2:0]  HSIZE_0;
       input  [2:0]  HBURST_0; wire [2:0]  HBURST_0;
       input  [31:0] HWDATA_0; wire [31:0] HWDATA_0;
       input  [31:0] HADDR_1;  wire [31:0] HADDR_1;
       input  [3:0]  HPROT_1;  wire [3:0]  HPROT_1;
       input  [1:0]  HTRANS_1; wire [1:0]  HTRANS_1;
       input         HWRITE_1; wire        HWRITE_1;
       input  [2:0]  HSIZE_1;  wire [2:0]  HSIZE_1;
       input  [2:0]  HBURST_1; wire [2:0]  HBURST_1;
       input  [31:0] HWDATA_1; wire [31:0] HWDATA_1;
       input  [31:0] HADDR_2;  wire [31:0] HADDR_2;
       input  [3:0]  HPROT_2;  wire [3:0]  HPROT_2;
       input  [1:0]  HTRANS_2; wire [1:0]  HTRANS_2;
       input         HWRITE_2; wire        HWRITE_2;
       input  [2:0]  HSIZE_2;  wire [2:0]  HSIZE_2;
       input  [2:0]  HBURST_2; wire [2:0]  HBURST_2;
       input  [31:0] HWDATA_2; wire [31:0] HWDATA_2;
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
       always @ (HMASTER or HADDR_0 or HADDR_1 or HADDR_2 )
           case (HMASTER)
           4'h0: HADDR = HADDR_0;
           4'h1: HADDR = HADDR_1;
           4'h2: HADDR = HADDR_2;
           default: HADDR = ~32'b0;
           endcase
       always @ (HMASTER or HPROT_0 or HPROT_1 or HPROT_2 )
           case (HMASTER)
           4'h0: HPROT = HPROT_0;
           4'h1: HPROT = HPROT_1;
           4'h2: HPROT = HPROT_2;
           default: HPROT = 32'b0;
           endcase
       always @ (HMASTER or HTRANS_0 or HTRANS_1 or HTRANS_2 )
           case (HMASTER)
           4'h0: HTRANS = HTRANS_0;
           4'h1: HTRANS = HTRANS_1;
           4'h2: HTRANS = HTRANS_2;
           default: HTRANS = 32'b0;
           endcase
       always @ (HMASTER or HWRITE_0 or HWRITE_1 or HWRITE_2 )
           case (HMASTER)
           4'h0: HWRITE = HWRITE_0;
           4'h1: HWRITE = HWRITE_1;
           4'h2: HWRITE = HWRITE_2;
           default: HWRITE = 32'b0;
           endcase
       always @ (HMASTER or HSIZE_0 or HSIZE_1 or HSIZE_2 )
           case (HMASTER)
           4'h0: HSIZE = HSIZE_0;
           4'h1: HSIZE = HSIZE_1;
           4'h2: HSIZE = HSIZE_2;
           default: HSIZE = 32'b0;
           endcase
       always @ (HMASTER or HBURST_0 or HBURST_1 or HBURST_2 )
           case (HMASTER)
           4'h0: HBURST = HBURST_0;
           4'h1: HBURST = HBURST_1;
           4'h2: HBURST = HBURST_2;
           default: HBURST = 32'b0;
           endcase
       always @ (hmaster_delay or HWDATA_0 or HWDATA_1 or HWDATA_2 )
           case (hmaster_delay)
           4'h0: HWDATA = HWDATA_0;
           4'h1: HWDATA = HWDATA_1;
           4'h2: HWDATA = HWDATA_2;
           default: HWDATA = 32'b0;
           endcase
endmodule
`endif
