#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
ifeq (/usr/src/linux-1.2.12,\
$(wildcard /usr/src/linux-1.2.12 ))
CFLAGS := $(CFLAGS) -DUSE_OLD_SPECIAL_FLAGS
endif
ifeq (/usr/src/linux/drivers/char/digi.h,\
$(wildcard /usr/src/linux/drivers/char/digi.h ))
CFLAGS := $(CFLAGS) -DDIGI
endif
#
OBJECTS = mcbcn.o
#
../bin/mcbcn: $(OBJECTS)
	cc  -o ../bin/mcbcn $(OBJECTS) $(LIBES)
	strip ../bin/mcbcn
#
mcbcn:
	rm -f ../bin/mcbcn
	make
