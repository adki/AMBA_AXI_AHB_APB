//----------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// dma_ahb_csr.v
//----------------------------------------------------------
// VERSION: 2014.04.29.
//----------------------------------------------------------
// PWM IGBT
//----------------------------------------------------------
// Limitations:
//----------------------------------------------------------
// CSR access signals
//             __    __    __    __    __    _
// CLK      __|  |__|  |__|  |__|  |__|  |__|
//             _____             _____
// T_ADDR   XXX_____XXXXXXXXXXXXX_____XXX
//             _____
// T_RDEN   __|     |____________________
//                   _____
// T_RDATA  XXXXXXXXX_____XXXXXXXXXXXXXXX
//                               _____
// T_WREN   ____________________|     |__
//                               _____
// T_WDATA  XXXXXXXXXXXXXXXXXXXXX_____XXXX
//----------------------------------------------------------
`timescale 1ns/1ns

module dma_ahb_csr #(parameter T_ADDR_WID=8)
(
       input   wire                   RESET_N
     , input   wire                   CLK
     , input   wire [T_ADDR_WID-1:0]  T_ADDR
     , input   wire                   T_WREN
     , input   wire                   T_RDEN
     , input   wire [31:0]            T_WDATA
     , output  reg  [31:0]            T_RDATA
     , output  wire                   IRQ
     //-----------------------------------------------------
     , output  wire            DMA_EN
     , output  wire            DMA_GO
     , input   wire            DMA_BUSY
     , input   wire            DMA_DONE
     , output  wire  [31:0]    DMA_SRC
     , output  wire  [31:0]    DMA_DST
     , output  wire  [15:0]    DMA_BNUM // num of bytes to move
     , output  wire  [ 4:0]    DMA_BURST // burst length 1, 4, 8 , 16
);
   //--------------------------------------------------------
   // CSR address
   //-------------------------------------------------------
   localparam CSRA_NAME0   = 8'h00,
              CSRA_NAME1   = 8'h04,
              CSRA_NAME2   = 8'h08,
              CSRA_NAME3   = 8'h0C,
              CSRA_COMP0   = 8'h10,
              CSRA_COMP1   = 8'h14,
              CSRA_COMP2   = 8'h18,
              CSRA_COMP3   = 8'h1C,
              CSRA_VERSION = 8'h20,
              CSRA_CONTROL = 8'h30,
              CSRA_NUM     = 8'h40,
              CSRA_SOURCE  = 8'h44,
              CSRA_DEST    = 8'h48;
   //-------------------------------------------------------
   // CSR
   //-------------------------------------------------------
   wire [31:0] csr_name0   = "DMA "; // 
   wire [31:0] csr_name1   = "AHB "; // 
   wire [31:0] csr_name2   = "    "; // 
   wire [31:0] csr_name3   = "    "; // 
   wire [31:0] csr_comp0   = "DYNA"; // 
   wire [31:0] csr_comp1   = "LITH"; // 
   wire [31:0] csr_comp2   = "    "; // 
   wire [31:0] csr_comp3   = "    "; // 
   wire [31:0] csr_version = 32'h20140429;//
   //-------------------------------------------------------
   reg         csr_ctl_en    = 1'b0; // bit-31
   reg         csr_ctl_ip    = 1'b0; // bit-1
   reg         csr_ctl_ie    = 1'b0; // bit-0
   //-------------------------------------------------------
   reg         csr_num_go    = 1'b0; // bit-31
   reg  [ 4:0] csr_num_burst = 1'b1; // bit-20~16
   reg  [15:0] csr_num_byte  =16'b0; // bit-15~0
   //-------------------------------------------------------
   reg  [31:0] csr_source    = 1'b0; // bit-31~0
   reg  [31:0] csr_dest      = 9'b0; // bit-31~0
   //-------------------------------------------------------
   // CSR read
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       T_RDATA <= 'h0;
   end else begin
      if (T_RDEN) begin
         case (T_ADDR) // synthesis full_case parallel_case
           CSRA_NAME0   : T_RDATA <= csr_name0  ;
           CSRA_NAME1   : T_RDATA <= csr_name1  ;
           CSRA_NAME2   : T_RDATA <= csr_name2  ;
           CSRA_NAME3   : T_RDATA <= csr_name3  ;
           CSRA_COMP0   : T_RDATA <= csr_comp0  ;
           CSRA_COMP1   : T_RDATA <= csr_comp1  ;
           CSRA_COMP2   : T_RDATA <= csr_comp2  ;
           CSRA_COMP3   : T_RDATA <= csr_comp3  ;
           CSRA_VERSION : T_RDATA <= csr_version;
           CSRA_CONTROL : T_RDATA <= {csr_ctl_en // bit-31
                                     ,29'h0      // bit-30~2
                                     ,csr_ctl_ip // bit-1
                                     ,csr_ctl_ie // bit-0
                                     };
           CSRA_NUM     : T_RDATA <= {csr_num_go    // bit-31
                                     ,DMA_BUSY      // bit-30
                                     ,DMA_DONE      // bit-29
                                     ,8'h0         // bit-28~21
                                     ,csr_num_burst // bit-20~16
                                     ,csr_num_byte  // bit-15~0
                                     };
           CSRA_SOURCE  : T_RDATA <= csr_source;
           CSRA_DEST    : T_RDATA <= csr_dest;
           default: begin
                    T_RDATA <=32'h0;
           end
         endcase
      end else T_RDATA <= 'h0;
   end // if
   end // always
   //-------------------------------------------------------
   // CSR write
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_ctl_en    <= 1'b0;
       csr_num_burst <= 1'b1;
       csr_num_byte  <= 16'h0;
       csr_source    <= 32'h0;
       csr_dest      <= 32'h0;
   end else begin
      if (T_WREN) begin
         case (T_ADDR) // synthesis full_case parallel_case
           CSRA_CONTROL : csr_ctl_en // bit-31
                          <= T_WDATA[31];
           CSRA_NUM     : begin
                          csr_num_burst // bit-20~16
                          <= (T_WDATA[20:16]<4) ? 1
                           : (T_WDATA[20:16]<8) ? 4
                           : (T_WDATA[20:16]<16) ? 8
                           : 16;
                          csr_num_byte  // bit-15~0
                          <= T_WDATA[15:0];
                          end
           CSRA_SOURCE  : csr_source <= T_WDATA;
           CSRA_DEST    : csr_dest <= T_WDATA;
         endcase
      end
   end // if
   end // always
   //-------------------------------------------------------
   // go
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_num_go <= 1'b0; // bit-0
   end else begin
       if (T_WREN&&(T_ADDR==CSRA_NUM)) begin
           csr_num_go  <= csr_ctl_en & T_WDATA[31];
       end else begin
           if (DMA_DONE) csr_num_go <= 1'b0;
       end
   end // if
   end // always
   //-------------------------------------------------------
   // interrupt
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_ctl_ie <= 1'b0; // bit-0
       csr_ctl_ip <= 1'b0; // bit-1
   end else begin
       if (T_WREN&&(T_ADDR==CSRA_CONTROL)) begin
           csr_ctl_ie            <= T_WDATA[0];
           csr_ctl_ip            <= (T_WDATA[1]==1'b1) ? 1'b0 : csr_ctl_ip;
       end else begin
           if (csr_ctl_ie & DMA_GO & DMA_DONE)
               csr_ctl_ip <= 1'b1;
       end
   end // if
   end // always
   //-------------------------------------------------------
   assign IRQ = csr_ctl_ip;
   //-------------------------------------------------------
   assign DMA_EN = csr_ctl_en;
   assign DMA_GO = csr_ctl_en & csr_num_go;
   assign DMA_SRC = csr_source;
   assign DMA_DST = csr_dest;
   assign DMA_BNUM = csr_num_byte;
   assign DMA_BURST = csr_num_burst;
   //-------------------------------------------------------
endmodule
//-------------------------------------------------------
// Revision History
//
// 2014.02.10: Started by Ando Ki 
// http://www.dynalith.com
// adki@dynalith.com
//-------------------------------------------------------
