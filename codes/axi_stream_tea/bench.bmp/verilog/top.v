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
  reg          clk    = 1'b0;
  reg          resetn = 1'b0;
  wire [127:0] key = `TEA_KEY;

  //----------------------------------------
  wire [63:0] en_textI    , en_textO    ;
  wire        en_textI_vld, en_textO_vld;

  //----------------------------------------
  wire [63:0] de_textI    , de_textO    ;
  wire        de_textI_vld, de_textO_vld;

  //----------------------------------------
  bmp_stimulus_file u_stimulus (
           .resetn(resetn)
         , .clk     (clk         )
         , .rgb     (en_textI    )
         , .rgb_vld (en_textI_vld)
         , .en_rgb     (en_textO    )
         , .en_rgb_vld (en_textO_vld)
         , .de_rgb     (de_textO    )
         , .de_rgb_vld (de_textO_vld)
  );

  //----------------------------------------
  tea_encryptor_core
  u_encryptor(
        .resetn    (resetn   )
       ,.clk       (clk      )
       ,.key       (key      )
       ,.textI     (en_textI    )
       ,.textI_vld (en_textI_vld)
       ,.textO     (en_textO    )
       ,.textO_vld (en_textO_vld)
       );

  //----------------------------------------
  assign de_textI_vld = en_textO_vld;
  assign de_textI     = en_textO    ;

  //----------------------------------------
  tea_decryptor_core
  u_decryptor(
        .resetn    (resetn   )
       ,.clk       (clk      )
       ,.key       (key      )
       ,.textI     (de_textI    )
       ,.textI_vld (de_textI_vld)
       ,.textO     (de_textO    )
       ,.textO_vld (de_textO_vld)
       );

  //----------------------------------------
  // check (compare) the result of decryption
  // and the input of encryption
  check
  u_check(
        .resetn   (resetn      )
       ,.clk      (clk         )
       ,.textI    (en_textI    )
       ,.textI_vld(en_textI_vld)
       ,.textO    (de_textO    )
       ,.textO_vld(de_textO_vld)
       );

  //--------------------------------------------------
  // clock generator
  initial clk <= 1'b0;
  always  #10 clk <= ~clk;
  initial begin // reset generator
          resetn <= 1'b0;
          repeat (3) @ (posedge clk);
          resetn <= 1'b1;
  end

  //--------------------------------------------------
  `ifdef VCD
  initial begin
          $dumpfile("wave.vcd"); //$dumplimit(10000000);
          $dumpvars(0);
  end
  `endif
endmodule
//-------------------------------------------------------
// Revision history
//
// 2015.07.10: Re-written by Ando Ki (adki@dynalith.com)
//-------------------------------------------------------
