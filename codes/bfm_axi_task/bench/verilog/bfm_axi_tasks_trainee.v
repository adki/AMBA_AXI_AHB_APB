`ifndef BFM_AXI_TASKS_V
`define BFM_AXI_TASKS_V
//----------------------------------------------------------------
//  Copyright (c) 2013 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// bfm_axi_tasks.v
//----------------------------------------------------------------
// VERSION: 2013.02.03.
//---------------------------------------------------------
reg [7:0] dataWB[0:1023];
reg [7:0] dataRB[0:1023];
//----------------------------------------------------------------
// Read-After-Write
task test_raw;
     input [31:0] id;
     input [31:0] saddr; // start address
     input [31:0] depth; // size in byte
     input [31:0] bsize; // burst size in byte
     input [31:0] bleng; // burst length
     reg   [31:0] addr;
     integer      idx, idy, idz, error;
begin
    error = 0;
    addr = saddr;
    for (idy=0; idy<depth; idy=idy+bsize) begin
        for (idx=0; idx<bsize; idx=idx+1) begin
            dataWB[idx] = idy + idx + 1;
        end
//$display($time,,"%m idy=%03d", idy);
        write_task( id //input [31:0]         id;
                  , addr  //addr;
                  , bsize //size; // 1 ~ 128 byte in a beat
                  , bleng //leng; // 1 ~ 16  beats in a burst
                  , 0     //type; // burst type
                  );
        read_task ( id //input [31:0]         id;
                  , addr  //addr;
                  , bsize //size; // 1 ~ 128 byte in a beat
                  , bleng //leng; // 1 ~ 16  beats in a burst
                  , 0     //type; // burst type
                  );
        for (idz=0; idz<bsize; idz=idz+1) begin
             if (dataWB[idz]!=dataRB[idz]) begin
                 error = error + 1;
                 $display($time,,"%m Error A:0x%x D:0x%x, but 0x%x expected",
                                  addr+idz, dataRB[idz], dataWB[idz]);
             end
             `ifdef DEBUG
             else $display($time,,"%m OK A:0x%x D:0x%x", addr+idz, dataRB[idz]);
             `endif
        end
        addr = addr + bsize;
    end
    if (error==0) $display($time,,"%m test_raw from 0x%08x to 0x%08x %03d-size %03d-leng OK", saddr, saddr+depth-1, bsize, bleng);
end
endtask
//----------------------------------------------------------------
// Read-After-Write ALL
task test_raw_all;
     input [31:0] id;
     input [31:0] saddr; // start address
     input [31:0] depth; // size in byte
     input [31:0] bsize; // burst size in byte
     input [31:0] bleng; // burst length
     reg   [31:0] addr;
     integer      idx, idy, idz, error;
begin
    error = 0;
    addr = saddr;
    for (idy=0; idy<depth; idy=idy+bsize) begin
        for (idx=0; idx<bsize; idx=idx+1) begin
            dataWB[idx] = idy + idx + 1;
        end
//$display($time,,"%m idy=%03d", idy);
        write_task( id //input [31:0]         id;
                  , addr  //addr;
                  , bsize //size; // 1 ~ 128 byte in a beat
                  , bleng //leng; // 1 ~ 16  beats in a burst
                  , 0     //type; // burst type
                  );
        addr = addr + bsize;
    end
    addr = saddr;
    for (idy=0; idy<depth; idy=idy+bsize) begin
        read_task ( id //input [31:0]         id;
                  , addr  //addr;
                  , bsize //size; // 1 ~ 128 byte in a beat
                  , bleng //leng; // 1 ~ 16  beats in a burst
                  , 0     //type; // burst type
                  );
        for (idz=0; idz<bsize; idz=idz+1) begin
             if ((idy+idz+1)!=dataRB[idz]) begin
                 error = error + 1;
                 $display($time,,"%m Error A:0x%x D:0x%x, but 0x%x expected",
                                  addr+idz, dataRB[idz], idy+idz+1);
             end
        end
        addr = addr + bsize;
    end
    if (error==0) $display($time,,"%m test_raw_all from 0x%08x to 0x%08x %03d-size %03d-leng OK", saddr, saddr+depth-1, bsize, bleng);
end
endtask
//----------------------------------------------------------------
task read_task;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
begin
     fork
     read_address_channel(id,addr,size,leng,type);
     read_data_channel(id,addr,size,leng,type);
     join
end
endtask
//----------------------------------------------------------------
task read_address_channel;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
begin
     // fill your code here
end
endtask
//----------------------------------------------------------------
task read_data_channel;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
     reg   [WIDTH_AD-1:0] naddr;
     reg   [WIDTH_DS-1:0] strb;
     reg   [WIDTH_DA-1:0] maskT;
     reg   [WIDTH_DA-1:0] dataR;
     integer idx, idy, idz;
