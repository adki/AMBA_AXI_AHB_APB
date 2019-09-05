//----------------------------------------------------------------
// Copyright (c) 2008-2010-2012 by Ando Ki.
// All right reserved.
//----------------------------------------------------------------
// Synchronous FIFO
//----------------------------------------------------------------
// MACROS and PARAMETERS
//----------------------------------------------------------------
// Features
//    * ready-valid handshake protocol
//    * lookahead full and empty -- see fullN and emptyN
//    * First-Word Fall-Through, but rd_vld indicates its validity
//----------------------------------------------------------------
// Operation
//    * data moves when both ready(rdy) and valid(vld) is high.
//    * ready(rdy) means the receiver is ready to accept data.
//    * valid(vld) means the data is valid on 'data'.
//----------------------------------------------------------------
//               __     ___     ___     ___     ___
//   clk           |___|   |___|   |___|   |___|
//               _______________________________
//   wr_rdy     
//                      _______________ 
//   wr_vld      ______|       ||      |___________  
//                      _______  ______
//   wr_din      XXXXXXX__D0___XX__D1__XXXX
//               ______________                         ___
//   empty                     |_______________________|
//                                      _______________ 
//   rd_rdy      ______________________|               |___
//                                      _______________
//   rd_vld      ______________________|       ||      |___
//                                      ________ _______
//   rd_dout     XXXXXXXXXXXXXXXXXXXXXXX__D0____X__D1___XXXX
//
//   full        __________________________________________
//
//----------------------------------------------------------------
`timescale 1ns/1ns

module ahb2ahb_fifo #(parameter FDW =8,  // fifof data width
                                FAW =4,  // num of entries in 2 to the power FAW
                                FULN=4)  // lookahead-full
(
       input   wire           rst // asynchronous reset (active high)
     , input   wire           clr // synchronous reset (active high)
     , input   wire           clk
     , output  wire           wr_rdy
     , input   wire           wr_vld
     , input   wire [FDW-1:0] wr_din
     , input   wire           rd_rdy
     , output  wire           rd_vld
     , output  wire [FDW-1:0] rd_dout
     , output  wire           full
     , output  wire           empty
     , output  wire           fullN  // lookahead full: there are only N rooms in the FIFO
     , output  wire           emptyN // lookahead empty: there are only N items in the FIFO
     , output  reg  [FAW:0]   rd_cnt // num of elements in the FIFO to be read
     , output  wire [FAW:0]   wr_cnt // num of rooms in the FIFO to be written
);
   //---------------------------------------------------
   localparam FDT = 1<<FAW;
   //---------------------------------------------------
   reg  [FAW:0]   fifo_head = 0; // where data to be read
   reg  [FAW:0]   fifo_tail = 0; // where data to be written
   reg  [FAW:0]   next_tail;
   reg  [FAW:0]   next_head;
   wire [FAW-1:0] read_addr = (rd_vld&rd_rdy) ? next_head[FAW-1:0] : fifo_head[FAW-1:0];
   //---------------------------------------------------
   // accept input
   // push data item into the entry pointed by fifo_tail
   //
   always @(posedge clk or posedge rst) begin
      if (rst) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else if (clr) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else begin
          if (!full && wr_vld) begin
              fifo_tail <= next_tail;
              next_tail <= next_tail + 1;
          end 
      end
   end
   //---------------------------------------------------
   // provide output
   // pop data item from the entry pointed by fifo_head
   //
   always @(posedge clk or posedge rst) begin
      if (rst) begin
          fifo_head <= 0;
          next_head <= 1;
      end else if (clr) begin
          fifo_head <= 0;
          next_head <= 1;
      end else begin
          if (!empty && rd_rdy) begin
              fifo_head <= next_head;
              next_head <= next_head + 1;
          end
      end
   end
   //---------------------------------------------------
   // how many items in the FIFO
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         rd_cnt <= 0;
      end else if (clr) begin
         rd_cnt <= 0;
      end else begin
         if (wr_vld&&!full&&(!rd_rdy||(rd_rdy&&empty))) begin
             rd_cnt <= rd_cnt + 1;
         end else
         if (rd_rdy&&!empty&&(!wr_vld||(wr_vld&&full))) begin
             rd_cnt <= rd_cnt - 1;
         end
      end
   end
   //---------------------------------------------------
   assign wr_cnt = FDT-rd_cnt;
   assign rd_vld = ~empty;
   assign wr_rdy = ~full;
   assign empty  = (fifo_head == fifo_tail);
   assign full   = (rd_cnt>=FDT);
   //---------------------------------------------------
   assign fullN  = (wr_cnt<=FULN);
   assign emptyN = (rd_cnt<=FULN);
   //---------------------------------------------------
   // synopsys translate_off
`ifdef RIGOR
   //always @ (posedge clk) begin
   //    if (full) $display($time,,"%m: synchronous fifo full.....");
   //end
   always @(negedge clk or posedge rst) begin
      if (!rst&&!clr) begin
          if ((rd_cnt==0)&&(!empty))
             $display($time,, "%m: empty flag mis-match: %d", rd_cnt);
          if ((rd_cnt==FDT)&&(!full))
             $display($time,, "%m: full flag mis-match: %d", rd_cnt);
          if (rd_cnt>FDT)
             $display($time,, "%m: fifo handling error: rd_cnt>FDT %d:%d", rd_cnt, FDT);
          if ((rd_cnt+wr_cnt)!=FDT)
             $display($time,, "%m: count mis-match: rd_cnt:wr_cnt %d:%d", rd_cnt, wr_cnt);
      end
   end
`endif
   // synopsys translate_on
   //---------------------------------------------------
   reg [FDW-1:0] Mem [0:FDT-1];
   assign rd_dout  = Mem[fifo_head[FAW-1:0]];
   always @(posedge clk) begin
       if (!full && wr_vld) begin
           Mem[fifo_tail[FAW-1:0]] <= wr_din;
       end
   end
   //---------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2011.03.03: 'fullN' changed by Ando Ki.
// 2010.08.18: 'dpsram_512x32' added by Ando Ki.
// 2010.08.17: 'xilinx_dpram' added by Ando Ki.
// Sept. 23, 2008: 'clr' (synchronous reset) added [adki]
// May   05, 2008: ready-valid protocol [adki]
// April 18, 2008: tested and passed [adki]
// April 10, 2008: port names changed [adki]
// March 28, 2008: emptyN added [adki]
// Jan.  29, 2008: Starting [adki]
//----------------------------------------------------------------
// $Log$
// 2008: Created by Ando Ki (adki@future-ds.com)
// This code is distributed in the hope that it
// will be useful to understand Future Design Systmes'
// products, BUT WITHOUT ANY WARRANTY.
// $EndLog$
//----------------------------------------------------------------
