#
# Copyright (c) 2011 by Ando Ki.
# All right reserved.
# 
# This code is distributed in the hope that it will
# be useful to understand Ando Ki's book,
# but WITHOUT ANY WARRANTY.
#

DIRS	= modelsim isim

all:

clean cleanup clobber:
	for D in $(DIRS); do\
		if [ -d $$D ] ; then \
			if [ -f $$D/Makefile ] ; then \
				echo "cd $$D && make -s $@";\
				(cd $$D && make -s $@);\
			fi\
		fi;\
	done