begin
     idz = 0;
     naddr  = addr;
     @ (posedge ACLK);
     RREADY <= #1 1'b1;
     for (idx=0; idx<leng; idx=idx+1) begin
          @ (posedge ACLK);
          while (RVALID==1'b0) @ (posedge ACLK);
          strb = get_strb(naddr, size);
          dataR = RDATA;
          for (idy=0; idy<WIDTH_DS; idy=idy+1) begin
               //if (strb[idy]) dataRB[naddr-addr+idy] = dataR&8'hFF;
               if (strb[idy]) begin
                   dataRB[idz] = dataR&8'hFF; // justified
                   idz = idz + 1;
               end
               dataR = dataR>>8;
          end
          if (id!=RID) begin
             $display($time,,"%m Error id/RID mis-match for read-data-channel", id, RID);
          end
          if (idx==leng-1) begin
             if (RLAST==1'b0) begin
                 $display($time,,"%m Error RLAST expected for read-data-channel");
             end
          end else begin
              @ (negedge ACLK);
              naddr = get_next_addr( naddr  // current address
                                   , size  // num of bytes in a beat
                                   , type);// type of burst
          end
     end
     RREADY <= #1 'b0;
     @ (negedge ACLK);
end
endtask
//----------------------------------------------------------------
task write_task;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
begin
     // fill your code here
end
endtask
//----------------------------------------------------------------
task write_address_channel;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
begin
    // fill your code here
end
endtask
//----------------------------------------------------------------
task write_data_channel;
     input [31:0]         id;
     input [WIDTH_AD-1:0] addr;
     input [31:0]         size; // 1 ~ 128 byte in a beat
     input [31:0]         leng; // 1 ~ 16  beats in a burst
     input [31:0]         type; // burst type
     reg   [WIDTH_AD-1:0] naddr;
     integer idx;
begin
     naddr  = addr;
     @ (posedge ACLK);
     WID    <= #1 id;
     WVALID <= #1 1'b1;
     for (idx=0; idx<leng; idx=idx+1) begin
          WDATA <= #1 get_data(addr, naddr, size);
          WSTRB <= #1 get_strb(naddr, size);
          WLAST <= #1 (idx==(leng-1));
          naddr <= get_next_addr(naddr, size, type);
          @ (posedge ACLK);
          while (WREADY==1'b0) @ (posedge ACLK);
     end
     WLAST  <= #1 'b0;
     WVALID <= #1 'b0;
     @ (negedge ACLK);
end
endtask
//----------------------------------------------------------------
task write_resp_channel;
     input [31:0] id;
begin
     // fill your code here
end
endtask
//----------------------------------------------------------------
// input: num of bytes
// output: AxSIZE[2:0] code
function [2:0] get_size;
   input [7:0] size;
begin
   case (size)
     1: get_size = 0;
     2: get_size = 1;
     4: get_size = 2;
     8: get_size = 3;
    16: get_size = 4;
    32: get_size = 5;
    64: get_size = 6;
   128: get_size = 7;
   default: get_size = 0;
   endcase
end
endfunction
//----------------------------------------------------------------
function [WIDTH_DS-1:0] get_strb;
    input [31:0] addr;
    input [31:0] size; // num of bytes in a beat
    integer offset;
    reg   [127:0] bit_size;
begin
    offset   = addr%WIDTH_DS;
    case (size)
      1: bit_size = {  1{1'b1}};
      2: bit_size = {  2{1'b1}};
      4: bit_size = {  4{1'b1}};
      8: bit_size = {  8{1'b1}};
     16: bit_size = { 16{1'b1}};
     32: bit_size = { 32{1'b1}};
     64: bit_size = { 64{1'b1}};
    128: bit_size = {128{1'b1}};
    default: bit_size = 0;
    endcase
    get_strb = bit_size<<offset;
end
endfunction
//----------------------------------------------------------------
function [WIDTH_AD-1:0] get_next_addr;
    input [31:0] addr; // current address
    input [31:0] size; // num of bytes in a beat
    input [31:0] type; // type of burst
    integer offset;
begin
    case (type[1:0])
    2'b00: get_next_addr = addr; // fixed
    2'b01: begin // increment
           offset = addr%WIDTH_DS;
           if ((offset+size)<=WIDTH_DS) begin
               get_next_addr = addr + size;
           end else begin // (offset+size)>nb
               get_next_addr = addr + WIDTH_DS - size;
           end
           end
    2'b10: begin // wrap
           if ((addr%size)!=0) begin
              $display($time,,"%m wrap-burst not aligned");
              get_next_addr = addr;
           end else begin
               offset = addr%WIDTH_DS;
               if ((offset+size)<=WIDTH_DS) begin
                   get_next_addr = addr + size;
               end else begin // (offset+size)>nb
                   get_next_addr = addr + WIDTH_DS - size;
               end
           end
           end
    default: $display($time,,"%m Error un-defined burst-type: %2b", type);
    endcase
end
endfunction
//----------------------------------------------------------------
// dataWB[0]   = saddr + 0;
// dataWB[1]   = saddr + 1;
// dataWB[2]   = saddr + 2;
//
function [WIDTH_DA-1:0] get_data;
    input [WIDTH_AD-1:0] saddr; // start address
    input [WIDTH_AD-1:0] addr;  // current address
    input [31:0]         size;
    reg   [ 7:0]         data[0:WIDTH_DS-1];
    integer offset, idx, idy, idz, ids;
begin
    `ifdef RIGOR
    for (idx=0; idx<WIDTH_DS; idx=idx+1) begin
         data[idx] = 'bX;
    end
    `endif
    offset = addr%WIDTH_DS;
    ids = 0;
    for (idx=addr%WIDTH_DS; (idx<WIDTH_DS)&&(ids<size); idx=idx+1) begin
         idz = addr+(idx-offset)-saddr;
         data[idx] = dataWB[idz];
//$display($time,,"%m sa=%04x ad=%04x idx=%03d idz=%03d", saddr, addr, idx, idz);
         ids = ids + 1;
    end
    get_data = 0;
    for (idy=0; idy<WIDTH_DS; idy=idy+1) begin
         get_data = get_data|(data[idy]<<(8*idy));
    end
    //for (idy=WIDTH_DS-1; idy>=0; idy=idy-1) begin
    //     get_data = (get_data<<8)|data[idy];
    //end
end
endfunction
//----------------------------------------------------------------
// Revision History
//
// 2013.02.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
`endif
