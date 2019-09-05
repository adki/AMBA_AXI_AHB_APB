//--------------------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//--------------------------------------------------------------------
// dma_axi_api.c
//--------------------------------------------------------------------
// VERSION = 2014.03.06.
//--------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//--------------------------------------------------------------------
#ifdef TRX_BFM
#	include <stdio.h>
#	include "bfm_api.h"
#	define   uart_put_string(x)  printf("%s", (x));
#	define   uart_put_hexn(n,m)  printf("%x", (n));
#else
#   if defined(RIGOR)
#	   include <small_libc.h>
#   endif
#	include "uart_api.h"
#endif
#include "dma_axi_api.h"
#include "memory_map.h"

//--------------------------------------------------------------------
// Register access macros
#ifdef TRX_BFM
#   define REGRD(A,B)         BfmRead((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define REGWR(A,B)         BfmWrite((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define MEM_WRITE_N(A,B,N) BfmWrite((unsigned int)(A), (unsigned int*)(B), 4, (N))
#   define MEM_READ_N(A,B,N)  BfmRead ((unsigned int)(A), (unsigned int*)(B), 4, (N))
#else
#	define REGRD(add,val)      (val) = *((volatile uint32_t *)(add))
#	define REGWR(add,val)     *((volatile uint32_t *)(add)) = (val)
#   define MEM_WRITE_N(A,B,N)   memcpy((A), (B), (N)*4)
#   define MEM_READ_N(A,B,N)    memcpy((B), (A), (N)*4)
#endif

//--------------------------------------------------------------------
#ifndef ADDR_DMA_AHB_START
#error  ADDR_DMA_AHB_START should be defined
#endif

#define CSRA_CONTROL   (ADDR_DMA_AHB_START + 0x30)
#define CSRA_NUM       (ADDR_DMA_AHB_START + 0x40)
#define CSRA_SRC       (ADDR_DMA_AHB_START + 0x44)
#define CSRA_DST       (ADDR_DMA_AHB_START + 0x48)

//--------------------------------------------------------------------
// bit position
#define DMA_AHB_ctl_en     31
#define DMA_AHB_ctl_ip     1
#define DMA_AHB_ctl_ie     0

#define DMA_AHB_num_go     31
#define DMA_AHB_num_busy   30
#define DMA_AHB_num_done   29
#define DMA_AHB_num_chunk  16
#define DMA_AHB_num_bnum   0

//--------------------------------------------------------------------
// bit mask
#define DMA_AHB_ctl_en_MSK     0x80000000
#define DMA_AHB_ctl_ip_MSK     0x2
#define DMA_AHB_ctl_ie_MSK     0x1

#define DMA_AHB_num_go_MSK     0x80000000
#define DMA_AHB_num_busy_MSK   0x40000000
#define DMA_AHB_num_done_MSK   0x20000000
#define DMA_AHB_num_chunk_MSK  0x00FF0000
#define DMA_AHB_num_bnum_MSK   0x0000FFFF

//--------------------------------------------------------------------
// read control register
int dma_axi_control( uint32_t *cnt )
{
    volatile uint32_t value;
    REGRD(CSRA_CONTROL, value);
    *cnt = value;
    return 0;
}

//--------------------------------------------------------------------
// read control register
int dma_axi_enable( int en, int ie )
{
    volatile uint32_t value;
    value = 0;
    if (en) value |= DMA_AHB_ctl_en_MSK;
    if (ie) value |= DMA_AHB_ctl_ie_MSK;
    REGWR(CSRA_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
int dma_axi_go ( uint32_t dst
               , uint32_t src
               , uint32_t bnum
               , uint32_t chunk
               , int time_out)
{
    volatile uint32_t value;
    int dly;
    #if defined(RIGOR)
    //if ((dst&((chunk*4)-1))!=(src&((chunk*4)-1))) {
    if ((dst&0x3)!=(src&0x3)) {
       printf("%s:%s ERROR src and dest address should be the same in terms of alignment 0x%x 0x%x\n",
               __FILE__, __FUNCTION__, src, dst);
    }
    #endif
    REGWR(CSRA_DST, dst);
    REGWR(CSRA_SRC, src);
    value  = DMA_AHB_num_go_MSK | (chunk&0xFF)<<16 | (bnum&0xFFFF);
    REGWR(CSRA_NUM, value);
    dly = 0;
    do { REGRD(CSRA_NUM, value);
         if (time_out) {
             dly++;
             if (dly>time_out) return 1;
         }
    } while (value&DMA_AHB_num_go_MSK);
    return 0;
}
//--------------------------------------------------------------------
// clear interrupt
int dma_axi_clear  ( void ) // interrupt clear
{
    volatile uint32_t value;
    REGRD(CSRA_CONTROL, value);
    value  |= DMA_AHB_ctl_ip_MSK;
    REGWR(CSRA_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
// Revision History
//
// 2014.03.06: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------------------
