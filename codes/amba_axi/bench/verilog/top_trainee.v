//----------------------------------------------------------------
//  Copyright (c) 2011 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// top.v
//----------------------------------------------------------------
// VERSION: 2011.01.01.
//----------------------------------------------------------------
`timescale 1ns/1ns

`ifndef WIDTH_AD
`define WIDTH_AD   32 // address width
`endif
`ifndef WIDTH_DA
`define WIDTH_DA   32 // data width
`endif
`ifndef ADDR_LENGTH
`define ADDR_LENGTH 12
`endif

module top ;
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       //$dumplimit(1000000);
   end
   `endif
   //---------------------------------------------------------
   localparam NUM_MASTER  = 2 
            , NUM_SLAVE   = 2;
   localparam WIDTH_CID   = 2    // Channel ID width in bits
            , WIDTH_ID    = 4    // ID width in bits
            , WIDTH_AD    =`WIDTH_AD    // address width
            , WIDTH_DA    =`WIDTH_DA    // data width
            , WIDTH_DS    =(WIDTH_DA/8)  // data strobe width
            , WIDTH_SID   =WIDTH_CID+WIDTH_ID // ID for slave
            , WIDTH_AWUSER=1  // Write-address user path
            , WIDTH_WUSER =1  // Write-data user path
            , WIDTH_BUSER =1  // Write-response user path
            , WIDTH_ARUSER=1  // read-address user path
            , WIDTH_RUSER =1; // read-data user path
   localparam ADDR_BASE0  =32'h0000_0000
            , ADDR_LENGTH0=`ADDR_LENGTH
            , ADDR_BASE1  =(ADDR_BASE0+(1<<ADDR_LENGTH0))
            , ADDR_LENGTH1=`ADDR_LENGTH;
   //---------------------------------------------------------
   reg                      ARESETn;
   reg                      ACLK   ;
   //--------------------------------------------------------------
   // fill your code
   //---------------------------------------------------------
   axi_switch_m2s2
       #(.WIDTH_CID   (WIDTH_CID   )
        ,.WIDTH_ID    (WIDTH_ID    )
        ,.WIDTH_AD    (WIDTH_AD    )
        ,.WIDTH_DA    (WIDTH_DA    )
        ,.WIDTH_DS    (WIDTH_DS    )
        ,.WIDTH_SID   (WIDTH_SID   )
        ,.WIDTH_AWUSER(WIDTH_AWUSER)
        ,.WIDTH_WUSER (WIDTH_WUSER )
        ,.WIDTH_BUSER (WIDTH_BUSER )
        ,.WIDTH_ARUSER(WIDTH_ARUSER)
        ,.WIDTH_RUSER (WIDTH_RUSER )
        ,.ADDR_BASE0  (ADDR_BASE0  )
        ,.ADDR_LENGTH0(ADDR_LENGTH0)
        ,.ADDR_BASE1  (ADDR_BASE1  )
        ,.ADDR_LENGTH1(ADDR_LENGTH1)
        )
   Uaxi_switch_m2s2 (
        // fill your coded
   );
   //---------------------------------------------------------
   generate
   genvar idm;
   for (idm=0; idm<NUM_MASTER; idm=idm+1) begin: MST_BLK
        bfm_axi #(.MST_ID   (idm+1    ) // Master ID
                 ,.WIDTH_CID(WIDTH_CID)
                 ,.WIDTH_ID (WIDTH_ID ) // ID width in bits
                 ,.WIDTH_AD (WIDTH_AD ) // address width
                 ,.WIDTH_DA (WIDTH_DA ))// data width
        u_bfm_axi (
		 // fill your code
        );
   end
   endgenerate
   //---------------------------------------------------------
   generate
   genvar ids;
   for (ids=0; ids<NUM_SLAVE; ids=ids+1) begin: SLV_BLK
        mem_axi #(.AXI_WIDTH_CID  (WIDTH_CID)// Channel ID width in bits
                 ,.AXI_WIDTH_ID   (WIDTH_ID )// ID width in bits
                 ,.AXI_WIDTH_AD   (WIDTH_AD )// address width
                 ,.AXI_WIDTH_DA   (WIDTH_DA )// data width
                 ,.AXI_WIDTH_DS   (WIDTH_DS )// data strobe width
                 ,.ADDR_LENGTH(ADDR_LENGTH0) // effective addre bits
                 )
        u_mem_axi (
             // fill your code
        );
   end
   endgenerate
   //---------------------------------------------------------
   wire [NUM_MASTER-1:0] DONE;
   generate
   genvar xds;
   for (xds=0; xds<NUM_MASTER; xds=xds+1) begin :BLK_XDS
        assign DONE[xds] = MST_BLK[xds].u_bfm_axi.DONE;
   end
   endgenerate
   //---------------------------------------------------------
   integer nx;
   always #5 ACLK = ~ACLK;
   initial begin
       ACLK    = 0;
       ARESETn = 0;
       for (nx=0; nx<NUM_MASTER; nx=nx+1) M_CSYSREQ[nx] = 1;
       for (nx=0; nx<NUM_SLAVE;  nx=nx+1) S_CSYSREQ[nx] = 1;
       repeat (2) @ (posedge ACLK);
       ARESETn = 1;
       repeat (2) @ (posedge ACLK);
       for (nx=0; nx<NUM_MASTER; nx=nx+1) wait(M_CACTIVE[nx]==1'b1);
       repeat (5) @ (posedge ACLK);
       for (nx=0; nx<NUM_MASTER; nx=nx+1) wait(&DONE);
       $finish(2);
   end
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpvars(0);
   end
   `endif
   //---------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.01.01: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
