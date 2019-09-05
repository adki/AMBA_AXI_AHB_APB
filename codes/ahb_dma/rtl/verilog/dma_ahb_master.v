//--------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// dma_ahb_master.v
//--------------------------------------------------------
// VERSION = 2014.04.29.
//--------------------------------------------------------
`include "dma_ahb_fifo_sync_small.v"
`timescale 1ns/1ns

module dma_ahb_master
(
       input   wire            HRESETn
     , input   wire            HCLK
     , output  reg             HBUSREQ=1'b0
     , input   wire            HGRANT
     , output  reg   [31:0]    HADDR=~32'h0
     , output  reg   [ 1:0]    HTRANS=2'b0
     , output  reg             HWRITE=1'b0
     , output  reg   [ 2:0]    HSIZE=3'b0
     , output  reg   [ 2:0]    HBURST=3'b0
     , output  wire  [ 3:0]    HPROT
     , output  reg   [31:0]    HWDATA=~32'h0
     , input   wire  [31:0]    HRDATA
     , input   wire  [ 1:0]    HRESP
     , input   wire            HREADY
     //---------------------------------------------------
     , input   wire            DMA_EN
     , input   wire            DMA_GO
     , output  reg             DMA_BUSY=1'b0
     , output  reg             DMA_DONE=1'b0
     , input   wire  [31:0]    DMA_SRC
     , input   wire  [31:0]    DMA_DST
     , input   wire  [15:0]    DMA_BNUM // num of bytes to move
     , input   wire  [ 4:0]    DMA_BURST // burst length 1, 4, 8 , 16
);
   //-----------------------------------------------------
   assign HPROT  = 4'b0011;
   //-----------------------------------------------------
   reg [31:0] dma_rd_addr  = ~32'h0;
   reg [15:0] dma_rd_bnum  =  16'h0;
   reg [ 4:0] dma_rd_burst =   5'h0;
   reg [31:0] dma_rd_data  = ~32'h0;
   reg [31:0] dma_wr_addr  = ~32'h0;
   reg [15:0] dma_wr_bnum  =  16'h0;
   reg [ 4:0] dma_wr_burst =   5'h0;
   reg [31:0] dma_wr_data  = ~32'h0;
   reg        dma_wr_data_vld=1'b0;
   reg [ 6:0] bnum  =  6'h0; // 1~60
   //-----------------------------------------------------
   reg         fifo_wr_vld=1'b0;
   wire        fifo_wr_rdy;
   reg  [31:0] fifo_wr_dat=32'h0;
   wire        fifo_rd_vld;
   reg         fifo_rd_rdy=1'b0;
   wire [31:0] fifo_rd_dat;
   wire        fifo_empty ;
   wire        fifo_full  ;
   //-----------------------------------------------------
   localparam ST_READY    = 'h0
            , ST_START    = 'h1
            , ST_RD_ARB_S = 'h2
            , ST_RD_S0    = 'h3
            , ST_RD_S1    = 'h4
            , ST_WR_ARB_S = 'h5
            , ST_WR_S0    = 'h6
            , ST_WR_S1    = 'h7
            , ST_RD_ARB_B = 'h8
            , ST_RD_B0    = 'h9
            , ST_RD_B1    = 'hA
            , ST_RD_B2    = 'hB
            , ST_WR_ARB_B = 'hC
            , ST_WR_B0    = 'hD
            , ST_CHECK    = 'hE
            , ST_DONE     = 'hF;
   reg [3:0] state = ST_READY;
   //-----------------------------------------------------
   always @ (posedge HCLK or negedge HRESETn) begin
   if (HRESETn==1'b0) begin
       HBUSREQ         <=  1'b0;
       HADDR           <=~32'h0;
       HTRANS          <=  2'b0;
       HSIZE           <=  3'b0;
       HBURST          <=  3'b0;
       HWRITE          <=  1'b0;
       HWDATA          <=~32'h0;
       DMA_BUSY        <=  1'b0;
       DMA_DONE        <=  1'b0;
       dma_rd_addr     <=~32'h0;
       dma_rd_bnum     <= 16'h0; // remain
       dma_rd_burst    <=  5'h0;
       dma_rd_data     <=~32'h0;
       dma_wr_addr     <=~32'h0;
       dma_wr_bnum     <= 16'h0; // remain
       dma_wr_burst    <=  5'h0;
       dma_wr_data     <=~32'h0;
       dma_wr_data_vld <= 1'b0;
       bnum            <=  6'h0; // byte num of current transaction
       fifo_wr_vld     <=  1'b0;
       fifo_wr_dat     <= 32'h0;
       fifo_rd_rdy     <=  1'b0;
       state           <= ST_READY;
   end else if (DMA_EN==1'b0) begin
       HBUSREQ         <=  1'b0;
       HADDR           <=~32'h0;
       HTRANS          <=  2'b0;
       HSIZE           <=  3'b0;
       HBURST          <=  3'b0;
       HWRITE          <=  1'b0;
       HWDATA          <=~32'h0;
       DMA_BUSY        <=  1'b0;
       DMA_DONE        <=  1'b0;
       dma_rd_addr     <=~32'h0;
       dma_rd_bnum     <= 16'h0; // remain
       dma_rd_burst    <=  5'h0;
       dma_rd_data     <=~32'h0;
       dma_wr_addr     <=~32'h0;
       dma_wr_bnum     <= 16'h0; // remain
       dma_wr_burst    <=  5'h0;
       dma_wr_data     <=~32'h0;
       dma_wr_data_vld <= 1'b0;
       bnum            <=  6'h0; // byte num of current transaction
       fifo_wr_vld     <=  1'b0;
       fifo_wr_dat     <= 32'h0;
       fifo_rd_rdy     <=  1'b0;
       state           <= ST_READY;
   end else begin
   case (state)
   //-------------------------------------------------------
   ST_READY: begin
      if ((DMA_GO==1'b1)&&(DMA_BNUM>0)&&(DMA_BURST>0)) begin
          DMA_BUSY     <= 1'b1;
          DMA_DONE     <= 1'b0;
          dma_rd_addr  <= DMA_SRC;
          dma_rd_bnum  <= DMA_BNUM;
          dma_rd_burst <=  5'h0;
          dma_wr_addr  <= DMA_DST;
          dma_wr_bnum  <= DMA_BNUM;
          dma_wr_burst <=  5'h0;
          bnum         <=  6'h0;
          HBUSREQ      <=  1'b1; // make one cycle fast
          state        <= ST_START;
          // synthesis translate_off
          if (DMA_SRC[1:0]!==DMA_DST[1:0])
              $display($time,,"%m ERROR src/dst should be the same offset");
          // synthesis translate_on
      end
      end // ST_READY
   //-------------------------------------------------------
   ST_START: begin
      HBUSREQ <= 1'b1;
      if ( (DMA_BURST==5'h1)||         // single
           (dma_rd_addr[1:0]!=2'b00)|| // mis-aligned
           (dma_rd_bnum<4)||           // small move
           (dma_rd_bnum<(DMA_BURST<<2))) begin
           bnum  <= (dma_rd_addr[1:0]!=2'b00) ? 1
                  : (dma_rd_bnum<4) ? 1
                  : 4;
           state <= ST_RD_ARB_S;
      end else begin
           bnum  <= 4;
           state <= ST_RD_ARB_B;
      end
      // synthesis translate_off
      if (fifo_empty==1'b0)
          $display($time,,"%m ERROR fifo should be empty before start transaction");
      // synthesis translate_on
      end // ST_START
   //-------------------------------------------------------
   // Single read
   ST_RD_ARB_S: begin
      if (HGRANT&HREADY) begin
          HBUSREQ <= 1'b0;
          HADDR   <= dma_rd_addr;
          HSIZE   <= (bnum==1'b1) ? 3'b000 : 3'b010; // 0=byte, 1=short, 2=word
          HTRANS  <= 2'b10;  // `HTRANS_NONSEQ; // it is important
          HBURST  <= 3'b000; // `HBURST_SINGLE;
          state   <= ST_RD_S0;
      end
      end // ST_RD_ARB_S
   ST_RD_S0: begin
      if (HREADY==1'b1) begin
          HTRANS  <= 2'b00; // `HTRANS_IDLE;
          state   <= ST_RD_S1;
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for read");
          // synthesis translate_on
      end
      end // ST_RD_S0
   ST_RD_S1: begin
      if (HREADY==1'b1) begin
          dma_rd_addr   <= dma_rd_addr + bnum;
          dma_rd_bnum   <= dma_rd_bnum - bnum;
          dma_rd_data   <= HRDATA;
          HBUSREQ       <= 1'b1;
          state         <= ST_WR_ARB_S;
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for read");
          // synthesis translate_on
      end
      end // ST_RD_S1
   //-------------------------------------------------------
   // single write
   ST_WR_ARB_S: begin
      if (HGRANT&HREADY) begin
          HBUSREQ  <= 1'b0;
          HADDR    <= dma_wr_addr;
          HWRITE   <= 1'b1;
          HSIZE   <= (bnum==1'b1) ? 3'b000 : 3'b010; // 0=byte, 1=short, 2=word
          HTRANS   <= 2'b10; // `HTRANS_NONSEQ; // it is important
          HBURST   <= 3'b000; // `HBURST_SINGLE;
          state    <= ST_WR_S0;
      end
      end // ST_WR_ARB_S
   ST_WR_S0: begin
      if (HREADY==1'b1) begin
          HTRANS      <= 2'b00; // `HTRANS_IDLE;
          HWRITE      <= 1'b0;
          HWDATA      <= dma_rd_data;
          dma_wr_addr <= dma_wr_addr + bnum;
          dma_wr_bnum <= dma_wr_bnum - bnum;
          state       <= ST_WR_S1;
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for write");
          // synthesis translate_on
      end
      end // ST_WR_S0
   ST_WR_S1: begin
      if (HREADY==1'b1) begin
          state       <= ST_CHECK;
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for write");
          // synthesis translate_on
      end
      end // ST_WR_S1
   //-------------------------------------------------------
   // Burst read
   ST_RD_ARB_B: begin
      if (HGRANT&HREADY) begin
          HADDR   <= dma_rd_addr;
          HSIZE   <= 3'b010; // 0=byte, 1=short, 2=word
          HTRANS  <= 2'b10;  // `HTRANS_NONSEQ; // it is important
          case (DMA_BURST)
           4: HBURST <= 3'b011; // INC4
           8: HBURST <= 3'b101; // INC8
          16: HBURST <= 3'b111; // INC16
          default: HBURST <= 3'b001; // INCR
          endcase
          dma_rd_addr  <= dma_rd_addr + bnum;
          dma_rd_burst <= dma_rd_burst + 1;
          state        <= ST_RD_B0;
          // synthesis translate_off
          if (bnum!=4)
              $display($time,,"%m ERROR: bnum should be 4 for burst, but %d", bnum);
          if (fifo_empty==1'b0)
              $display($time,,"%m ERROR: fifo should be empty for burst read");
          // synthesis translate_on
      end
      end // ST_RD_ARB_B
   ST_RD_B0: begin
      if (HREADY==1'b1) begin
          if (dma_rd_burst<DMA_BURST) begin
              HADDR        <= dma_rd_addr;
              HTRANS       <= 2'b11;  // `HTRANS_SEQ; // it is important
              dma_rd_addr  <= dma_rd_addr + bnum;
              dma_rd_burst <= dma_rd_burst + 1;
          end else begin
              HBUSREQ     <= 1'b0;
              HTRANS      <= 2'b00;  // `HTRANS_SEQ; // it is important
          end
          state <= ST_RD_B1;
      end
      end // ST_RD_B0
   ST_RD_B1: begin
      if (HREADY==1'b1) begin
          dma_rd_bnum <= dma_rd_bnum - bnum;
          fifo_wr_vld <= 1'b1;
          fifo_wr_dat <= HRDATA;
          if (dma_rd_burst<DMA_BURST) begin
              HADDR        <= dma_rd_addr;
              HTRANS       <= 2'b11;  // `HTRANS_SEQ; // it is important
              dma_rd_addr  <= dma_rd_addr + bnum;
              dma_rd_burst <= dma_rd_burst + 1;
          end else begin
              HTRANS      <= 2'b00;  // `HTRANS_SEQ; // it is important
          end
          if (dma_rd_burst==(DMA_BURST-2)) begin
              HBUSREQ     <= 1'b0;
          end
          if (dma_rd_burst==DMA_BURST) begin
              state   <= ST_RD_B2;
          end
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for read");
          // synthesis translate_on
      end else begin
          fifo_wr_vld <= 1'b0;
      end
      end // ST_RD_B1
   ST_RD_B2: begin
      if (HREADY==1'b1) begin
          dma_rd_bnum <= dma_rd_bnum - bnum;
          fifo_wr_vld <= 1'b1;
          fifo_wr_dat <= HRDATA;
          HBUSREQ <= 1'b1;
          state   <= ST_WR_ARB_B;
      end else begin
          fifo_wr_vld <= 1'b0;
      end
      end // ST_RD_B2
   //-------------------------------------------------------
   // burst write
   ST_WR_ARB_B: begin
      fifo_wr_vld <= 1'b0;
      if (HGRANT&HREADY) begin
          HADDR   <= dma_wr_addr;
          HWRITE  <= 1'b1;
          HSIZE   <= 3'b010; // 0=byte, 1=short, 2=word
          HTRANS  <= 2'b10;  // `HTRANS_NONSEQ; // it is important
          case (DMA_BURST)
           4: HBURST <= 3'b011; // INC4
           8: HBURST <= 3'b101; // INC8
          16: HBURST <= 3'b111; // INC16
          default: HBURST <= 3'b001; // INCR
          endcase
          dma_wr_addr  <= dma_wr_addr + bnum;
          dma_wr_burst <= dma_wr_burst + 1;
          fifo_rd_rdy  <= 1'b1;
          state        <= ST_WR_B0;
          // synthesis translate_off
          if (bnum!=4)
              $display($time,,"%m ERROR: bnum should be 4 for burst, but %d", bnum);
          if (fifo_empty==1'b1)
              $display($time,,"%m ERROR: fifo should not be empty for burst write");
          // synthesis translate_on
      end
      end // ST_WR_ARB_S
   ST_WR_B0: begin
      if (HREADY==1'b1) begin
          HWDATA          <= (dma_wr_data_vld) ? dma_wr_data : fifo_rd_dat;
          dma_wr_data_vld <= 1'b0;
          fifo_rd_rdy     <= 1'b1;
          dma_wr_bnum     <= dma_wr_bnum - bnum;
          if (dma_wr_burst<DMA_BURST) begin
              HADDR        <= dma_wr_addr;
              HTRANS       <= 2'b11;  // `HTRANS_SEQ; // it is important
              dma_wr_addr  <= dma_wr_addr + bnum;
              dma_wr_burst <= dma_wr_burst + 1;
          end else begin
              HWRITE  <= 1'b0;
              HTRANS  <= 2'b00;  // `HTRANS_SEQ; // it is important
          end
          if (dma_wr_burst==(DMA_BURST-2)) begin
              HBUSREQ <= 1'b0;
          end 
          if (dma_wr_burst==DMA_BURST) begin
              fifo_rd_rdy <= 1'b0;
              state       <= ST_CHECK;
          end
          // synthesis translate_off
          if (HRESP!=2'b00)
              $display($time,, "%m ERROR: non OK response for write");
          // synthesis translate_on
      end else begin
          fifo_rd_rdy     <= 1'b0;
          dma_wr_data_vld <= 1'b1;
          dma_wr_data     <= (dma_wr_data_vld) ? dma_wr_data : fifo_rd_dat;
      end
      // synthesis translate_off
      if ((fifo_rd_rdy==1'b1)&&(fifo_rd_vld==1'b0))
          $display($time,, "%m ERROR: fifo should be valid while write");
      // synthesis translate_on
      end // ST_WR_B0
   //-------------------------------------------------------
   ST_CHECK: begin
      fifo_rd_rdy <= 1'b0;
      if (dma_rd_bnum>0) begin
         HBUSREQ      <= 1'b1;
         dma_rd_burst <= 5'h0;
         dma_wr_burst <= 5'h0;
         state        <= ST_START;
      end else begin
         DMA_BUSY <= 1'b0;
         DMA_DONE <= 1'b1;
         state    <= ST_DONE;
      end
      end // ST_CHECk
   ST_DONE: begin
      if (DMA_GO==1'b0) begin
         DMA_DONE <= 1'b0;
         state    <= ST_READY;
      end
      end // ST_DONE
   //-------------------------------------------------------
   endcase
   end // if
   end // always
   //-----------------------------------------------------
   dma_ahb_fifo_sync_small
   u_fifo (
       .rst     (~HRESETn   )// asynchronous reset (active high)
     , .clr     (1'b0       )// synchronous reset (active high)
     , .clk     (HCLK       )
     , .wr_rdy  (fifo_wr_rdy)
     , .wr_vld  (fifo_wr_vld)
     , .wr_din  (fifo_wr_dat)
     , .rd_rdy  (fifo_rd_rdy)
     , .rd_vld  (fifo_rd_vld)
     , .rd_dout (fifo_rd_dat)
     , .full    (fifo_full  )
     , .empty   (fifo_empty )
     , .fullN   ()// lookahead full
     , .emptyN  ()// lookahead empty
     , .rd_cnt  ()// num of elements in the FIFO to be read
     , .wr_cnt  ()// num of rooms in the FIFO to be written
   );
   //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2014.04.29: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
