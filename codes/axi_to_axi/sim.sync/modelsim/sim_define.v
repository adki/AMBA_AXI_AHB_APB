`ifndef SIM_DEFINE_V
`define SIM_DEFINE_V

`define SIM
`undef  SYN
`define RIGOR
`define VCD
`undef  XILINX

`define WIDTH_CID    4  // additional id bit-width
`define WIDTH_ID     4  // id bit-width (do not modify)
`define WIDTH_AD    32  // address bus width (do not modify)
`define WIDTH_DA    32  // data bus width
`define WIDTH_DS    `WIDTH_DA/8 // num of bytes in WIDTH_DA
`define ADDR_LENGTH 12  // size of memory 1<<ADDR_LENGTH bytes

`undef  AMBA_AXI_CACHE
`undef  AMBA_AXI_PROT
`undef  AMBA_AXI4

`define ACLK_FREQ     50000000.0 // 50Mhz
`define S_ACLK_FREQ  777000000.0

`endif
