OBJECTS = rwand.o bsort.o cksum.o wandwr.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a ../port/port.a\
../flib/flib.a ../fclib/fclib.a\
../clib/clib.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a
#
../bin/rwand: $(OBJECTS)
	f77  -o ../bin/rwand $(OBJECTS) $(LIBES)
	strip ../bin/rwand
