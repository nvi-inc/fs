#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
ifeq (/usr/src/linux/drivers/char/digi.h,\
$(wildcard /usr/src/linux/drivers/char/digi.h))
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
