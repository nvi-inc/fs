all: ../bin/fsserver shims

CFLAGS += -g -std=gnu99
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lrt -pthread -lnng -ljansson
CPPFLAGS += -pthread

../bin/fsserver: main.o server.o window.o
	$(LINK.o) $^ $(LOADLIBES) -o $@ $(LDLIBS)

.PHONY: shims
shims:
	cp -a shims ../bin/
