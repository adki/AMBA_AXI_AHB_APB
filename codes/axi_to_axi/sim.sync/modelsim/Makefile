#--------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile

#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
WORK	= work
PLIOBJS =
TOP	= top

#--------------------------------------------------------
all: vlib compile simulate

vlib:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	($(VLIB) $(WORK) || exit -1) 2>&1 | tee compile.log

compile:
	($(VLOG) -lint -work $(WORK) -f modelsim.args || exit -1) 2>&1 | tee -a compile.log

simulate: compile
	$(VSIM) -novopt -c -do "run -all; quit" $(WORK).$(TOP) || exit -1

#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  transcript compile.log
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf
	-@/bin/rm -f  vish_stacktrace.vstf

cleanup: clean

clobber: cleanup
