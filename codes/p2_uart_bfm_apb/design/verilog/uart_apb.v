// synopsys translate_off
`timescale 1ns/1ns
// synopsys translate_on
`include "uart16550/uart_regs.v"

module uart_apb (
       input   wire        PRESETn
     , input   wire        PCLK
     , input   wire        PSEL
     , input   wire        PENABLE
     , input   wire [31:0] PADDR
     , input   wire        PWRITE
     , output  wire [31:0] PRDATA
     , input   wire [31:0] PWDATA
     , output  wire        interrupt // interrupt request (active-high)
     , input   wire        srx       // serial output
     , output  wire        stx       // serial input
);
   //--------------------------------------------------
   wire   rtsn;
   wire   ctsn = 1'b0;
   wire   dtr_pad_o;
   wire   dsr_pad_i=1'b0;
   wire   ri_pad_i =1'b0;
   wire   dcd_pad_i=1'b0;
   //--------------------------------------------------------
   wire       reg_we;   // Write enable for registers
   wire       reg_re;   // Read enable for registers
   wire [2:0] reg_adr;
   reg  [7:0] reg_dat8_w; // write to reg
   wire [7:0] reg_dat8_r; // read from reg
   wire       rts_internal;
   assign     rtsn = ~rts_internal;
   //--------------------------------------------------------
   assign reg_we  = PRESETn & PSEL & ~PENABLE &  PWRITE;
   assign reg_re  = PRESETn & PSEL &  PENABLE & ~PWRITE;
   assign reg_adr = PADDR[4:2]; //assign adr_o   = PADDR[2:0];
   assign PRDATA  = (PSEL) ? {4{reg_dat8_r}} : 'h0;
   always @ (PADDR[1:0] or PWDATA) begin
             case (PADDR[1:0])
             `ifdef ENDIAN_BIG
             2'b00: #1 reg_dat8_w = PWDATA[31:24];
             2'b01: #1 reg_dat8_w = PWDATA[23:16];
             2'b10: #1 reg_dat8_w = PWDATA[15:8];
             2'b11: #1 reg_dat8_w = PWDATA[7:0];
             `else // little-endian -- default
             2'b00: #1 reg_dat8_w = PWDATA[7:0];
             2'b01: #1 reg_dat8_w = PWDATA[15:8];
             2'b10: #1 reg_dat8_w = PWDATA[23:16];
             2'b11: #1 reg_dat8_w = PWDATA[31:24];
             `endif
             endcase
   end
   //--------------------------------------------------------
   // Registers
   // As shown below reg_dat_i should be stable
   // one-cycle after reg_we negates.
   //              ___     ___     ___     ___     ___     ___
   //  clk      __|   |___|   |___|   |___|   |___|   |___|   |__
   //             ________________        ________________
   //  reg_adr  XX________________XXXXXXXX________________XXXX
   //             ________________
   //  reg_dat_i X________________XXXXXXX
   //                                     ________________
   //  reg_dat_o XXXXXXXXXXXXXXXXXXXXXXXXX________________XXXX
   //                                              _______
   //  reg_re   __________________________________|       |_____
   //              _______
   //  reg_we   __|       |_____________________________________
   //
   uart_regs Uregs(
          .clk         (PCLK),
          .wb_rst_i    (~PRESETn),
          .wb_addr_i   (reg_adr),
          .wb_dat_i    (reg_dat8_w),
          .wb_dat_o    (reg_dat8_r),
          .wb_we_i     (reg_we),
          .wb_re_i     (reg_re),
          .modem_inputs({~ctsn, dsr_pad_i, ri_pad_i,  dcd_pad_i}),
          .stx_pad_o   (stx),
          .srx_pad_i   (srx),
          .rts_pad_o   (rts_internal),
          .dtr_pad_o   (dtr_pad_o),
          .int_o       (interrupt)
   );
endmodule
