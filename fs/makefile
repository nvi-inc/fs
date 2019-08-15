# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
CFLAGS :=  -DNO_FTOK_FS
endif

LDLIBS = -lutil
OBJECTS = fs.o statusprt.o 
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a

all: ../bin/fs

../bin/fs: $(OBJECTS) $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@


.PHONEY: fs
fs:
	rm -f ../bin/fs
	make
