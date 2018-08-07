all: ../bin/fsclient

LDFLAGS +=  -L $(shell pwd)/../third_party/lib
CPPFLAGS += -isystem ../third_party/include

CFLAGS += -g -std=gnu99
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lrt -pthread -lnng -ljansson
CPPFLAGS += -pthread -D_XOPEN_SOURCE=700

../bin/fsclient: fsclient.o $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@
