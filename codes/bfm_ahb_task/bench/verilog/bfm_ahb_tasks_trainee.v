`ifndef _BFM_AHB_TASKS_V_
`define _BFM_AHB_TASKS_V_
//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// bfm_ahb_tasks.h
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
task ahb_read;
input  [31:0] address;
input  [ 2:0] size;
output [31:0] data;
begin
    ... fill
end
endtask

//-----------------------------------------------------
task ahb_write;
input  [31:0] address;
input  [ 2:0] size;
input  [31:0] data;
begin
    ... fill
end
endtask
//-------------------------------------------------------------
task ahb_read_burst;
     input  [31:0] addr;
     input  [31:0] leng;
     integer       i, ln, k;
begin
    k = 0;
    @ (posedge HCLK);
    HBUSREQ <= #1 1'b1;
    @ (posedge HCLK);
    while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
    HADDR  <= #1 addr; addr = addr + 4;
    HTRANS <= #1 2'b10; //`HTRANS_NONSEQ;
    if (leng>=16)     begin HBURST <= #1 3'b111; ln=16; end //`HBURST_INCR16;
    else if (leng>=8) begin HBURST <= #1 3'b101; ln= 8; end //`HBURST_INCR8;
    else if (leng>=4) begin HBURST <= #1 3'b011; ln= 4; end //`HBURST_INCR4;
    else              begin HBURST <= #1 3'b001; ln=leng; end //`HBURST_INCR;
    HWRITE <= #1 1'b0; //`HWRITE_READ;
    HSIZE  <= #1 3'b010; //`HSIZE_WORD;
    @ (posedge HCLK);
    while (HREADY==1'b0) @ (posedge HCLK);
    while (leng>0) begin
       for (i=0; i<ln-1; i=i+1) begin
           HADDR  <= #1 addr; addr = addr + 4;
           HTRANS <= #1 2'b11; //`HTRANS_SEQ;
           @ (posedge HCLK);
           while (HREADY==1'b0) @ (posedge HCLK);
           data_burst[k%1024] <= HRDATA;
           k = k+1;
       end
       leng = leng - ln;
       if (leng==0) begin
          HADDR   <= #1 0;
          HTRANS  <= #1 0;
          HBURST  <= #1 0;
          HWRITE  <= #1 0;
          HSIZE   <= #1 0;
          HBUSREQ <= #1 1'b0;
       end else begin
          HADDR  <= #1 addr; addr = addr + 4;
          HTRANS <= #1 2'b10; //`HTRANS_NONSEQ;
          if (leng>=16)     begin HBURST <= #1 3'b111; ln=16; end //`HBURST_INCR16;
          else if (leng>=8) begin HBURST <= #1 3'b101; ln= 8; end //`HBURST_INCR8;
          else if (leng>=4) begin HBURST <= #1 3'b011; ln= 4; end //`HBURST_INCR4;
          else              begin HBURST <= #1 3'b001; ln=leng; end //`HBURST_INCR;
          @ (posedge HCLK);
          while (HREADY==0) @ (posedge HCLK);
          data_burst[k%1024] = HRDATA; // must be blocking
          k = k+1;
       end
    end
    @ (posedge HCLK);
    while (HREADY==0) @ (posedge HCLK);
    data_burst[k%1024] = HRDATA; // must be blocking
end
endtask

//-------------------------------------------------------------
// It takes suitable burst first and then incremental.
task ahb_write_burst;
     input  [31:0] addr;
     input  [31:0] leng;
     integer       i, j, ln;
begin
    j = 0;
    ln = 0;
    @ (posedge HCLK);
    HBUSREQ <= #1 1'b1;
    @ (posedge HCLK);
    while (leng>0) begin
       while ((HGRANT!==1'b1)||(HREADY!==1'b1)) @ (posedge HCLK);
       HADDR  <= #1 addr; addr = addr + 4;
       HTRANS <= #1 2'b10; //`HTRANS_NONSEQ;
       if (leng>=16)     begin HBURST <= #1 3'b111; ln=16; end//`HBURST_INCR16;
       else if (leng>=8) begin HBURST <= #1 3'b101; ln= 8; end//`HBURST_INCR8;
       else if (leng>=4) begin HBURST <= #1 3'b011; ln= 4; end//`HBURST_INCR4;
       else              begin HBURST <= #1 3'b001; ln=leng; end//`HBURST_INCR;
       HWRITE <= #1 1'b1; //`HWRITE_WRITE;
       HSIZE  <= #1 3'b010; //`HSIZE_WORD;
       for (i=0; i<ln-1; i=i+1) begin
           @ (posedge HCLK);
           while (HREADY==1'b0) @ (posedge HCLK);
           HWDATA <= #1 data_burst[(j+i)%1024];
           HADDR  <= #1 addr; addr = addr + 4;
           HTRANS <= #1 2'b11; //`HTRANS_SEQ;
           while (HREADY==1'b0) @ (posedge HCLK);
       end
       @ (posedge HCLK);
       while (HREADY==0) @ (posedge HCLK);
       HWDATA <= #1 data_burst[(j+i)%1024];
       if (ln==leng) begin
           HADDR   <= #1 0;
           HTRANS  <= #1 0;
           HBURST  <= #1 0;
           HWRITE  <= #1 0;
           HSIZE   <= #1 0;
           HBUSREQ <= #1 1'b0;
       end
       leng = leng - ln;
       j = j+ln;
    end
    @ (posedge HCLK);
    while (HREADY==0) @ (posedge HCLK);
    if (HRESP!=2'b00) begin //`HRESP_OKAY
        $display($time,, "ERROR: non OK response write");
    end
    `ifdef DEBUG
    $display($time,, "INFO: write(%x, %d, %x)", addr, size, data);
    `endif
    HWDATA <= #1 0;
    @ (posedge HCLK);
end
endtask
//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
`endif
