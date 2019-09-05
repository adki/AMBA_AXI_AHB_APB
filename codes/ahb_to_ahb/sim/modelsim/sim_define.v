`ifndef _SIM_DEFINE_V_
`define _SIM_DEFNE_V_
//-----------------------------------------------------------------------
// Copyright (c) 2013 by Ando Ki
// All rights reserved.
//
// This program is distributed in the hope that it
// will be useful to understand Ando Ki's work,
// BUT WITHOUT ANY WARRANTY.
//-----------------------------------------------------------------------
`define SIM      // define this for simulation case if you are not sure
`define VCD       // define this for VCD waveform dump
`undef  DEBUG
`define RIGOR
`define LOW_POWER
//-----------------------------------------------------------------------
`define CLK_FREQ   50000000
`define MEM_DELAY  1
//-----------------------------------------------------------------------
`define SINGLE_TEST
//`define BURST_TEST
//-----------------------------------------------------------------------
`endif
