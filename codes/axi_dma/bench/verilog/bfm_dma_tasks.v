`ifndef BFM_DMA_TASKS_V
`define BFM_DMA_TASKS_V
   //---------------------------------------------------------
   localparam CSRA_NAME0   = 32'hA000_0000 + 8'h00,
              CSRA_NAME1   = 32'hA000_0000 + 8'h04,
              CSRA_NAME2   = 32'hA000_0000 + 8'h08,
              CSRA_NAME3   = 32'hA000_0000 + 8'h0C,
              CSRA_COMP0   = 32'hA000_0000 + 8'h10,
              CSRA_COMP1   = 32'hA000_0000 + 8'h14,
              CSRA_COMP2   = 32'hA000_0000 + 8'h18,
              CSRA_COMP3   = 32'hA000_0000 + 8'h1C,
              CSRA_VERSION = 32'hA000_0000 + 8'h20,
              CSRA_CONTROL = 32'hA000_0000 + 8'h30,
              CSRA_NUM     = 32'hA000_0000 + 8'h40,
              CSRA_SOURCE  = 32'hA000_0000 + 8'h44,
              CSRA_DEST    = 32'hA000_0000 + 8'h48;
   //---------------------------------------------------------
   task csr_test;
   begin
     read_task(3, CSRA_NAME0  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "NAME0  ", CSRA_NAME0  , dataRW[0]);
     read_task(3, CSRA_NAME1  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "NAME1  ", CSRA_NAME1  , dataRW[0]);
     read_task(3, CSRA_NAME2  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "NAME2  ", CSRA_NAME2  , dataRW[0]);
     read_task(3, CSRA_NAME3  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "NAME3  ", CSRA_NAME3  , dataRW[0]);
     read_task(3, CSRA_COMP0  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "COMP0  ", CSRA_COMP0  , dataRW[0]);
     read_task(3, CSRA_COMP1  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "COMP1  ", CSRA_COMP1  , dataRW[0]);
     read_task(3, CSRA_COMP2  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "COMP2  ", CSRA_COMP2  , dataRW[0]);
     read_task(3, CSRA_COMP3  , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "COMP3  ", CSRA_COMP3  , dataRW[0]);
     read_task(3, CSRA_VERSION, 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "VERSION", CSRA_VERSION, dataRW[0]);
     read_task(3, CSRA_CONTROL, 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "CONTROL", CSRA_CONTROL, dataRW[0]);
     read_task(3, CSRA_NUM    , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "NUM    ", CSRA_NUM    , dataRW[0]);
     read_task(3, CSRA_SOURCE , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "SOURCE ", CSRA_SOURCE , dataRW[0]);
     read_task(3, CSRA_DEST   , 4, 1, 1); $display($time,,"%m %s A:0x%08X D:0x%08X", "DEST   ", CSRA_DEST   , dataRW[0]);
   end
   endtask
   //---------------------------------------------------------
   // fill, DMA, test
   task one_dma_test;
   input [31:0] src;
   input [31:0] dst;
   input [15:0] bnum;
   input [ 7:0] chunk; // 
   input [ 7:0] offset;
   reg [31:0] ad, dat, exp;
   reg [ 3:0] be;
   integer err;
   begin
       dat = 32'h0403_0201 + {4{offset}};
       for (ad=src; ad<(src+bnum); ad=ad+1) begin
            be = (ad[1:0]==0) ? 4'b0001
               : (ad[1:0]==1) ? 4'b0010
               : (ad[1:0]==2) ? 4'b0100
               :                4'b1000;
            top.u_mem.u_dpram.write(ad, dat, be);
            if (ad[1:0]==0) dat[ 7: 0] = dat[ 7: 0] + 4;
            if (ad[1:0]==1) dat[15: 8] = dat[15: 8] + 4;
            if (ad[1:0]==2) dat[23:16] = dat[23:16] + 4;
            if (ad[1:0]==3) dat[31:24] = dat[31:24] + 4;
       end
//for (ad=src; ad<(src+bnum); ad=ad+1) begin
//top.u_mem.u_dpram.read(ad, dat);
//end
       one_dma(src, dst, bnum, chunk);
       err=0;
       exp = 32'h0403_0201 + {4{offset}};
       for (ad=dst; ad<(dst+bnum); ad=ad+1) begin
            top.u_mem.u_dpram.read(ad, dat);
//$display($time,,"%m exp=0x%08X dat=0x%08X", exp, dat);
            if (ad[1:0]==0) begin 
                 if (dat[ 7: 0]!==exp[ 7: 0]) begin err=err+1;
                 end 
            end
            if (ad[1:0]==1) begin 
                 if (dat[15: 8]!==exp[15: 8]) begin err=err+1; 
                 end
            end
            if (ad[1:0]==2) begin 
                 if (dat[23:16]!==exp[23:16]) begin err=err+1; 
                 end
            end
            if (ad[1:0]==3) begin 
                 if (dat[31:24]!==exp[31:24]) begin err=err+1; 
            end
            end
            if (ad[1:0]==0) exp[ 7: 0] = exp[ 7: 0] + 4;
            if (ad[1:0]==1) exp[15: 8] = exp[15: 8] + 4;
            if (ad[1:0]==2) exp[23:16] = exp[23:16] + 4;
            if (ad[1:0]==3) exp[31:24] = exp[31:24] + 4;
       end
       if (err>0) $display($time,,"%m mismatch %d", err);
       else       $display($time,,"%m OK");
   end
   endtask
   //---------------------------------------------------------
   task one_dma;
   input [31:0] src;
   input [31:0] dst;
   input [15:0] bnum;
   input [ 7:0] chunk;
   reg [31:0] value;
   begin
     {dataWB[3],dataWB[2],dataWB[1],dataWB[0]} = 32'h8000_0001; // enable
     value = {dataWB[3],dataWB[2],dataWB[1],dataWB[0]};
     write_task(2, CSRA_CONTROL, 4, 1, 1);
     {dataWB[3],dataWB[2],dataWB[1],dataWB[0]} = src;
     write_task(2, CSRA_SOURCE, 4, 1, 1);
     {dataWB[3],dataWB[2],dataWB[1],dataWB[0]} = dst;
     write_task(2, CSRA_DEST, 4, 1, 1);
     value = bnum | (chunk<<16) | (1<<31);
     {dataWB[3],dataWB[2],dataWB[1],dataWB[0]} = value;
     write_task(2, CSRA_NUM, 4, 1, 1);
     while (value&32'h8000_0000) begin
        read_task(2, CSRA_NUM, 4, 1, 1);
        value = dataRW[0];
     end
   end
   endtask
   //---------------------------------------------------------
`endif
