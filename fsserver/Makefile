.PHONY: all
all: ../bin/fsserver ../bin/fsclient shims

CFLAGS += -g -std=gnu99 -Wall -Wextra -Werror=implicit-function-declaration
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lrt -pthread -lnng -ljansson
CPPFLAGS += -pthread

../bin/fsserver: fsserver.o server.o window.o list.o prompt.o
	$(LINK.o) $^ $(LOADLIBES) -o $@ $(LDLIBS)

../bin/fsclient: fsclient.o window.o list.o prompt.o $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

../bin/shims/fs.prompt: ./shims/fs.prompt.o $(LIBS)
	mkdir -p ../bin/shims/
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

../bin/shims/xterm: shims/xterm
	mkdir -p ../bin/shims/
	cp -a shims/xterm ../bin/shims/

.PHONY: shims
shims: ../bin/shims/xterm ../bin/shims/fs.prompt


.PHONY: clean
clean:
	-rm *.o
	-rm ../bin/fsserver
