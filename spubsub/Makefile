CFLAGS += -std=c99 -g
CPPFLAGS += -D_XOPEN_SOURCE=700
LDFLAGS += -lutil -lnanomsg -lpthread

all: ../bin/spub ../bin/ssub 

spub: spub.o msg.o
ssub: ssub.o msg.o

../bin/spub: spub
	cp $< $@
	rm -f spub
	
../bin/ssub: ssub
	cp $< $@
	rm -f spub
