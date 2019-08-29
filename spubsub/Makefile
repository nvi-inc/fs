LDFLAGS +=  -L $(shell pwd)/../third_party/lib
CPPFLAGS += -isystem ../third_party/include

CFLAGS += -std=c99
CPPFLAGS += -D_GNU_SOURCE
LDLIBS += -pthread -lutil -lanl -lrt -lnsl -lnng

OBJECTS = spub.o ssub.o msg.o
TARGETS = ../bin/spub ../bin/ssub

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


include ../include.mk
