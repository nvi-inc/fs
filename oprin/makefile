# fs/oprin/Makefile  --  of UFS 'oprin'
# $Id$

# Copyright (C) 1995 Ari Mujunen. (amn@nfra.nl, Ari.Mujunen@hut.fi)
# modifications to original NASA FS code

# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License.
# See the file 'COPYING' for details.

# $Log$

# We want the built-in default GNU Make actions to use 'gcc' as our C compiler.
#CC = gcc
#CC = gcc-2.95

READLINE :=$(shell fgrep >/dev/null 2>&1 'rl_compentry_func_t' /usr/include/readline/readline.h ; echo $$?)

# In all default compilation commands involving the C preprocessor,
# use these preprocessor control flags (include dirs, defines).
ifneq ($(READLINE),0)
CPPFLAGS = -Ireadline-2.0

# Flags for default $(CC) compilations.
CFLAGS = -Wall -pipe -O2 -fomit-frame-pointer -DREADLINE
# debugging CFLAGS =  -Wall -pipe -g
endif

# What objects and libraries are linked together.
OBJECTS = oprin.o readl.o
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
ifneq ($(READLINE),0)
LIBS := $(LIBS) readline-2.0/libreadline.a
else
LIBS := $(LIBS) -lreadline
endif
# (Note: ":=" evaluates '$(xxx)'s on right-hand side immediately whereas
#        "=" stores the '$(xxx)' var references and evaluates them again
#            whenever the left-hand-side variable is used.)

TERMLIB = -lncurses
#
ifeq (/usr/lib/libtermcap.a,$(wildcard /usr/lib/libtermcap.a))
TERMLIB = -ltermcap
endif
NOTSETUTC := $(shell patch --set-utc -v >/dev/null 2>&1;echo $$?)
ifeq (${NOTSETUTC},0)
SETUTC=--set-utc
endif

# The main target, 'oprin'.  Both new/updated object files and libraries
# cause relinking; if libraries are missing, this makefile cannot
# create them on its own, it says "don't know how to make $(LIBS)".
../bin/oprin : $(OBJECTS) $(LIBS)
	gcc -o ../bin/oprin $(OBJECTS) $(LIBS) $(TERMLIB)
	strip ../bin/oprin

# Actually 'oprin.c' is not dependent on the lib archive file
# but the include files in 'readline-2.0' directory, but still:
ifneq ($(READLINE),0)
oprin.o: oprin.c readline-2.0/libreadline.a
#readl.c too
readl.o: readl.c readline-2.0/libreadline.a
else
oprin.o: oprin.c
#readl.c too
readl.o: readl.c
endif
# (Note that when we don't specify the command(s) to execute,
#  GNU make defaults to the built-in rule actions.)

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
