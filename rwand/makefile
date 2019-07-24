OBJECTS = rwand.o bsort.o cksum.o wandwr.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../fslb/fslb.a ../newlb/newlb.a ../lnfch/lnfch.a ../port/port.a\
../flib/flib.a ../fclib/fclib.a\
../clib/clib.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a -lrtx
#
../bin/rwand: $(OBJECTS)
	gf77 -g -o ../bin/rwand $(OBJECTS) $(LIBES)
	../setb/setb ../bin/rwand
