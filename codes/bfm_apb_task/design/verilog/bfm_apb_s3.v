//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// bfm_apb_s3.v
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifdef AMBA4
`ifndef AMBA3
ERROR AMBA3 shouldb edefined when AMBA4 is defined
`endif 
`endif

module bfm_apb_s3
     #(parameter P_DWIDTH=32
               , P_STRB  =(P_DWIDTH/8)
               , P_NUM=3
               , P_ADDR_START0 = 16'h0000, P_ADDR_SIZE0 = 16'h0010
               , P_ADDR_START1 = 16'h1000, P_ADDR_SIZE1 = 16'h0010
               , P_ADDR_START2 = 16'h2000, P_ADDR_SIZE2 = 16'h0010)
(
       input   wire                 PRESETn
     , input   wire                 PCLK
     , output  reg   [P_NUM-1:0]    PSEL
     , output  reg   [31:0]         PADDR
     , output  reg                  PENABLE
     , output  reg                  PWRITE
     , output  reg   [P_DWIDTH-1:0] PWDATA
     , input   wire  [P_DWIDTH-1:0] PRDATA0
     , input   wire  [P_DWIDTH-1:0] PRDATA1
     , input   wire  [P_DWIDTH-1:0] PRDATA2
     `ifdef AMBA3
     , input   wire  [P_NUM-1:0]    PREADY
     , input   wire  [P_NUM-1:0]    PSLVERR
     `endif
     `ifdef AMBA4
     , output  reg   [ 2:0]         PPROT
     , output  reg   [P_STRB-1:0]   PSTRB
     `endif
);
    //----------------------------------------------------
     `ifndef AMBA3
     wire  [P_NUM-1:0]    PREADY  = {P_NUM{1'b1}};
     wire  [P_NUM-1:0]    PSLVERR = {P_NUM{1'b0}};
     `endif
     `ifndef AMBA4
     reg   [ 2:0]         PPROT;
     reg   [P_STRB-1:0]   PSTRB;
     `endif
    //----------------------------------------------------
    initial begin
        PSEL     = {P_NUM{1'b0}};
        PADDR    = ~32'h0;
        PENABLE  =   1'b0;
        PWRITE   =   1'b0;
        PWDATA   = {P_DWIDTH{1'b1}};
        PPROT    =   3'h0;
        PSTRB    = {P_STRB{1'b0}};
        wait  (PRESETn==1'b0);
        wait  (PRESETn==1'b1);
        repeat (3) @ (posedge PCLK);
        memory_test({P_ADDR_START0,16'h0}, {P_ADDR_START0,16'h0}+32'h10-1, 4);
        memory_test({P_ADDR_START1,16'h0}, {P_ADDR_START1,16'h0}+32'h10-1, 4);
        memory_test({P_ADDR_START2,16'h0}, {P_ADDR_START2,16'h0}+32'h10-1, 4);
        repeat (5) @ (posedge PCLK);
        $finish(2);
    end
    //----------------------------------------------------
    reg [P_DWIDTH-1:0] reposit[0:1023];
    //----------------------------------------------------
    task memory_test;
    input [31:0] start ; // starting address
    input [31:0] finish; // ending address, inclusive
    input [ 2:0] size  ; // num of byte to access
    reg   [P_DWIDTH-1:0] dataW, dataR;
    integer a, b, err;
    begin
        err = 0;
        //------------------------------------------------
        // read-after-write test
        for (a=start; a<=(finish-size); a=a+size) begin
             dataW = $random;
             apb_write(a, dataW, size);
             apb_read (a, dataR, size);
             if (dataR!==dataW) begin
                 err = err + 1;
                 $display($time,,"%m RAW error at A:0x%08x D:0x%x, but 0x%x expected",
                                  a, dataR, dataW);
             end
        end
        if (err==0) $display($time,,"%m RAW 0x%x-%x test OK", start, finish);
        err = 0;
        //------------------------------------------------
        // read_all-after-write_all test
        for (a=start; a<=(finish-size); a=a+size) begin
             b = a - start;
             reposit[b] = $random;
             apb_write(a, reposit[b], size);
        end
        for (a=start; a<=(finish-size); a=a+size) begin
             b = a - start;
             apb_read(a, dataR, size);
             if (dataR!==reposit[b]) begin
                 err = err + 1;
                 $display($time,,"%m RAAWA error at A:0x%08x D:0x%x, but 0x%x expected",
                                  a, dataR, reposit[b]);
             end
        end
        if (err==0) $display($time,,"%m RAAWA 0x%x-%x test OK", start, finish);
    end
    endtask
    //----------------------------------------------------
    `include "bfm_apb_tasks.v"
    //----------------------------------------------------
endmodule

//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
