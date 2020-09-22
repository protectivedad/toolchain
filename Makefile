all: install

SUBDIRS = kernel binutils elfkickers gcc uclibc

STAGES := $(SUBDIRS) startfiles libgcc final

.PHONY : install clean distclean $(STAGES)

headers:
	$(MAKE) -C kernel headers
	$(MAKE) -C uclibc headers

binutils: headers
	$(MAKE) -C binutils

elfkickers: binutils
	$(MAKE) -C elfkickers

gcc: elfkickers
	$(MAKE) -C gcc gcc

startfiles: gcc
	$(MAKE) -C uclibc startfiles

libgcc: startfiles
	$(MAKE) -C gcc libgcc

uclibc: libgcc
	$(MAKE) -C uclibc
	$(MAKE) -C uclibc install_hostutils

install: uclibc
	$(MAKE) -C gcc

clean: 
	for dir in $(SUBDIRS); do \
		if [ -d $$dir ] ; then \
			if [ -f $$dir/Makefile ] ; then \
				$(MAKE) -C $$dir clean; \
			fi \
		fi \
	done

distclean: 
	for dir in $(SUBDIRS); do \
		if [ -d $$dir ] ; then \
			if [ -f $$dir/Makefile ] ; then \
				$(MAKE) -C $$dir distclean; \
			fi \
		fi \
	done
