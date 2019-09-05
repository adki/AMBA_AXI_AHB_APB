//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// bmp_handle.v
//--------------------------------------------------------

integer   bmp_file; // file descriptor
integer   bmp_file_en; // file descriptor
integer   bmp_file_de; // file descriptor
reg [7:0] bmp_file_header[0:13]; // 14-byte
reg [7:0] bmp_img_header [0:39]; // 40-byte
integer   bmp_code;
//--------------------------------------------------------
integer   bfOffBits; // offset ot bitmap data
integer   biWidth; // image width
integer   biHeight; // image heigh
integer   biBitCount; // num of bits per pixel
integer   biSizeImage; // size of image data
//--------------------------------------------------------
reg [7:0] pBitMap[0:640*480-1]; // RGB

//--------------------------------------------------------
task bmp_read;
input  integer fd;
output integer code;
integer num;
begin
     bmp_read_file_header(fd, code);
     $write("bmp_file_header");
     for (num=0; num<14; num=num+1) begin
          $write(":%02x", bmp_file_header[num]);
     end
     $write("\n");
     bmp_read_img_header(fd, code);
     $write("bmp_img_header");
     for (num=0; num<40; num=num+1) begin
          $write(":%02x", bmp_img_header[num]);
     end
     $write("\n");
     $display("bfOffBits  = %d offset ot bitmap data",bfOffBits  );
     $display("biWidth    = %d image width          ",biWidth    );
     $display("biHeight   = %d image heigh          ",biHeight   );
     $display("biBitCount = %d num of bits per pixel",biBitCount );
     $display("biSizeImage= %d size of image data   ",biSizeImage);
     bmp_read_rgb(fd, bfOffBits, biSizeImage, code);
end
endtask

//--------------------------------------------------------
task bmp_read_file_header;
input  integer fd;
output integer code;
begin
    code = $fseek(fd, 0, 0); // $frewind(fp);
    code = $fread(bmp_file_header, fd, 0, 14);
    if ((bmp_file_header[0]!=8'h42)|| // 'B'
        (bmp_file_header[1]!=8'h4d)) begin // 'M'
        $display($time,,"%m not BMP file");
    end
    bfOffBits = (bmp_file_header[13]<<24)
              | (bmp_file_header[12]<<16)
              | (bmp_file_header[11]<<8)
              | (bmp_file_header[10]);
end
endtask

//--------------------------------------------------------
// It reads 40-bytes from position 14.
task bmp_read_img_header;
input  integer fd;
output integer code;
integer pos;
integer header_size;
begin
    pos  = $ftell(fd);
    if (pos!=14) code = $fseek(fd, 14, 0);
    code = $fread(bmp_img_header, fd, 0, 40);
    header_size = (bmp_img_header[3]<<24)
                | (bmp_img_header[2]<<16)
                | (bmp_img_header[1]<<8)
                | (bmp_img_header[0]);    
    if (header_size!=40) begin
        $display($time,,"%m BMP image header size mis-match %d, but 40 expected", header_size);
    end
    biWidth     = (bmp_img_header[ 7]<<24)
                | (bmp_img_header[ 6]<<16)
                | (bmp_img_header[ 5]<<8)
                | (bmp_img_header[ 4]);    
    biHeight    = (bmp_img_header[11]<<24)
                | (bmp_img_header[10]<<16)
                | (bmp_img_header[ 9]<<8)
                | (bmp_img_header[ 8]);    
    biBitCount  = (bmp_img_header[15]<<8)
                | (bmp_img_header[14]);    
    biSizeImage = (bmp_img_header[23]<<24)
                | (bmp_img_header[22]<<16)
                | (bmp_img_header[21]<<8)
                | (bmp_img_header[20]);    
    if (biBitCount!=24) begin
        $display($time, "%m %d-bpp, but 24-bpp expected", biBitCount);
    end
    if ((biWidth*biHeight*(biBitCount/8))!=biSizeImage) begin
        $display($time,,"%m image size mis-match %d, but %d expected",
                biSizeImage, (biWidth*biHeight*(biBitCount/8)));
    end
    if (biSizeImage>(640*480)) begin
        $display($time,,"%m image size exceed");
    end
end
endtask

//--------------------------------------------------------
// It reads pixel data.
task bmp_read_rgb;
input  integer fd;
input  integer pos;
input  integer sze;
output integer code;
begin
    code = $fseek(fd, pos, 0);
    code = $fread(pBitMap, fd, 0, sze);
end
endtask

//--------------------------------------------------------
task bmp_write;
input  integer fd;
output integer code;
integer num;
integer pos;
begin
    $fwriteb(fd, "%u", {bmp_file_header[ 3],
                        bmp_file_header[ 2],
                        bmp_file_header[ 1],
                        bmp_file_header[ 0]});
    $fwriteb(fd, "%u", {bmp_file_header[ 7],
                        bmp_file_header[ 6],
                        bmp_file_header[ 5],
                        bmp_file_header[ 4]});
    $fwriteb(fd, "%u", {bmp_file_header[11],
                        bmp_file_header[10],
                        bmp_file_header[ 9],
                        bmp_file_header[ 8]});
    $fwriteb(fd, "%u", {bmp_img_header [ 1],
                        bmp_img_header [ 0],
                        bmp_file_header[13],
                        bmp_file_header[12]});
    for (num=2; num<38; num=num+4) begin
    $fwriteb(fd, "%u", {bmp_img_header [num+3],
                        bmp_img_header [num+2],
                        bmp_img_header [num+1],
                        bmp_img_header [num  ]});
    end
    $fwriteb(fd, "%u", {pBitMap [ 1],
                        pBitMap [ 0],
                        bmp_img_header [39],
                        bmp_img_header [38]});
    for (num=2; num<biSizeImage; num=num+4) begin
    $fwriteb(fd, "%u", {pBitMap [num+3],
                        pBitMap [num+2],
                        pBitMap [num+1],
                        pBitMap [num  ]});
    end
end
endtask

//--------------------------------------------------------
// Revision history:
//
// 2013.07.10.: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
