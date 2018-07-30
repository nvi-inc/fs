LDFLAGS +=  -L $(shell pwd)/../third_party/lib
CPPFLAGS += -isystem ../third_party/include

CFLAGS += -std=c99
CPPFLAGS += -D_GNU_SOURCE
LDLIBS += -pthread -lutil -lanl -lrt -lnsl -lnng

ifeq ($(DEBUG), memory)
CFLAGS += -g -fno-omit-frame-pointer -fsanitize=address
CPPFLAGS += -fno-omit-frame-pointer -fsanitize=address
LDLIBS += -fno-omit-frame-pointer -fsanitize=address
endif

ifeq ($(DEBUG), thread)
CFLAGS += -g -fno-omit-frame-pointer -fsanitize=thread
CPPFLAGS += -fno-omit-frame-pointer -fsanitize=thread
LDLIBS += -fno-omit-frame-pointer -fsanitize=thread
endif


all: ../bin/spub ../bin/ssub 


../bin/spub: spub.o msg.o
../bin/ssub: ssub.o msg.o

../bin/%:
	$(LINK.o) -o $@ $^ $(LOADLIBES) $(LDLIBS)


.PHONY: clean
clean: 
	-rm -f *.o
	-rm -f ../bin/spub ../bin/ssub
