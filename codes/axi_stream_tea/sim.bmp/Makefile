DIRS	= $(subst /,, $(dir $(wildcard */Makefile)))

all:

clean cleanup clobber:
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

.PHONY: all clean cleanup clobber
