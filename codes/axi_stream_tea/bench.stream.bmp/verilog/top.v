//-------------------------------------------------------
// Copyright (c) 2015 by Ando Ki
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
`timescale 1ns/1ns

`define TEA_KEY 128'hABAB_ABAB_ABAB_ABAB_ABAB_ABAB_ABAB_ABAB

module top;
  //-----------------------------------------------------
  localparam STREAM_WIDTH_DATA=64
           , STREAM_WIDTH_DS=(STREAM_WIDTH_DATA/8)
           , STREAM_WIDTH_TID=8
           , STREAM_WIDTH_TDEST=3
           , STREAM_WIDTH_TUSER=1;

  //-----------------------------------------------------
  reg          ACLK   = 1'b0;
  reg          ARESETn= 1'b0;

  //--------------------------------------------------
  wire                           en_S_TREADY, de_S_TREADY;
  wire                           en_S_TVALID, de_S_TVALID;
  wire  [STREAM_WIDTH_DATA-1:0]  en_S_TDATA , de_S_TDATA ;
  wire  [STREAM_WIDTH_DS-1:0]    en_S_TSTRB , de_S_TSTRB ;
  wire  [STREAM_WIDTH_DS-1:0]    en_S_TKEEP , de_S_TKEEP ;
  wire                           en_S_TLAST , de_S_TLAST ;
  wire  [STREAM_WIDTH_TID-1:0]   en_S_TID   , de_S_TID   ;
  wire  [STREAM_WIDTH_TDEST-1:0] en_S_TDEST , de_S_TDEST ;
  `ifdef AMBA_AXI_TUSER
  wire  [STREAM_WIDTH_TUSER-1:0] en_S_TUSER , de_S_TUSER ;
  `endif

  //----------------------------------------------------
  wire                           en_M_TREADY, de_M_TREADY;
  wire                           en_M_TVALID, de_M_TVALID;
  wire  [STREAM_WIDTH_DATA-1:0]  en_M_TDATA , de_M_TDATA ;
  wire  [STREAM_WIDTH_DS-1:0]    en_M_TSTRB , de_M_TSTRB ;
  wire  [STREAM_WIDTH_DS-1:0]    en_M_TKEEP , de_M_TKEEP ;
  wire                           en_M_TLAST , de_M_TLAST ;
  wire  [STREAM_WIDTH_TID-1:0]   en_M_TID   , de_M_TID   ;
  wire  [STREAM_WIDTH_TDEST-1:0] en_M_TDEST , de_M_TDEST ;
  `ifdef AMBA_AXI_TUSER
  wire  [STREAM_WIDTH_TUSER-1:0] en_M_TUSER , de_M_TUSER ;
  `endif

  //----------------------------------------
  bmp_stimulus_stream
  u_stimulus (
       .ARESETn  (ARESETn    )
     , .ACLK     (ACLK       )
     , .M_TREADY (en_S_TREADY)
     , .M_TVALID (en_S_TVALID)
     , .M_TDATA  (en_S_TDATA )
     , .M_TSTRB  (en_S_TSTRB )
     , .M_TKEEP  (en_S_TKEEP )
     , .M_TLAST  (en_S_TLAST )
     , .M_TID    (en_S_TID   )
     , .M_TDEST  (en_S_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .M_TUSER  (en_S_TUSER)
     `endif
     , .en_rgb     (en_M_TDATA             )
     , .en_rgb_vld (en_M_TVALID&en_M_TREADY)
     , .de_rgb     (de_M_TDATA             )
     , .de_rgb_vld (de_M_TVALID&de_M_TREADY)
  );

  //----------------------------------------
  tea_encryptor_stream
  u_encryptor(
       .ARESETn  (ARESETn    )
     , .ACLK     (ACLK       )
     , .S_TREADY (en_S_TREADY)
     , .S_TVALID (en_S_TVALID)
     , .S_TDATA  (en_S_TDATA )
     , .S_TSTRB  (en_S_TSTRB )
     , .S_TKEEP  (en_S_TKEEP )
     , .S_TLAST  (en_S_TLAST )
     , .S_TID    (en_S_TID   )
     , .S_TDEST  (en_S_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .S_TUSER  (en_S_TUSER )
     `endif
     , .M_TREADY (en_M_TREADY)
     , .M_TVALID (en_M_TVALID)
     , .M_TDATA  (en_M_TDATA )
     , .M_TSTRB  (en_M_TSTRB )
     , .M_TKEEP  (en_M_TKEEP )
     , .M_TLAST  (en_M_TLAST )
     , .M_TID    (en_M_TID   )
     , .M_TDEST  (en_M_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .M_TUSER  (en_M_TUSER )
     `endif
  );

  //----------------------------------------
  assign en_M_TREADY = de_S_TREADY;
  assign de_S_TVALID = en_M_TVALID;
  assign de_S_TDATA  = en_M_TDATA ;
  assign de_S_TSTRB  = en_M_TSTRB ;
  assign de_S_TKEEP  = en_M_TKEEP ;
  assign de_S_TLAST  = en_M_TLAST ;
  assign de_S_TID    = en_M_TID   ;
  assign de_S_TDEST  = en_M_TDEST ;
  `ifdef AMBA_AXI_TUSER
  assign de_S_TUSER  = en_M_TUSER ;
  `endif

  //----------------------------------------
  tea_decryptor_stream
  u_decryptor(
       .ARESETn  (ARESETn    )
     , .ACLK     (ACLK       )
     , .S_TREADY (de_S_TREADY)
     , .S_TVALID (de_S_TVALID)
     , .S_TDATA  (de_S_TDATA )
     , .S_TSTRB  (de_S_TSTRB )
     , .S_TKEEP  (de_S_TKEEP )
     , .S_TLAST  (de_S_TLAST )
     , .S_TID    (de_S_TID   )
     , .S_TDEST  (de_S_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .S_TUSER  (de_S_TUSER )
     `endif
     , .M_TREADY (de_M_TREADY)
     , .M_TVALID (de_M_TVALID)
     , .M_TDATA  (de_M_TDATA )
     , .M_TSTRB  (de_M_TSTRB )
     , .M_TKEEP  (de_M_TKEEP )
     , .M_TLAST  (de_M_TLAST )
     , .M_TID    (de_M_TID   )
     , .M_TDEST  (de_M_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .M_TUSER  (de_M_TUSER )
     `endif
  );

  //----------------------------------------
  assign de_M_TREADY=ARESETn;

  //----------------------------------------
  // check (compare) the result of decryption
  // and the input of encryption
  check_stream
  u_check(
       .ARESETn  (ARESETn    )
     , .ACLK     (ACLK       )
     , .en_S_TREADY (en_S_TREADY)
     , .en_S_TVALID (en_S_TVALID)
     , .en_S_TDATA  (en_S_TDATA )
     , .en_S_TSTRB  (en_S_TSTRB )
     , .en_S_TKEEP  (en_S_TKEEP )
     , .en_S_TLAST  (en_S_TLAST )
     , .en_S_TID    (en_S_TID   )
     , .en_S_TDEST  (en_S_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .en_S_TUSER  (en_S_TUSER )
     `endif
     , .de_S_TREADY (de_M_TREADY)
     , .de_S_TVALID (de_M_TVALID)
     , .de_S_TDATA  (de_M_TDATA )
     , .de_S_TSTRB  (de_M_TSTRB )
     , .de_S_TKEEP  (de_M_TKEEP )
     , .de_S_TLAST  (de_M_TLAST )
     , .de_S_TID    (de_M_TID   )
     , .de_S_TDEST  (de_M_TDEST )
     `ifdef AMBA_AXI_TUSER
     , .de_S_TUSER  (de_M_TUSER )
     `endif
  );

  //--------------------------------------------------
  // clock generator
  initial ACLK <= 1'b0;
  always  #10 ACLK <= ~ACLK;
  initial begin // reset generator
          ARESETn <= 1'b0;
          repeat (3) @ (posedge ACLK);
          ARESETn <= 1'b1;
  end

  //--------------------------------------------------
  `ifdef VCD
   initial begin
           $dumpfile("wave.vcd"); //$dumplimit(1000000);
           $dumpvars(0);
   end
  `endif
endmodule
//-------------------------------------------------------
// Revision history
//
// 2015.07.10: Re-written by Ando Ki (adki@dynalith.com)
//-------------------------------------------------------
