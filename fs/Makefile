# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#

ifdef NO_FTOK_FS
CFLAGS :=  -DNO_FTOK_FS
endif

CFLAGS += -g

LDLIBS = -lutil
OBJECTS = fs.o statusprt.o 
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a

all: ../bin/fs

ifeq "$(FS_DISPLAY_SERVER)" "no"  
CPPFLAGS += -DNO_SERVER
else
all: ../bin/fsclient
CFLAGS += -D_XOPEN_SOURCE=700
LDLIBS += -lnanomsg
OBJECTS += start_server.o
endif

../bin/fs: $(OBJECTS) $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

../bin/fsclient: fsclient.o $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

fs: 
	rm ../bin/fs
	make
