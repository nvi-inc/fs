TARGETS = ../bin/fsserver ../bin/fsclient ../bin/spub ../bin/ssub $(SHIMS) 
SHIMS = ../bin/shims/xterm ../bin/shims/fs.prompt
OBJECTs = fsserver.o server.o window.o list.o prompt.o fsclient.o window.o list.o prompt.o ./shims/fs.prompt.o 

.PHONY: all
.PHONY: shims
all: $(TARGETS)
shims: $(SHIMS)

CFLAGS += -g -std=gnu99 -Wall -Wextra -Werror=implicit-function-declaration
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lrt -lanl -lnsl -pthread -lnng -ljansson 
CPPFLAGS += -pthread -D_GNU_SOURCE

../bin/spub: spub.o msg.o
../bin/ssub: ssub.o msg.o
../bin/fsserver: fsserver.o server.o window.o list.o prompt.o
../bin/fsclient: fsclient.o window.o list.o prompt.o $(LIBS)

../bin/shims/fs.prompt: shims/fs.prompt.o $(LIBS)
	@mkdir -p ../bin/shims/
	$(LINK.o) $+ $(LOADLIBES) $(LDLIBS) -o $@

shims/fs.prompt.o: shims/fs.prompt.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c $< -o shims/fs.prompt.o

../bin/shims/xterm: shims/xterm
	@mkdir -p ../bin/shims/
	cp -a shims/xterm ../bin/shims/


include ../include.mk
