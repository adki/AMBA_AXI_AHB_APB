//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`timescale 1ns/1ns

module bmp_stimulus_stream
     #(parameter STREAM_WIDTH_DATA=64
               , STREAM_WIDTH_DS=(STREAM_WIDTH_DATA/8)
               , STREAM_WIDTH_TID=8
               , STREAM_WIDTH_TDEST=3
               , STREAM_WIDTH_TUSER=1
       )
(
       input   wire                           ARESETn
     , input   wire                           ACLK
     //----------------------------------------------------
     , input   wire                           M_TREADY
     , output  reg                            M_TVALID=1'b0
     , output  reg   [STREAM_WIDTH_DATA-1:0]  M_TDATA='h0
     , output  reg   [STREAM_WIDTH_DS-1:0]    M_TSTRB='h0
     , output  reg   [STREAM_WIDTH_DS-1:0]    M_TKEEP='h0
     , output  reg                            M_TLAST=1'b0
     , output  reg   [STREAM_WIDTH_TID-1:0]   M_TID='h0
     , output  reg   [STREAM_WIDTH_TDEST-1:0] M_TDEST='h0
     `ifdef AMBA_AXI_TUSER
     , output  reg   [STREAM_WIDTH_TUSER-1:0] M_TUSER='h0
     `endif
     //--------------------------------------------------
     , input   wire                           en_rgb_vld
     , input   wire  [STREAM_WIDTH_DATA-1:0]  en_rgb
     //--------------------------------------------------
     , input   wire                           de_rgb_vld
     , input   wire  [STREAM_WIDTH_DATA-1:0]  de_rgb
     //--------------------------------------------------
);
    //---------------------------------------------
    `include "bmp_handle.v"
    //---------------------------------------------
    localparam bmp_file_name="face_320x240.bmp";
    localparam bmp_file_name_en="face_320x240_en.bmp";
    localparam bmp_file_name_de="face_320x240_de.bmp";
    //-----------------------------------------------------
    reg [7:0] RGB    [0:640*480-1]; // RGB org
    reg [7:0] RGB_en [0:640*480-1]; // RGB encrypted
    reg [7:0] RGB_de [0:640*480-1]; // RGB decrypted
    //---------------------------------------------
    integer num, idx;
    integer lpf, ppl;
    integer num_en, num_de;
    //---------------------------------------------
    initial begin
        M_TVALID = 1'b0;
        M_TDATA  = 64'b0;
        while (ARESETn==1'b0) @ (ACLK);
        while (ARESETn==1'b1) @ (ACLK);
        repeat (4) @ (posedge ACLK);
        //-------------------------------------------------
        bmp_file = $fopen(bmp_file_name, "rb");
        if (bmp_file==0) begin
            $display($time,,"%m %s cannot open", bmp_file_name);
            $finish(2);
        end
        bmp_read(bmp_file, bmp_code);
        $fclose(bmp_file);
       //-------------------------------------------------
       for (num=0; num<biSizeImage; num=num+1) begin
            // copy original RGB
            RGB[num] = pBitMap[num];
       end
       //-------------------------------------------------
       @ (posedge ACLK);
       fork
       begin
         for (lpf=0; lpf<biHeight; lpf=lpf+1) begin
              M_TID <= M_TID+1;
              num = lpf*biWidth*biBitCount/8;
              for (ppl=0; ppl<(biWidth*3); ppl=ppl+8) begin
                   // note that each pixel consists of 3-byte
                   idx = num + ppl;
                   M_TDATA[63:32]  <= {RGB[idx+7],RGB[idx+6],RGB[idx+5],RGB[idx+4]};
                   M_TDATA[31: 0]  <= {RGB[idx+3],RGB[idx+2],RGB[idx+1],RGB[idx]};
                   M_TLAST         <= ((ppl+8)==(biWidth*3)) ? 1'b1 : 1'b0;
                   M_TVALID        <= #1 1'b1;
                   @ (posedge ACLK);
                   while (M_TREADY==1'b0) @ (posedge ACLK);
                   M_TLAST         <= 1'b0;
              end
              M_TVALID <= #1 1'b0;
              @ (posedge ACLK);
         end
       end
       begin
          for (num_en=0; num_en<biSizeImage; num_en=num_en+8) begin
               while (en_rgb_vld==1'b0) @ (posedge ACLK);
               RGB_en[num_en  ] <= en_rgb[ 7: 0];
               RGB_en[num_en+1] <= en_rgb[15: 8];
               RGB_en[num_en+2] <= en_rgb[23:16];
               RGB_en[num_en+3] <= en_rgb[31:24];
               RGB_en[num_en+4] <= en_rgb[39:32];
               RGB_en[num_en+5] <= en_rgb[47:40];
               RGB_en[num_en+6] <= en_rgb[55:48];
               RGB_en[num_en+7] <= en_rgb[63:56];
               @ (posedge ACLK);
          end
       end
       begin
          for (num_de=0; num_de<biSizeImage; num_de=num_de+8) begin
               while (de_rgb_vld==1'b0) @ (posedge ACLK);
               RGB_de[num_de  ] <= de_rgb[ 7: 0];
               RGB_de[num_de+1] <= de_rgb[15: 8];
               RGB_de[num_de+2] <= de_rgb[23:16];
               RGB_de[num_de+3] <= de_rgb[31:24];
               RGB_de[num_de+4] <= de_rgb[39:32];
               RGB_de[num_de+5] <= de_rgb[47:40];
               RGB_de[num_de+6] <= de_rgb[55:48];
               RGB_de[num_de+7] <= de_rgb[63:56];
               @ (posedge ACLK);
          end
       end
       join
       //-------------------------------------------------
       for (num=0; num<biSizeImage; num=num+1) begin
            // copy original RGB
            pBitMap[num] = RGB_en[num];
       end
       //-------------------------------------------------
       bmp_file_en = $fopen(bmp_file_name_en, "wb");
       if (bmp_file_en==0) begin
           $display($time,,"%m %s cannot open", bmp_file_name_en);
           $finish(2);
       end
       bmp_write(bmp_file_en, bmp_code);
       $fclose(bmp_file_en);
       //-------------------------------------------------
       for (num=0; num<biSizeImage; num=num+1) begin
            // copy original RGB
            pBitMap[num] = RGB_de[num];
       end
       //-------------------------------------------------
       bmp_file_de = $fopen(bmp_file_name_de, "wb");
       if (bmp_file_de==0) begin
           $display($time,,"%m %s cannot open", bmp_file_name_de);
           $finish(2);
       end
       bmp_write(bmp_file_de, bmp_code);
       $fclose(bmp_file_de);
       //-------------------------------------------------
       repeat (10) @ (posedge ACLK);
       $finish(2);
    end
endmodule
