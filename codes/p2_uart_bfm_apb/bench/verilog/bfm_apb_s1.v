//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// bfm_apb_s1.v
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
`timescale 1ns/1ns

module bfm_apb_s1
     #(parameter P_ADDR_START0 = 16'h0000, P_ADDR_SIZE0 = 16'h0010)
(
       input   wire         PRESETn
     , input   wire         PCLK
     , output  reg          PSEL
     , output  reg   [31:0] PADDR
     , output  reg          PENABLE
     , output  reg          PWRITE
     , output  reg   [31:0] PWDATA
     , input   wire  [31:0] PRDATA0
);
    //----------------------------------------------------
     `ifndef AMBA3
     wire  PREADY  = 1'b1;
     wire  PSLVERR = 1'b0;
     `endif
     `ifndef AMBA4
     reg   [ 2:0]  PPROT;
     reg   [ 3:0]  PSTRB;
     `endif
    //----------------------------------------------------
    reg [31:0] freq;
    real stamp_x, stamp_y, delta;
    initial begin
        PSEL     =   1'b0;
        PADDR    = ~32'h0;
        PENABLE  =   1'b0;
        PWRITE   =   1'b0;
        PWDATA   = ~32'h0;
        PPROT    =   3'h0;
        PSTRB    =   4'h0;
        wait  (PRESETn==1'b0);
        wait  (PRESETn==1'b1);
        @ (posedge PCLK);
        @ (posedge PCLK); stamp_x = $time;
        @ (posedge PCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge PCLK); $display("%m PCLK %f nsec %f Mhz", delta, 1000.0/delta);
        freq = 1000000000/delta;
        repeat (3) @ (posedge PCLK);
        uart_test(freq, 115200);
        repeat (5) @ (posedge PCLK);
        $finish(2);
    end
    //----------------------------------------------------
    integer  err;
    //----------------------------------------------------
    task uart_test;
         input [31:0] freq;
         input [31:0] baud;
         reg [7:0] dat;
         integer idx;
    begin
        err = 0;
        //------------------------------------------------
        init_uart( freq // input [31:0] frea;
                 , baud // input [31:0] baud
        );
        //------------------------------------------------
        for (idx="A"; idx<="Z"; idx = idx + 1) begin
            send_a_character(idx[7:0]);
            receive_a_character(dat);
	    if (dat>=8'h20&&dat<=8'h7E)
                 $display($time,,"%m 0x%x(%c) received!", dat, dat);
            else
                 $display($time,,"%m 0x%x  received!", dat);
            if (idx[7:0]!==dat) begin
               err = err + 1;
               $display($time,,"%m ERROR 0x%x received, but 0x%x expected",
                               dat, idx[7:0]);
            end
        end
        //------------------------------------------------
        if (err==0) $display($time,,"%m test OK");
    end
    endtask
    //----------------------------------------------------
    `include "bfm_apb_tasks_s1.v"
    `include "uart_apb_tasks.v"
    //----------------------------------------------------
endmodule

//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
