OBJECTS= portopen.o portread.o portwrite.o portbaud.o portflush.o portoutdrain.o\
portdelay.o portclose.o

ifeq (/usr/src/linux-1.2.12,$(wildcard /usr/src/linux-1.2.12 ))
CPPFLAGS += -DUSE_OLD_SPECIAL_FLAGS
endif

ifeq (/usr/src/linux/include/digi.h,$(wildcard /usr/src/linux/include/digi.h ))
CPPFLAGS += -DDIGI
endif

ifdef FS_SERIAL_CLOCAL
CPPFLAGS += -DFS_SERIAL_CLOCAL
endif

port.a: $(OBJECTS)

include ../include.mk
