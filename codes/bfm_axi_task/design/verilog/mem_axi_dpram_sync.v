//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// mem_axi_dpram_sync.v
//--------------------------------------------------------
// VERSION = 2013.02.03.
//--------------------------------------------------------
// Simple Dual-Port RAM
//  - one port for write
//  - one port for read
//--------------------------------------------------------
// Macros and parameters:
//--------------------------------------------------------
// size of memory in byte: 1<<ADDR_LENGTH
// requires: 'WIDTH_DS' 8-bit BRAM of depth 1<<(ADDR_LENGTH-WIDTH_DSB)
//----------------------------------------------------------------
`timescale 1ns/1ns

module mem_axi_dpram_sync
     #(parameter WIDTH_AD =10 // size of memory in byte
               , WIDTH_DA =32 // width of a line in bytes
               , WIDTH_DS =(WIDTH_DA/8) // width of a line in bytes
               , WIDTH_DSB=clogb2(WIDTH_DS)
               )
(
        input  wire                RESETn
      , input  wire                CLK
      , input  wire [WIDTH_AD-1:0] WADDR
      , input  wire [WIDTH_DA-1:0] WDATA
      , input  wire [WIDTH_DS-1:0] WSTRB
      , input  wire                WEN
      , input  wire [WIDTH_AD-1:0] RADDR
      , output wire [WIDTH_DA-1:0] RDATA
      , input  wire [WIDTH_DS-1:0] RSTRB
      , input  wire                REN
);
    //----------------------------------------------------
    localparam DEPTH_BIT=(WIDTH_AD-WIDTH_DSB);
    localparam DEPTH=(1<<DEPTH_BIT);
    //----------------------------------------------------
    generate
    genvar bs;
    for (bs=0; bs<WIDTH_DS; bs=bs+1) begin: mem_core
        mem_axi_dpram_sync_core #(.WIDTH_AD(WIDTH_AD-WIDTH_DSB))
        Udpram_sync_core (
              .RESETn (RESETn             )
            , .CLK    (CLK                )
            , .WADDR  (WADDR[WIDTH_AD-1:WIDTH_DSB])
            , .WDATA  (WDATA[8*bs+7:8*bs] )
            , .WEN    (WEN&WSTRB[bs]      )
            , .RADDR  (RADDR[WIDTH_AD-1:WIDTH_DSB])
            , .RDATA  (RDATA[8*bs+7:8*bs] )
            , .REN    (REN&RSTRB[bs]      )
        );
    end
    endgenerate
    //-------------------------------------------------------
    function integer clogb2;
    input [31:0] value;
    reg   [31:0] tmp;
    begin
       tmp = value - 1;
       for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
          tmp = tmp >> 1;
       end
    endfunction
    //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
module mem_axi_dpram_sync_core #(parameter WIDTH_AD=8)
(
       input  wire                 RESETn
     , input  wire                 CLK
     , input  wire [WIDTH_AD-1:0]  WADDR
     , input  wire [7:0]           WDATA
     , input  wire                 WEN
     , input  wire [WIDTH_AD-1:0]  RADDR
     , output reg  [7:0]           RDATA
     , input  wire                 REN
);
     //-----------------------------------------------------------
     localparam DEPTH = (1<<WIDTH_AD);
     //-----------------------------------------------------------
     reg [7:0] mem[0:DEPTH-1];
     //-----------------------------------------------------------
     // write case
     always @ (posedge CLK or negedge RESETn) begin
          if (RESETn==1'b0) begin
          end else begin
              if (WEN==1'b1) begin
                  mem[WADDR] <= WDATA;
              end
          end
     end
     //-----------------------------------------------------------
     // read case
     always @ (posedge CLK or negedge RESETn) begin
          if (RESETn==1'b0) begin
              RDATA <= 'h0;
          end else begin
              if (REN==1'b1) begin
                  if ((WEN==1'b1)&&(RADDR==WADDR)) begin
                      RDATA <= WDATA;
                  end else begin
                      RDATA <= mem[RADDR];
                  end
              end
             // synopsys translate_off
             else begin
                 RDATA <= 'hX;
             end
             // synopsys translate_on
          end
     end
     //-----------------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2013.02.03: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
