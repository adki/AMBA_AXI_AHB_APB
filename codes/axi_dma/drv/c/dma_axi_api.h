#ifndef DMA_AXI_API_H
#define DMA_AXI_API_H
//--------------------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//--------------------------------------------------------------------
// dma_axi_api.h
//--------------------------------------------------------------------
// VERSION = 2014.03.06.
//--------------------------------------------------------------------
#include <stdint.h>
#include "small_libc.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int dma_axi_control( uint32_t *cnt ); // read control register
extern int dma_axi_enable ( int en, int ie );
extern int dma_axi_go     ( uint32_t dst
                          , uint32_t src
                          , uint32_t bnum
                          , uint32_t chunk
                          , int time_out // 0 for blocking
                          );
extern int dma_axi_clear  ( void ); // interrupt clear

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2014.03.06: Start by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
#endif
