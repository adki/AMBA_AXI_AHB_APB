#------------------------------------------------------------------
# Copyright (c) 2015 by Ando Ki.
# All right reserved.
#
# This code is distributed in the hope that it will
# be useful to understand Ando Ki's work,
# but WITHOUT ANY WARRANTY.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
ARCH	= $(shell uname)
ifeq ($(ARCH), CYGWIN_NT-5.1)
else
ifeq ($(ARCH), MINGW32_NT-5.1)
else
endif
endif
#--------------------------------------------------------
unexport PLIOBJS
#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
#--------------------------------------------------------
STR	= $(shell $(VSIM) -version)
VVER	= $(shell for S in $(STR); do\
		if [ "$${NN}" = "vsim" ]; then\
			echo $$S;\
		fi;\
		NN=$$S;\
	done)
#--------------------------------------------------------
MAJOR	= $(firstword $(subst ., , $(VVER)))
#--------------------------------------------------------
WORK	= work
#--------------------------------------------------------
TOP	= top
#--------------------------------------------------------
ifeq ($(shell test $(MAJOR) -ge 10; echo $$?),0)
	VOPT=-novopt -l transcript
else
	VOPT=-l transcript
endif
#--------------------------------------------------------
all: vlib compile simulate

vlib:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	($(VLIB) $(WORK) || exit -1) 2>&1 | tee compile.log

compile:
	($(VLOG) -lint -work $(WORK)\
		-f modelsim.args || exit -1) 2>&1 | tee -a compile.log

simulate: compile
	$(VSIM) $(VOPT) -c -do "run -all; quit"\
		$(WORK).$(TOP)

#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  transcript
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf
	-@/bin/rm -f  vish_stacktrace.vstf
	-@/bin/rm -f  wlft*
	-@/bin/rm -f  compile.log

cleanup: clean

clobber: cleanup
#--------------------------------------------------------
