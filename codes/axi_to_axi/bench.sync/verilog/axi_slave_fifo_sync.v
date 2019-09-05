//----------------------------------------------------------------
//  Copyright (c) by Ando Ki.
//  All right reserved.
//----------------------------------------------------------------
// axi_fifo_sync.v
//----------------------------------------------------------------
// Synchronous FIFO
//----------------------------------------------------------------
// VERSION: 2011.01.08.
//----------------------------------------------------------------
// MACROS and PARAMETERS
//     FDW: bit-width of data
//     FAW: num of entries in power of 2
//----------------------------------------------------------------
// Features
//    * ready-valid handshake protocol
//    * First-Word Fall-Through, but rd_vld indicates its validity
//----------------------------------------------------------------
//    * data moves when both ready(rdy) and valid(vld) is high.
//    * ready(rdy) means the receiver is ready to accept data.
//    * valid(vld) means the data is valid on 'data'.
//----------------------------------------------------------------
//
//               ___   _____   _____   _____   ____
//   clk           |___|   |___|   |___|   |___|
//               _______________________________
//   wr_rdy     
//                     _________________
//   wr_vld      ______|       ||      |___________  
//                      _______  ______
//   wr_din      XXXXXXX__D0___XX__D1__XXXX
//               ______________                        ____
//   empty                     |_______________________|
//                                     _________________
//   rd_rdy      ______________________|               |___
//                                     ________________
//   rd_vld      ______________________|       ||      |___
//                                      ________ _______
//   rd_dout     XXXXXXXXXXXXXXXXXXXXXXX__D0____X__D1___XXXX
//
//   full        __________________________________________
//
//----------------------------------------------------------------
`timescale 1ns/1ps

module axi_slave_fifo_sync #(parameter FDW =32,  // fifof data width
                                       FAW =5 )  // num of entries in 2 to the power FAW
(
       input   wire           rstn// asynchronous reset (active low)
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
     , output  reg  [FAW:0]   item_cnt // num of elements in the FIFO to be read
     , output  wire [FAW:0]   room_cnt // num of rooms in the FIFO to be written
);
   //---------------------------------------------------
   localparam FDT = 1<<FAW;
   //---------------------------------------------------
   reg  [FAW:0]   fifo_head; // where data to be read
   reg  [FAW:0]   fifo_tail; // where data to be written
   reg  [FAW:0]   next_tail;
   reg  [FAW:0]   next_head;
   wire [FAW-1:0] read_addr = (rd_vld&rd_rdy) ? next_head[FAW-1:0] : fifo_head[FAW-1:0];
   //---------------------------------------------------
   // synopsys translate_off
   initial fifo_head = 'h0;
   initial fifo_tail = 'h0;
   initial next_head = 'h0;
   initial next_tail = 'h0;
   // synopsys translate_on
   //---------------------------------------------------
   // accept input
   // push data item into the entry pointed by fifo_tail
   //
   always @(posedge clk or negedge rstn) begin
      if (rstn==1'b0) begin
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
   always @(posedge clk or negedge rstn) begin
      if (rstn==1'b0) begin
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
   //
   assign  room_cnt = FDT-item_cnt;
   always @(posedge clk or negedge rstn) begin
      if (rstn==1'b0) begin
         item_cnt <= 0;
      end else if (clr) begin
         item_cnt <= 0;
      end else begin
         if (wr_vld&&!full&&(!rd_rdy||(rd_rdy&&empty))) begin
             item_cnt <= item_cnt + 1;
         end else
         if (rd_rdy&&!empty&&(!wr_vld||(wr_vld&&full))) begin
             item_cnt <= item_cnt - 1;
         end
      end
   end
   
   //---------------------------------------------------
   assign rd_vld = ~empty;
   assign wr_rdy = ~full;
   assign empty  = (fifo_head == fifo_tail);
   assign full   = (item_cnt>=FDT);
   //---------------------------------------------------
   // synopsys translate_off
`ifdef RIGOR
   //always @ (posedge clk) begin
   //    if (full) $display($time,,"%m: synchronous fifo full.....");
   //end
   always @(negedge clk or negedge rstn) begin
      if (rstn&&!clr) begin
          if ((item_cnt==0)&&(!empty))
             $display($time,, "%m: empty flag mis-match: %d", item_cnt);
          if ((item_cnt==FDT)&&(!full))
             $display($time,, "%m: full flag mis-match: %d", item_cnt);
          if (item_cnt>FDT)
             $display($time,, "%m: fifo handling error: item_cnt>FDT %d:%d", item_cnt, FDT);
          if ((item_cnt+room_cnt)!=FDT)
             $display($time,, "%m: count mis-match: item_cnt:room_cnt %d:%d", item_cnt, room_cnt);
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
// 2011.01.08: Starting [adki]
//----------------------------------------------------------------
