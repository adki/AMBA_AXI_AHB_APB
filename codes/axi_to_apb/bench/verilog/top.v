//----------------------------------------------------------------
//  Copyright (c) 2010 by Ando Ki.
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

`ifndef WIDTH_CID
`define WIDTH_CID 4
`endif

`ifndef WIDTH_ID
`define WIDTH_ID 4
`endif

`ifndef WIDTH_AD
`define WIDTH_AD 32
`endif

`ifndef WIDTH_DA
`define WIDTH_DA 32
`endif

`ifndef ADDR_LENGTH
`define ADDR_LENGTH 12
`endif

`ifndef NUM_PSLAVE
`define NUM_PSLAVE 5
`define NUM_PSLAVE_5
`endif

`ifdef  AMBA_APB4
`ifndef AMBA_APB3
`define AMBA_APB3
`endif
`endif

module top ;
   //---------------------------------------------------------
   parameter  WIDTH_CID  =`WIDTH_CID  // Channel ID width in bits
            , WIDTH_ID   =`WIDTH_ID   // ID width in bits
            , WIDTH_AD   =`WIDTH_AD   // address width
            , WIDTH_DA   =`WIDTH_DA   // data width
            , WIDTH_DS   =(WIDTH_DA/8)   // data strobe width
            , WIDTH_DSB  =clogb2(WIDTH_DS)  // 
            , WIDTH_SID  =(WIDTH_CID+WIDTH_ID)
            , ADDR_LENGTH=`ADDR_LENGTH
            , NUM_PSLAVE = `NUM_PSLAVE
            , WIDTH_PAD  =32   // address width
            , WIDTH_PDA  =32   // data width
            , WIDTH_PDS  =(WIDTH_PDA/8)   // data strobe width
            , WIDTH_PDSB =clogb2(WIDTH_PDS)
            `ifdef NUM_PSLAVE_5
            , ADDR_PLENGTH0 = `ADDR_LENGTH , ADDR_PBASE0 = 0
            , ADDR_PLENGTH1 = `ADDR_LENGTH , ADDR_PBASE1 = (1<<ADDR_PLENGTH1)
            , ADDR_PLENGTH2 = `ADDR_LENGTH , ADDR_PBASE2 = (2<<ADDR_PLENGTH2)
            , ADDR_PLENGTH3 = `ADDR_LENGTH , ADDR_PBASE3 = (3<<ADDR_PLENGTH3)
            , ADDR_PLENGTH4 = `ADDR_LENGTH , ADDR_PBASE4 = (4<<ADDR_PLENGTH4)
            `elsif NUM_PSLAVE_8
            , ADDR_PLENGTH0 = `ADDR_LENGTH , ADDR_PBASE0 = 0
            , ADDR_PLENGTH1 = `ADDR_LENGTH , ADDR_PBASE1 = (1<<ADDR_PLENGTH1)
            , ADDR_PLENGTH2 = `ADDR_LENGTH , ADDR_PBASE2 = (2<<ADDR_PLENGTH2)
            , ADDR_PLENGTH3 = `ADDR_LENGTH , ADDR_PBASE3 = (3<<ADDR_PLENGTH3)
            , ADDR_PLENGTH4 = `ADDR_LENGTH , ADDR_PBASE4 = (4<<ADDR_PLENGTH4)
            , ADDR_PLENGTH5 = `ADDR_LENGTH , ADDR_PBASE5 = (5<<ADDR_PLENGTH5)
            , ADDR_PLENGTH6 = `ADDR_LENGTH , ADDR_PBASE6 = (6<<ADDR_PLENGTH6)
            , ADDR_PLENGTH7 = `ADDR_LENGTH , ADDR_PBASE7 = (7<<ADDR_PLENGTH7)
            `elsif NUM_PSLAVE_16
            , ADDR_PLENGTH0 = `ADDR_LENGTH , ADDR_PBASE0 = 0
            , ADDR_PLENGTH1 = `ADDR_LENGTH , ADDR_PBASE1 = (1 <<ADDR_PLENGTH1)
            , ADDR_PLENGTH2 = `ADDR_LENGTH , ADDR_PBASE2 = (2 <<ADDR_PLENGTH2)
            , ADDR_PLENGTH3 = `ADDR_LENGTH , ADDR_PBASE3 = (3 <<ADDR_PLENGTH3)
            , ADDR_PLENGTH4 = `ADDR_LENGTH , ADDR_PBASE4 = (4 <<ADDR_PLENGTH4)
            , ADDR_PLENGTH5 = `ADDR_LENGTH , ADDR_PBASE5 = (5 <<ADDR_PLENGTH5)
            , ADDR_PLENGTH6 = `ADDR_LENGTH , ADDR_PBASE6 = (6 <<ADDR_PLENGTH6)
            , ADDR_PLENGTH7 = `ADDR_LENGTH , ADDR_PBASE7 = (7 <<ADDR_PLENGTH7)
            , ADDR_PLENGTH8 = `ADDR_LENGTH , ADDR_PBASE8 = (8 <<ADDR_PLENGTH8)
            , ADDR_PLENGTH9 = `ADDR_LENGTH , ADDR_PBASE9 = (9 <<ADDR_PLENGTH9)
            , ADDR_PLENGTH10= `ADDR_LENGTH , ADDR_PBASE10= (10<<ADDR_PLENGTH10)
            , ADDR_PLENGTH11= `ADDR_LENGTH , ADDR_PBASE11= (11<<ADDR_PLENGTH11)
            , ADDR_PLENGTH12= `ADDR_LENGTH , ADDR_PBASE12= (12<<ADDR_PLENGTH12)
            , ADDR_PLENGTH13= `ADDR_LENGTH , ADDR_PBASE13= (13<<ADDR_PLENGTH13)
            , ADDR_PLENGTH14= `ADDR_LENGTH , ADDR_PBASE14= (14<<ADDR_PLENGTH14)
            , ADDR_PLENGTH15= `ADDR_LENGTH , ADDR_PBASE15= (15<<ADDR_PLENGTH15)
            `else
            `endif
            ;
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       //$dumplimit(1000000);
   end
   `endif
   //---------------------------------------------------------
   reg                  ARESETn  ;
   reg                  ACLK     ;
   wire [WIDTH_SID-1:0] AWID     ;
   wire [WIDTH_AD-1:0]  AWADDR   ;
   `ifdef AMBA_AXI4
   wire [ 7:0]          AWLEN    ;
   wire                 AWLOCK   ;
   `else
   wire [ 3:0]          AWLEN    ;
   wire [ 1:0]          AWLOCK   ;
   `endif
   wire [ 2:0]          AWSIZE   ;
   wire [ 1:0]          AWBURST  ;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]          AWCACHE  ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]          AWPROT   ;
   `endif
   wire                 AWVALID  ;
   wire                 AWREADY  ;
   `ifdef AMBA_AXI4
   wire [ 3:0]          AWQOS    ;
   wire [ 3:0]          AWREGION ;
   `endif
   wire [WIDTH_SID-1:0] WID      ;
   wire [WIDTH_DA-1:0]  WDATA    ;
   wire [WIDTH_DS-1:0]  WSTRB    ;
   wire                 WLAST    ;
   wire                 WVALID   ;
   wire                 WREADY   ;
   wire [WIDTH_SID-1:0] BID      ;
   wire [ 1:0]          BRESP    ;
   wire                 BVALID   ;
   wire                 BREADY   ;
   wire [WIDTH_SID-1:0] ARID     ;
   wire [WIDTH_AD-1:0]  ARADDR   ;
   `ifdef AMBA_AXI4
   wire [ 7:0]          ARLEN    ;
   wire                 ARLOCK   ;
   `else
   wire [ 3:0]          ARLEN    ;
   wire [ 1:0]          ARLOCK   ;
   `endif
   wire [ 2:0]          ARSIZE   ;
   wire [ 1:0]          ARBURST  ;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]          ARCACHE  ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]          ARPROT   ;
   `endif
   wire                 ARVALID  ;
   wire                 ARREADY  ;
   `ifdef AMBA_AXI4
   wire [ 3:0]          ARQOS    ;
   wire [ 3:0]          ARREGION ;
   `endif
   wire [WIDTH_SID-1:0] RID      ;
   wire [WIDTH_DA-1:0]  RDATA    ;
   wire [ 1:0]          RRESP    ;
   wire                 RLAST    ;
   wire                 RVALID   ;
   wire                 RREADY   ;
   //---------------------------------------------------------
   wire                  PRESETn  ;
   reg                   PCLK     ;
   wire [WIDTH_PAD-1:0]  PADDR    ;
   wire                  PENABLE  ;
   wire                  PWRITE   ;
   wire [WIDTH_PDA-1:0]  PWDATA   ;
   wire [NUM_PSLAVE-1:0] PSEL     ;
   wire [WIDTH_PDA-1:0]  PRDATA[0:NUM_PSLAVE-1];
   `ifdef AMBA_APB3
   wire [NUM_PSLAVE-1:0] PREADY   ;
   wire [NUM_PSLAVE-1:0] PSLVERR  ;
   `endif
   `ifdef AMBA_APB4
   wire [WIDTH_PDS-1:0]  PSTRB    ;
   wire [ 2:0]           PPROT    ;
   `endif
   //---------------------------------------------------------
   `ifdef NUM_PSLAVE_5
   axi_to_apb_s5
   `elsif NUM_PSLAVE_8
   axi_to_apb_s8
   `elsif NUM_PSLAVE_16
   axi_to_apb_s16
   `else
   ERROR un-defined num of slave
   `endif
                 #(.AXI_WIDTH_CID (WIDTH_CID    )
                  ,.AXI_WIDTH_ID  (WIDTH_ID     )
                  ,.AXI_WIDTH_AD  (WIDTH_AD     )
                  ,.AXI_WIDTH_DA  (WIDTH_DA     )
                  ,.NUM_PSLAVE    (NUM_PSLAVE   )
                  ,.WIDTH_PAD     (WIDTH_PAD    )
                  ,.WIDTH_PDA     (WIDTH_PDA    )
   `ifdef NUM_PSLAVE_5
                  ,.ADDR_PBASE0   (ADDR_PBASE0  ) ,.ADDR_PLENGTH0 (ADDR_PLENGTH0)
                  ,.ADDR_PBASE1   (ADDR_PBASE1  ) ,.ADDR_PLENGTH1 (ADDR_PLENGTH1)
                  ,.ADDR_PBASE2   (ADDR_PBASE2  ) ,.ADDR_PLENGTH2 (ADDR_PLENGTH2)
                  ,.ADDR_PBASE3   (ADDR_PBASE3  ) ,.ADDR_PLENGTH3 (ADDR_PLENGTH3)
                  ,.ADDR_PBASE4   (ADDR_PBASE4  ) ,.ADDR_PLENGTH4 (ADDR_PLENGTH4)
   `elsif NUM_PSLAVE_8
                  ,.ADDR_PBASE0   (ADDR_PBASE0  ) ,.ADDR_PLENGTH0 (ADDR_PLENGTH0)
                  ,.ADDR_PBASE1   (ADDR_PBASE1  ) ,.ADDR_PLENGTH1 (ADDR_PLENGTH1)
                  ,.ADDR_PBASE2   (ADDR_PBASE2  ) ,.ADDR_PLENGTH2 (ADDR_PLENGTH2)
                  ,.ADDR_PBASE3   (ADDR_PBASE3  ) ,.ADDR_PLENGTH3 (ADDR_PLENGTH3)
                  ,.ADDR_PBASE4   (ADDR_PBASE4  ) ,.ADDR_PLENGTH4 (ADDR_PLENGTH4)
                  ,.ADDR_PBASE5   (ADDR_PBASE5  ) ,.ADDR_PLENGTH5 (ADDR_PLENGTH5)
                  ,.ADDR_PBASE6   (ADDR_PBASE6  ) ,.ADDR_PLENGTH6 (ADDR_PLENGTH6)
                  ,.ADDR_PBASE7   (ADDR_PBASE7  ) ,.ADDR_PLENGTH7 (ADDR_PLENGTH7)
   `elsif NUM_PSLAVE_16
                  ,.ADDR_PBASE0   (ADDR_PBASE0  ) ,.ADDR_PLENGTH0 (ADDR_PLENGTH0)
                  ,.ADDR_PBASE1   (ADDR_PBASE1  ) ,.ADDR_PLENGTH1 (ADDR_PLENGTH1)
                  ,.ADDR_PBASE2   (ADDR_PBASE2  ) ,.ADDR_PLENGTH2 (ADDR_PLENGTH2)
                  ,.ADDR_PBASE3   (ADDR_PBASE3  ) ,.ADDR_PLENGTH3 (ADDR_PLENGTH3)
                  ,.ADDR_PBASE4   (ADDR_PBASE4  ) ,.ADDR_PLENGTH4 (ADDR_PLENGTH4)
                  ,.ADDR_PBASE5   (ADDR_PBASE5  ) ,.ADDR_PLENGTH5 (ADDR_PLENGTH5)
                  ,.ADDR_PBASE6   (ADDR_PBASE6  ) ,.ADDR_PLENGTH6 (ADDR_PLENGTH6)
                  ,.ADDR_PBASE7   (ADDR_PBASE7  ) ,.ADDR_PLENGTH7 (ADDR_PLENGTH7)
                  ,.ADDR_PBASE8   (ADDR_PBASE8  ) ,.ADDR_PLENGTH8 (ADDR_PLENGTH8)
                  ,.ADDR_PBASE9   (ADDR_PBASE9  ) ,.ADDR_PLENGTH9 (ADDR_PLENGTH9)
                  ,.ADDR_PBASE10  (ADDR_PBASE10 ) ,.ADDR_PLENGTH10(ADDR_PLENGTH10)
                  ,.ADDR_PBASE11  (ADDR_PBASE11 ) ,.ADDR_PLENGTH11(ADDR_PLENGTH11)
                  ,.ADDR_PBASE12  (ADDR_PBASE12 ) ,.ADDR_PLENGTH12(ADDR_PLENGTH12)
                  ,.ADDR_PBASE13  (ADDR_PBASE13 ) ,.ADDR_PLENGTH13(ADDR_PLENGTH13)
                  ,.ADDR_PBASE14  (ADDR_PBASE14 ) ,.ADDR_PLENGTH14(ADDR_PLENGTH14)
                  ,.ADDR_PBASE15  (ADDR_PBASE15 ) ,.ADDR_PLENGTH15(ADDR_PLENGTH15)
   `else
   `endif
                  )
   Uaxi_to_apb
   (
       .ARESETn            (ARESETn)
     , .ACLK               (ACLK   )
     , .AWID               (AWID   )
     , .AWADDR             (AWADDR )
     , .AWLEN              (AWLEN )
     , .AWLOCK             (AWLOCK)
     , .AWSIZE             (AWSIZE )
     , .AWBURST            (AWBURST)
     `ifdef AMBA_AXI_CACHE
     , .AWCACHE            (AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .AWPROT             (AWPROT )
     `endif
     , .AWVALID            (AWVALID)
     , .AWREADY            (AWREADY)
     `ifdef AMBA_AXI4      
     , .AWQOS              (AWQOS   )
     , .AWREGION           (AWREGION)
     `endif
     , .WID                (WID   )
     , .WDATA              (WDATA )
     , .WSTRB              (WSTRB )
     , .WLAST              (WLAST )
     , .WVALID             (WVALID)
     , .WREADY             (WREADY)
     , .BID                (BID   )
     , .BRESP              (BRESP )
     , .BVALID             (BVALID)
     , .BREADY             (BREADY)
     , .ARID               (ARID  )
     , .ARADDR             (ARADDR)
     , .ARLEN              (ARLEN )
     , .ARLOCK             (ARLOCK)
     , .ARSIZE             (ARSIZE )
     , .ARBURST            (ARBURST)
     `ifdef AMBA_AXI_CACHE
     , .ARCACHE            (ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .ARPROT             (ARPROT )
     `endif
     , .ARVALID            (ARVALID)
     , .ARREADY            (ARREADY)
     `ifdef AMBA_AXI4
     , .ARQOS              (ARQOS   )
     , .ARREGION           (ARREGION)
     `endif
     , .RID                (RID    )
     , .RDATA              (RDATA  )
     , .RRESP              (RRESP  )
     , .RLAST              (RLAST  )
     , .RVALID             (RVALID )
     , .RREADY             (RREADY )
     , .PRESETn            (PRESETn     )
     , .PCLK               (PCLK        )
     , .PADDR              (PADDR       )
     , .PENABLE            (PENABLE     )
     , .PWRITE             (PWRITE      )
     , .PWDATA             (PWDATA      )
     `ifdef NUM_PSLAVE_5
            , .PSEL_0        (PSEL[0]     )
            , .PSEL_1        (PSEL[1]     )
            , .PSEL_2        (PSEL[2]     )
            , .PSEL_3        (PSEL[3]     )
            , .PSEL_4        (PSEL[4]     )
            , .PRDATA_0      (PRDATA[0]   )
            , .PRDATA_1      (PRDATA[1]   )
            , .PRDATA_2      (PRDATA[2]   )
            , .PRDATA_3      (PRDATA[3]   )
            , .PRDATA_4      (PRDATA[4]   )
            `ifdef AMBA_APB3
            , .PREADY_0      (PREADY[0]   )
            , .PREADY_1      (PREADY[1]   )
            , .PREADY_2      (PREADY[2]   )
            , .PREADY_3      (PREADY[3]   )
            , .PREADY_4      (PREADY[4]   )
            , .PSLVERR_0     (PSLVERR[0]  )
            , .PSLVERR_1     (PSLVERR[1]  )
            , .PSLVERR_2     (PSLVERR[2]  )
            , .PSLVERR_3     (PSLVERR[3]  )
            , .PSLVERR_4     (PSLVERR[4]  )
            `endif
     `elsif NUM_PSLAVE_8
            , .PSEL_0        (PSEL[0]     )
            , .PSEL_1        (PSEL[1]     )
            , .PSEL_2        (PSEL[2]     )
            , .PSEL_3        (PSEL[3]     )
            , .PSEL_4        (PSEL[4]     )
            , .PSEL_5        (PSEL[5]     )
            , .PSEL_6        (PSEL[6]     )
            , .PSEL_7        (PSEL[7]     )
            , .PRDATA_0      (PRDATA[0]   )
            , .PRDATA_1      (PRDATA[1]   )
            , .PRDATA_2      (PRDATA[2]   )
            , .PRDATA_3      (PRDATA[3]   )
            , .PRDATA_4      (PRDATA[4]   )
            , .PRDATA_5      (PRDATA[5]   )
            , .PRDATA_6      (PRDATA[6]   )
            , .PRDATA_7      (PRDATA[7]   )
            `ifdef AMBA_APB3
            , .PREADY_0      (PREADY[0]   )
            , .PREADY_1      (PREADY[1]   )
            , .PREADY_2      (PREADY[2]   )
            , .PREADY_3      (PREADY[3]   )
            , .PREADY_4      (PREADY[4]   )
            , .PREADY_5      (PREADY[5]   )
            , .PREADY_6      (PREADY[6]   )
            , .PREADY_7      (PREADY[7]   )
            , .PSLVERR_0     (PSLVERR[0]  )
            , .PSLVERR_1     (PSLVERR[1]  )
            , .PSLVERR_2     (PSLVERR[2]  )
            , .PSLVERR_3     (PSLVERR[3]  )
            , .PSLVERR_4     (PSLVERR[4]  )
            , .PSLVERR_5     (PSLVERR[5]  )
            , .PSLVERR_6     (PSLVERR[6]  )
            , .PSLVERR_7     (PSLVERR[7]  )
            `endif
     `elsif NUM_PSLAVE_16
            , .PSEL_0        (PSEL[ 0]     )
            , .PSEL_1        (PSEL[ 1]     )
            , .PSEL_2        (PSEL[ 2]     )
            , .PSEL_3        (PSEL[ 3]     )
            , .PSEL_4        (PSEL[ 4]     )
            , .PSEL_5        (PSEL[ 5]     )
            , .PSEL_6        (PSEL[ 6]     )
            , .PSEL_7        (PSEL[ 7]     )
            , .PSEL_8        (PSEL[ 8]     )
            , .PSEL_9        (PSEL[ 9]     )
            , .PSEL_10       (PSEL[10]     )
            , .PSEL_11       (PSEL[11]     )
            , .PSEL_12       (PSEL[12]     )
            , .PSEL_13       (PSEL[13]     )
            , .PSEL_14       (PSEL[14]     )
            , .PSEL_15       (PSEL[15]     )
            , .PRDATA_0      (PRDATA[ 0]   )
            , .PRDATA_1      (PRDATA[ 1]   )
            , .PRDATA_2      (PRDATA[ 2]   )
            , .PRDATA_3      (PRDATA[ 3]   )
            , .PRDATA_4      (PRDATA[ 4]   )
            , .PRDATA_5      (PRDATA[ 5]   )
            , .PRDATA_6      (PRDATA[ 6]   )
            , .PRDATA_7      (PRDATA[ 7]   )
            , .PRDATA_8      (PRDATA[ 8]   )
            , .PRDATA_9      (PRDATA[ 9]   )
            , .PRDATA_10     (PRDATA[10]   )
            , .PRDATA_11     (PRDATA[11]   )
            , .PRDATA_12     (PRDATA[12]   )
            , .PRDATA_13     (PRDATA[13]   )
            , .PRDATA_14     (PRDATA[14]   )
            , .PRDATA_15     (PRDATA[15]   )
            `ifdef AMBA_APB3
            , .PREADY_0      (PREADY[ 0]   )
            , .PREADY_1      (PREADY[ 1]   )
            , .PREADY_2      (PREADY[ 2]   )
            , .PREADY_3      (PREADY[ 3]   )
            , .PREADY_4      (PREADY[ 4]   )
            , .PREADY_5      (PREADY[ 5]   )
            , .PREADY_6      (PREADY[ 6]   )
            , .PREADY_7      (PREADY[ 7]   )
            , .PREADY_8      (PREADY[ 8]   )
            , .PREADY_9      (PREADY[ 9]   )
            , .PREADY_10     (PREADY[10]   )
            , .PREADY_11     (PREADY[11]   )
            , .PREADY_12     (PREADY[12]   )
            , .PREADY_13     (PREADY[13]   )
            , .PREADY_14     (PREADY[14]   )
            , .PREADY_15     (PREADY[15]   )
            , .PSLVERR_0     (PSLVERR[ 0]  )
            , .PSLVERR_1     (PSLVERR[ 1]  )
            , .PSLVERR_2     (PSLVERR[ 2]  )
            , .PSLVERR_3     (PSLVERR[ 3]  )
            , .PSLVERR_4     (PSLVERR[ 4]  )
            , .PSLVERR_5     (PSLVERR[ 5]  )
            , .PSLVERR_6     (PSLVERR[ 6]  )
            , .PSLVERR_7     (PSLVERR[ 7]  )
            , .PSLVERR_8     (PSLVERR[ 8]  )
            , .PSLVERR_9     (PSLVERR[ 9]  )
            , .PSLVERR_10    (PSLVERR[10]  )
            , .PSLVERR_11    (PSLVERR[11]  )
            , .PSLVERR_12    (PSLVERR[12]  )
            , .PSLVERR_13    (PSLVERR[13]  )
            , .PSLVERR_14    (PSLVERR[14]  )
            , .PSLVERR_15    (PSLVERR[15]  )
            `endif
     `else
     `endif
     `ifdef AMBA_APB4
     , .PSTRB         (PSTRB       )
     , .PPROT         (PPROT       )
     `endif
   );
   //---------------------------------------------------------
   generate
   genvar ind;
   for (ind=0; ind<NUM_PSLAVE; ind=ind+1) begin : NS
       `ifdef AMBA_APB4
       mem_apb4 #(.AW(WIDTH_PAD), .DW(WIDTH_PDA), .LEN(`ADDR_LENGTH))
       `else
       mem_apb  #(.AW(WIDTH_PAD), .DW(WIDTH_PDA), .LEN(`ADDR_LENGTH))
       `endif
       Umem_apb (
            .PRESETn  (PRESETn     )
          , .PCLK     (PCLK        )
          , .PSEL     (PSEL   [ind])
          , .PENABLE  (PENABLE     )
          , .PADDR    (PADDR       )
          , .PWRITE   (PWRITE      )
          , .PRDATA   (PRDATA [ind])
          , .PWDATA   (PWDATA      )
          `ifdef AMBA_APB3
          , .PREADY   (PREADY [ind])
          , .PSLVERR  (PSLVERR[ind])
          `endif
          `ifdef AMBA_APB4
          , .PSTRB    (PSTRB       )
          , .PPROT    (PPROT       )
          `endif
       );
   end
   endgenerate
   //---------------------------------------------------------
   wire [WIDTH_CID-1:0] M_MID ; // driven by AXI master
   wire [WIDTH_ID-1:0]  M_AWID;
   wire [WIDTH_ID-1:0]  M_WID ;
   wire [WIDTH_ID-1:0]  M_BID ;
   wire [WIDTH_ID-1:0]  M_ARID;
   wire [WIDTH_ID-1:0]  M_RID ;
   assign AWID  = {M_MID,M_AWID};
   assign WID   = {M_MID,M_WID};
   assign ARID  = {M_MID,M_ARID};
   assign M_BID = BID[WIDTH_ID-1:0];
   assign M_RID = RID[WIDTH_ID-1:0];
   //---------------------------------------------------------
   bfm_axi #(.MST_ID   (2        ) // Master ID
               ,.WIDTH_CID(WIDTH_CID)
               ,.WIDTH_ID (WIDTH_ID ) // ID width in bits
               ,.WIDTH_AD (WIDTH_AD ) // address width
               ,.WIDTH_DA (WIDTH_DA ))// data width
   u_bfm_axi (
         .ARESETn           (ARESETn   )
       , .ACLK              (ACLK      )
       , .MID               (M_MID     )
       , .AWID              (M_AWID    )
       , .AWADDR            (AWADDR    )
       , .AWLEN             (AWLEN     )
       , .AWLOCK            (AWLOCK    )
       , .AWSIZE            (AWSIZE    )
       , .AWBURST           (AWBURST   )
       `ifdef AMBA_AXI_CACHE
       , .AWCACHE           (AWCACHE   )
       `endif
       `ifdef AMBA_AXI_PROT
       , .AWPROT            (AWPROT    )
       `endif
       , .AWVALID           (AWVALID   )
       , .AWREADY           (AWREADY   )
       `ifdef AMBA_AXI4
       , .AWQOS             (AWQOS     )
       , .AWREGION          (AWREGION  )
       `endif
       , .WID               (M_WID     )
       , .WDATA             (WDATA     )
       , .WSTRB             (WSTRB     )
       , .WLAST             (WLAST     )
       , .WVALID            (WVALID    )
       , .WREADY            (WREADY    )
       , .BID               (M_BID     )
       , .BRESP             (BRESP     )
       , .BVALID            (BVALID    )
       , .BREADY            (BREADY    )
       , .ARID              (M_ARID    )
       , .ARADDR            (ARADDR    )
       , .ARLEN             (ARLEN     )
       , .ARLOCK            (ARLOCK    )
       , .ARSIZE            (ARSIZE    )
       , .ARBURST           (ARBURST   )
       `ifdef AMBA_AXI_CACHE
       , .ARCACHE           (ARCACHE   )
       `endif
       `ifdef AMBA_AXI_PROT
       , .ARPROT            (ARPROT    )
       `endif
       , .ARVALID           (ARVALID   )
       , .ARREADY           (ARREADY   )
       `ifdef AMBA_AXI4
       , .ARQOS             (ARQOS     )
       , .ARREGION          (ARREGION  )
       `endif
       , .RID               (M_RID     )
       , .RDATA             (RDATA     )
       , .RRESP             (RRESP     )
       , .RLAST             (RLAST     )
       , .RVALID            (RVALID    )
       , .RREADY            (RREADY    )
       , .CSYSREQ           (1'b0      )
       , .CSYSACK           (          )
       , .CACTIVE           (          )
   );
   //---------------------------------------------------------
   always #5 ACLK <= ~ACLK;
   always #7 PCLK <= ~PCLK;
   assign    PRESETn = ARESETn;
   initial begin
       ACLK     = 0; PCLK    = 0;
       ARESETn  = 0;
       repeat (3) @ (negedge ACLK);
       ARESETn = 1;
       repeat (3) @ (negedge ACLK);
       //---------------------------------------------------------
       wait(u_bfm_axi.DONE==1'b1);
       $finish(2);
   end
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpvars(0);
   end
   `endif
   //----------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
     tmp = value - 1;
     for (clogb2=0; tmp>0; clogb2=clogb2+1) tmp = tmp>>1;
   end
   endfunction
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.01.01: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
