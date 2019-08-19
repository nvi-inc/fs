# fs/oprin/Makefile  --  of UFS 'oprin'
# $Id$

# Copyright (C) 1995 Ari Mujunen. (amn@nfra.nl, Ari.Mujunen@hut.fi)
# modifications to original NASA FS code

# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License.
# See the file 'COPYING' for details.

# $Log$

OBJECTS = oprin.o readl.o
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a

READLINE :=$(shell fgrep >/dev/null 2>&1 'rl_completion_append_character' /usr/include/readline/readline.h ; echo $$?)
ifneq ($(READLINE),0)
READLINE :=$(shell fgrep >/dev/null 2>&1 'rl_compentry_func_t' /usr/include/readline/readline.h ; echo $$?)
endif


ifneq ($(READLINE),0)
CPPFLAGS += -Ireadline-2.0
LIBS += readline-2.0/libreadline.a
else
LDLIBS += -lreadline
endif

TERMLIB = -lncurses

ifeq (/usr/lib/libtermcap.a,$(wildcard /usr/lib/libtermcap.a))
TERMLIB = -ltermcap
endif
NOTSETUTC := $(shell patch --set-utc -v >/dev/null 2>&1;echo $$?)
ifeq (${NOTSETUTC},0)
SETUTC=--set-utc
endif

LDLIBS += $(TERMLIB)

../bin/oprin : $(OBJECTS) $(LIBS)

# We (re)create the GNU Realine library by unpacking the original
# archive, modifying it slightly, and rebuilding the whole thing.
ifneq ($(READLINE),0)
readline-2.0/libreadline.a: readline-2.0.tar.gz patch-rl-2.0
	# Make sure we recreate Readline library again.
	rm -rf readline-2.0
	# Unpack the original GNU Readline 2.0 archive.
	tar xzf readline-2.0.tar.gz
	# Patch, configure and make the library.
	cd readline-2.0; patch -s -p1 ${SETUTC} <../patch-rl-2.0
	# Establish '#include <readline/readline.h>'.
	(cd readline-2.0; rm -f readline; ln -s . readline)
	# Configure and make.
	(cd readline-2.0; ./configure; make)
endif
clean:
	rm -rf *~ *.o readline-2.0 ../bin/oprin
	rm -rf $(OBJECTS)

# Make a "distribution" ie. the tar archive 'oprin.tar' besides
# the 'oprin' directory.  (Distribution needs to be 'clean' ie.
# no object files etc. lying around.)
dist: ../oprin.tar clean

# Creating a tar archive with naming just the directory
# requires that objects et al are cleaned first.
../oprin.tar: clean
	(cd ..; tar cvf oprin.tar oprin)

# Transfer the distribution to ftp area.
ftp-dist: /home/ftp/pub/oprin.tar

/home/ftp/pub/oprin.tar: ../oprin.tar
	cp -p ../oprin.tar /home/ftp/pub/oprin.tar


include ../include.mk
