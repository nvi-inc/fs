# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
CPPFLAGS :=  -DNO_FTOK_FS
endif

LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = fsalloc.o

../bin/fsalloc: $(OBJECTS) $(LIBS)


include ../include.mk
