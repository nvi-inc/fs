OBJECTS = ibcon.o opbrd.o opdev.o rddev.o wrdev.o ifclr.o get_ibcnt.o
#
CFLAGS = -I/usr/include/gpib
#
ifeq (/usr/include/gpib,$(wildcard /usr/include/gpib))
GPIB_LIBS=-lf2c -lgpib -lfl
CFLAGS := $(CFLAGS) -DCONFIG_GPIB
endif
#
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a \
../clib/clib.a ../newlb/newlb.a ../rtelb/rtelb.a
#-lf2c -lgpib -lfl
#
../bin/ibcon: $(OBJECTS)
	f77  -o ../bin/ibcon $(OBJECTS) $(LIBES) $(GPIB_LIBS)
	strip ../bin/ibcon
#
ibcon:
	rm -f ../bin/ibcon
	make
