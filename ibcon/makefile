OBJECTS = ibcon.o opbrd.o opdev.o rddev.o wrdev.o ifclr.o get_ibcnt.o \
/usr/lib/libgpib.a
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a \
../clib/clib.a ../lnfch/lnfch.a ../rtelb/rtelb.a -lrtx
#
../bin/ibcon: $(OBJECTS)
	gf77 -g -o ../bin/ibcon $(OBJECTS) $(LIBES)
	../setb/setb ../bin/ibcon
#
ibcon:
	rm -f ../bin/ibcon
	make
