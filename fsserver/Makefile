TARGETS = ../bin/fsserver ../bin/fsclient ../bin/spub ../bin/ssub $(SHIMS) 
SHIMS = ../bin/shims/xterm ../bin/shims/fs.prompt
OBJECTS = fsserver.o server.o window.o list.o prompt.o fsclient.o window.o list.o prompt.o ./shims/fs.prompt.o

.PHONY: all
.PHONY: shims
all: $(TARGETS)
shims: $(SHIMS)

CFLAGS += -g -std=gnu99 -Wall -Wextra -Werror=implicit-function-declaration
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
LDLIBS += -lutil -lrt -lanl -lnsl -pthread -lnng -ljansson 
CPPFLAGS += -pthread -D_GNU_SOURCE

../bin/spub: spub.o stream.o msg.o list.o
../bin/ssub: ssub.o msg.o
../bin/fsserver: fsserver.o window.o server.o list.o prompt.o stream.o msg.o jsonutils.o inject_snap.o $(LIBS)
../bin/fsclient: fsclient.o window.o stream.o msg.o list.o prompt.o $(LIBS)

../bin/shims/fs.prompt: shims/fs.prompt.o $(LIBS)
	@mkdir -p ../bin/shims/
	$(LINK.o) $+ $(LOADLIBES) $(LDLIBS) -o $@

shims/fs.prompt.o: shims/fs.prompt.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c $< -o shims/fs.prompt.o

../bin/shims/xterm: shims/xterm
	@mkdir -p ../bin/shims/
ifeq ($(FS_PYTHON_VERSION),2)
	cp -a shims/xterm-python2 ../bin/shims/xterm
else
	cp -a shims/xterm ../bin/shims/xterm
endif


include ../include.mk
