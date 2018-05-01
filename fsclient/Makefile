all: ../bin/fsclient

CFLAGS += -g
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lpthread
CPPFLAGS += -D_XOPEN_SOURCE=700

../bin/fsclient: fsclient.o $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@
