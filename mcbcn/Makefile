
LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a

ifeq (/usr/src/linux-1.2.12,$(wildcard /usr/src/linux-1.2.12))
CPPFLAGS += -DUSE_OLD_SPECIAL_FLAGS
endif

ifeq (/usr/src/linux/include/digi.h,$(wildcard /usr/src/linux/include/digi.h))
CPPFLAGS += -DDIGI
STRUCT = $(shell fgrep >/dev/null 2>&1 'struct digi_t ' /usr/src/linux/include/digi.h ; echo $$?)

ifeq ($(STRUCT),0)
CPPFLAGS += -DUSE_STRUCT
endif
endif

ifdef FS_SERIAL_CLOCAL
CPPFLAGS += -DFS_SERIAL_CLOCAL
endif

OBJECTS = mcbcn.o

../bin/mcbcn: $(OBJECTS) $(LIBS)

include ../include.mk
