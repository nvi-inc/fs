CPPFLAGS += -I./third_party/include
CFLAGS += -std=c99 -g
CPPFLAGS += -D_XOPEN_SOURCE=700
LDFLAGS += -lutil -lanl -lrt -lpthread -lnsl

all: ../bin/spub ../bin/ssub 

spub.o ssub.o:

../bin/spub: spub.o msg.o third_party/libnanomsg.a
../bin/ssub: ssub.o msg.o third_party/libnanomsg.a

../bin/%:
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

third_party/libnanomsg.a:
	$(MAKE) -s -C third_party

.PHONY: clean
clean: 
	rm -f third_party/libnanomsg.a
	rm -f *.o
	rm -f ../bin/spub ../bin/ssub
