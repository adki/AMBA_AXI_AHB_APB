`ifndef _UART_APB_TASKS_V_
`define _UART_APB_TASKS_V_
//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
// uart_apb_tasks.v
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
   // U16550 CSR address
   localparam RB_THR     =0
            , IER        =4
            , IIR_FCR    =8
            , LCR        =12
            , MCR        =16
            , LSR        =20
            , MSR        =24;
//--------------------------------------------------------
   task send_a_character;
        input [ 7:0] dat;
        reg   [31:0] tmp;
   begin
          ... ... fill
   end
   endtask
//--------------------------------------------------------
   task receive_a_character;
        output [ 7:0] dat;
        reg    [31:0] tmp;
   begin
          ... ... fill
   end
   endtask
//--------------------------------------------------------
   task init_uart;
        input [31:0] freq;
        input [31:0] baud;
        reg   [31:0] dl;
   begin
          ... ... fill
   end
   endtask
//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
`endif
