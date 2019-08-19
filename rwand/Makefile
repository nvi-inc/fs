OBJECTS = rwand.o bsort.o cksum.o wandwr.o
LIBS = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a ../port/port.a\
../flib/flib.a ../fclib/fclib.a\
../clib/clib.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a

../bin/rwand: $(OBJECTS) $(LIBS)
	
LDLIBS += $(FLIBS)

include ../include.mk
