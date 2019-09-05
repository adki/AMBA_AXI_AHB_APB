//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
`timescale 1ns/1ns

module bmp_stimulus_file (
       input   wire         resetn
     , input   wire         clk
     , output  reg   [63:0] rgb=64'h0
     , output  reg          rgb_vld=1'b0
     , input   wire  [63:0] en_rgb
     , input   wire         en_rgb_vld
     , input   wire  [63:0] de_rgb
     , input   wire         de_rgb_vld
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
    integer num, num_en, num_de;
    //---------------------------------------------
    initial begin
        rgb_vld = 1'b0;
        rgb     = 64'b0;
        while (resetn==1'b1) @ (clk);
        while (resetn==1'b0) @ (clk);
        repeat (2) @ (posedge clk);
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
       @ (posedge clk);
       fork
       begin
         for (num=0; num<biSizeImage; num=num+8) begin
              rgb[63:32]  <= {RGB[num+7],RGB[num+6],RGB[num+5],RGB[num+4]};
              rgb[31: 0]  <= {RGB[num+3],RGB[num+2],RGB[num+1],RGB[num]};
              rgb_vld     <= #1 1'b1;
              @ (posedge clk);
         end
         @ (posedge clk);
         rgb_vld <= #1 1'b0;
       end
       begin
          for (num_en=0; num_en<biSizeImage; num_en=num_en+8) begin
               while (en_rgb_vld==1'b0) @ (posedge clk);
               RGB_en[num_en  ] <= en_rgb[ 7: 0];
               RGB_en[num_en+1] <= en_rgb[15: 8];
               RGB_en[num_en+2] <= en_rgb[23:16];
               RGB_en[num_en+3] <= en_rgb[31:24];
               RGB_en[num_en+4] <= en_rgb[39:32];
               RGB_en[num_en+5] <= en_rgb[47:40];
               RGB_en[num_en+6] <= en_rgb[55:48];
               RGB_en[num_en+7] <= en_rgb[63:56];
               @ (posedge clk);
          end
       end
       begin
          for (num_de=0; num_de<biSizeImage; num_de=num_de+8) begin
               while (de_rgb_vld==1'b0) @ (posedge clk);
               RGB_de[num_de  ] <= de_rgb[ 7: 0];
               RGB_de[num_de+1] <= de_rgb[15: 8];
               RGB_de[num_de+2] <= de_rgb[23:16];
               RGB_de[num_de+3] <= de_rgb[31:24];
               RGB_de[num_de+4] <= de_rgb[39:32];
               RGB_de[num_de+5] <= de_rgb[47:40];
               RGB_de[num_de+6] <= de_rgb[55:48];
               RGB_de[num_de+7] <= de_rgb[63:56];
               @ (posedge clk);
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
       repeat (10) @ (posedge clk);
       $finish(2);
    end
endmodule
