//----------------------------------------------------------------
//  Copyright (c) by Ando Ki.
//  All right reserved.
//----------------------------------------------------------------
// tty.v
//----------------------------------------------------------------
// VERSION: 2011.03.12.
//----------------------------------------------------------------
`timescale 1ns/1ns

module tty #(parameter BAUD_RATE  = 115200, LOOPBACK=1)
(
   output  reg   STX,
   input   wire  SRX
);
   //--------------------------------------------
   localparam INTERVAL = (1000000000/BAUD_RATE); // nsec
   //--------------------------------------------
   reg [7:0] data  = 0;
   //--------------------------------------------
   initial begin STX = 1'b1; end
   //--------------------------------------------
   always @ (negedge SRX) begin
        receive(data);
        $write("%c", data); $fflush();
        if (LOOPBACK) send(data);
   end
   //--------------------------------------------
   task receive;
        output [7:0] value;
        integer      x;
   begin
          value = 0;
          #(INTERVAL*1.5);
          for (x=0; x<8; x=x+1) begin // LSB comes first
                  value[x] = SRX;
                  #(INTERVAL);
          end
   end
   endtask
   //--------------------------------------------
   task send;
        input [7:0] value;
        integer     y;
   begin
        STX = 1'b0;
        #(INTERVAL);
        for (y=0; y<8; y=y+1) begin // LSB goes first
           STX = value[y];
           #(INTERVAL);
        end
        STX = 1'b1;
        #(INTERVAL);
   end
   endtask
   //--------------------------------------------
endmodule

//----------------------------------------------------------------
//   RS232-C signal at the end of UART not on the cable.
//   ___    __ __ __ __ __ __ __ ________
//      |  |  |  |  |  |  |  |  |  |   
//      |  |D0|D1|D2|D3|D4|D5|D6|D7|S
//      |__|__|__|__|__|__|__|__|__|
//        |
//        0
//  starts by changing 1 to 0.
//  stops by returing to 1.
//----------------------------------------------------------------
// Revision History
//
// 2011.03.12.: renamed.
// 2011.02.19.: 'CLOCK', 'RESET' removed by Ando Ki.
// 2010.06.16.: Signal diagram added by Ando Ki.
// 2010.01.23.: Starting [adki]
//----------------------------------------------------------------
