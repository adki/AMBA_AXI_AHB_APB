//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// axi_stom_s2.v
//----------------------------------------------------------------
// VERSION: 2011.01.08.
//----------------------------------------------------------------
`timescale 1ns/1ns
`include "axi_arbiter_stom_s2.v"

module axi_stom_s2
   // synopsys translate_off
   `protect
   // synopsys translate_on
       #(parameter WIDTH_CID=4  // Channel ID width in bits
                 , WIDTH_ID =4  // ID width in bits
                 , WIDTH_AD =32 // address width
                 , WIDTH_DA =32 // data width
                 , WIDTH_DS =(WIDTH_DA/8)  // data strobe width
                 , WIDTH_SID=WIDTH_CID+WIDTH_ID // ID for slave
                 , WIDTH_BUSER =1 // Write-response user path
                 , WIDTH_RUSER =1 // read-data user path
        )
(
       input   wire                      ARESETn
     , input   wire                      ACLK
     //--------------------------------------------------------------
     , input   wire  [WIDTH_CID-1:0]     M_MID
     , output  reg   [WIDTH_ID-1:0]      M_BID
     , output  reg   [ 1:0]              M_BRESP
     , output  reg                       M_BVALID
     , input   wire                      M_BREADY
     `ifdef AMBA_AXI_BUSER
     , output  reg   [WIDTH_BUSER-1:0]   M_BUSER
     `endif
     , output  reg   [WIDTH_ID-1:0]      M_RID
     , output  reg   [WIDTH_DA-1:0]      M_RDATA
     , output  reg   [ 1:0]              M_RRESP
     , output  reg                       M_RLAST
     , output  reg                       M_RVALID
     , input   wire                      M_RREADY
     `ifdef AMBA_AXI_RUSER
     , output  reg   [WIDTH_RUSER-1:0]   M_RUSER
     `endif
     //--------------------------------------------------------------
     , input   wire  [WIDTH_SID-1:0]     S0_BID
     , input   wire  [ 1:0]              S0_BRESP
     , input   wire                      S0_BVALID
     , output  wire                      S0_BREADY
     `ifdef AMBA_AXI_BUSER
     , input   wire  [WIDTH_BUSER-1:0]   S0_BUSER
     `endif
     , input   wire  [WIDTH_SID-1:0]     S0_RID
     , input   wire  [WIDTH_DA-1:0]      S0_RDATA
     , input   wire  [ 1:0]              S0_RRESP
     , input   wire                      S0_RLAST
     , input   wire                      S0_RVALID
     , output  wire                      S0_RREADY
     `ifdef AMBA_AXI_RUSER
     , input   wire  [WIDTH_RUSER-1:0]   S0_RUSER
     `endif
     //--------------------------------------------------------------
     , input   wire  [WIDTH_SID-1:0]     S1_BID
     , input   wire  [ 1:0]              S1_BRESP
     , input   wire                      S1_BVALID
     , output  wire                      S1_BREADY
     `ifdef AMBA_AXI_BUSER
     , input   wire  [WIDTH_BUSER-1:0]   S1_BUSER
     `endif
     , input   wire  [WIDTH_SID-1:0]     S1_RID
     , input   wire  [WIDTH_DA-1:0]      S1_RDATA
     , input   wire  [ 1:0]              S1_RRESP
     , input   wire                      S1_RLAST
     , input   wire                      S1_RVALID
     , output  wire                      S1_RREADY
     `ifdef AMBA_AXI_RUSER
     , input   wire  [WIDTH_RUSER-1:0]   S1_RUSER
     `endif
     //--------------------------------------------------------------
     , input   wire  [WIDTH_SID-1:0]     SD_BID
     , input   wire  [ 1:0]              SD_BRESP
     , input   wire                      SD_BVALID
     , output  wire                      SD_BREADY
     `ifdef AMBA_AXI_BUSER
     , input   wire  [WIDTH_BUSER-1:0]   SD_BUSER
     `endif
     , input   wire  [WIDTH_SID-1:0]     SD_RID
     , input   wire  [WIDTH_DA-1:0]      SD_RDATA
     , input   wire  [ 1:0]              SD_RRESP
     , input   wire                      SD_RLAST
     , input   wire                      SD_RVALID
     , output  wire                      SD_RREADY
     `ifdef AMBA_AXI_RUSER
     , input   wire  [WIDTH_RUSER-1:0]   SD_RUSER
     `endif
);
     //-----------------------------------------------------------
     localparam NUM=2;
     //-----------------------------------------------------------
     wire [NUM:0] BSELECT, RSELECT;
     wire [NUM:0] BGRANT , RGRANT ;
     //-----------------------------------------------------------
     assign BSELECT[0] = (S0_BID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     assign BSELECT[1] = (S1_BID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     assign BSELECT[2] = (SD_BID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     assign RSELECT[0] = (S0_RID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     assign RSELECT[1] = (S1_RID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     assign RSELECT[2] = (SD_RID[WIDTH_SID-1:WIDTH_ID]==M_MID);
     //-----------------------------------------------------------
     axi_arbiter_stom_s2 #(.NUM(NUM))
     Uaxi_arbiter_stom_s2 (
           .ARESETn  (ARESETn)
         , .ACLK     (ACLK   )
         , .BSELECT  (BSELECT)
         , .BVALID   ({SD_BVALID,S1_BVALID,S0_BVALID})
         , .BREADY   ({SD_BREADY,S1_BREADY,S0_BREADY})
         , .BGRANT   (BGRANT )
         , .RSELECT  (RSELECT)
         , .RVALID   ({SD_RVALID,S1_RVALID,S0_RVALID})
         , .RREADY   ({SD_RREADY,S1_RREADY,S0_RREADY})
         , .RLAST    ({SD_RLAST ,S1_RLAST ,S0_RLAST })
         , .RGRANT   (RGRANT )
     );
     //-----------------------------------------------------------
     localparam NUM_B_WIDTH = 0
                    + WIDTH_ID           //M_BID
                    +  2                 //M_BRESP
                    +  1                 //M_BVALID
                      `ifdef AMBA_AXI_BUSER
                    + WIDTH_BUSER        //M_BUSER
                      `endif
                    ;
     localparam NUM_R_WIDTH = 0
                    + WIDTH_ID           //M_RID
                    + WIDTH_DA           //M_RDATA
                    +  2                 //M_RRESP
                    +  1                 //M_RLAST
                    +  1                 //M_RVALID
                      `ifdef AMBA_AXI_RUSER
                    + WIDTH_RUSER        //M_RUSER
                      `endif
                    ;
     //-----------------------------------------------------------
     wire [NUM_B_WIDTH-1:0] bus_b[0:NUM];
     wire [NUM_R_WIDTH-1:0] bus_r[0:NUM];
     //-----------------------------------------------------------
     assign bus_b[0] = {S0_BID[WIDTH_ID-1:0]
                       ,S0_BRESP
                       ,S0_BVALID
                       `ifdef AMBA_AXI_BUSER
                       ,S0_BUSER
                       `endif
                       };
     assign bus_b[1] = {S1_BID[WIDTH_ID-1:0]
                       ,S1_BRESP
                       ,S1_BVALID
                       `ifdef AMBA_AXI_BUSER
                       ,S1_BUSER
                       `endif
                       };
     assign bus_b[2] = {SD_BID[WIDTH_ID-1:0]
                       ,SD_BRESP
                       ,SD_BVALID
                       `ifdef AMBA_AXI_BUSER
                       ,SD_BUSER
                       `endif
                       };
     assign bus_r[0] = {S0_RID[WIDTH_ID-1:0]
                       ,S0_RDATA
                       ,S0_RRESP
                       ,S0_RLAST
                       ,S0_RVALID
                       `ifdef AMBA_AXI_RUSER
                       ,S0_RUSER
                       `endif
                       };
     assign bus_r[1] = {S1_RID[WIDTH_ID-1:0]
                       ,S1_RDATA
                       ,S1_RRESP
                       ,S1_RLAST
                       ,S1_RVALID
                       `ifdef AMBA_AXI_RUSER
                       ,S1_RUSER
                       `endif
                       };
     assign bus_r[2] = {SD_RID[WIDTH_ID-1:0]
                       ,SD_RDATA
                       ,SD_RRESP
                       ,SD_RLAST
                       ,SD_RVALID
                       `ifdef AMBA_AXI_RUSER
                       ,SD_RUSER
                       `endif
                       };
     //-----------------------------------------------------------
     `define M_BBUS {M_BID[WIDTH_ID-1:0]\
                    ,M_BRESP\
                    ,M_BVALID\
                    `ifdef AMBA_AXI_BUSER\
                    ,M_BUSER\
                    `endif\
                    }
     always @ ( BGRANT, bus_b[0], bus_b[1], bus_b[2] ) begin
            `ifdef AMBA_AXI_MUX
            case (BGRANT)
            3'b001:  `M_BBUS = bus_b[0];
            3'b010:  `M_BBUS = bus_b[1];
            3'b100:  `M_BBUS = bus_b[2];
            default: `M_BBUS = 'h0;
            endcase
            `else
            `M_BBUS =
                ({NUM_B_WIDTH{BGRANT[0]}}&bus_b[0])
              | ({NUM_B_WIDTH{BGRANT[1]}}&bus_b[1])
              | ({NUM_B_WIDTH{BGRANT[2]}}&bus_b[2]);
            `endif
     end
     `define M_RBUS {M_RID[WIDTH_ID-1:0]\
                    ,M_RDATA\
                    ,M_RRESP\
                    ,M_RLAST\
                    ,M_RVALID\
                    `ifdef AMBA_AXI_RUSER\
                    ,M_RUSER\
                    `endif\
                    }
     always @ ( RGRANT, bus_r[0], bus_r[1], bus_r[2] ) begin
            `ifdef AMBA_AXI_MUX
            case (RGRANT)
            3'b001:  `M_RBUS = bus_r[0];
            3'b010:  `M_RBUS = bus_r[1];
            3'b100:  `M_RBUS = bus_r[2];
            default: `M_RBUS = 'h0;
            endcase
            `else
            `M_RBUS =
                ({NUM_R_WIDTH{RGRANT[0]}}&bus_r[0])
              | ({NUM_R_WIDTH{RGRANT[1]}}&bus_r[1])
              | ({NUM_R_WIDTH{RGRANT[2]}}&bus_r[2]);
            `endif
     end
     //-----------------------------------------------------------
     assign S0_BREADY = BGRANT[0]&M_BREADY;
     assign S1_BREADY = BGRANT[1]&M_BREADY;
     assign SD_BREADY = BGRANT[2]&M_BREADY;
     assign S0_RREADY = RGRANT[0]&M_RREADY;
     assign S1_RREADY = RGRANT[1]&M_RREADY;
     assign SD_RREADY = RGRANT[2]&M_RREADY;
     //-----------------------------------------------------------
   // synopsys translate_off
   `endprotect
   // synopsys translate_on
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.01.08: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
