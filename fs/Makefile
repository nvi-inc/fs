# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
CPPFLAGS :=  -DNO_FTOK_FS
endif

ifdef FS_DISPLAY_SERVER_NO_MAKE
CPPFLAGS +=  -DFS_DISPLAY_SERVER_NO_MAKE
endif

LDLIBS = -lutil
OBJECTS = fs.o statusprt.o 
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a

../bin/fs: $(OBJECTS) $(LIBS)

include ../include.mk
