OBJECTS = ibcon.o opbrd.o opdev.o rddev.o wrdev.o sib.o statbrd.o rspdev.o\
echo_out.o find_delay.o iclrdev.o
#
CFLAGS =
#
ifeq (/usr/local/include/sys/ugpib.h,$(wildcard /usr/local/include/sys/ugpib.h))
CFLAGS :=  -DCONFIG_GPIB -DNI_DRIVER
GPIB_LIBS := -lgpib
else
ifeq (/usr/include/gpib,$(wildcard /usr/include/gpib))
CFLAGS := -I/usr/include/gpib -DCONFIG_GPIB
ifeq (/usr/include/gpib/ugpib.h,$(wildcard /usr/include/gpib/ugpib.h))
GPIB_LIBS=-lf2c -lgpib -lfl
else
ifeq (/usr/include/gpib/y.tab.h,$(wildcard /usr/include/gpib/y.tab.h))
GPIB_LIBS=-lf2c -lgpib -lfl
CFLAGS := $(CFLAGS) -DREV_2
else
GPIB_LIBS=-lgpib
CFLAGS := $(CFLAGS) -DREV_3
endif
endif
endif
endif
#
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a \
../poclb/poclb.a ../clib/clib.a ../port/port.a ../newlb/newlb.a ../rtelb/rtelb.a
#-lf2c -lgpib -lfl
#
../bin/ibcon: $(OBJECTS)
	$(FC)  -o ../bin/ibcon $(OBJECTS) $(LIBES) $(GPIB_LIBS)
	strip ../bin/ibcon
#
ibcon:
	rm -f ../bin/ibcon
	make
