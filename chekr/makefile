OBJECTS = chekr.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a \
../clib/clib.a ../lnfch/lnfch.a ../rtelb/rtelb.a -lrtx
#
../bin/chekr: $(OBJECTS)
	gf77 -g -o ../bin/chekr $(OBJECTS) $(LIBES)
	../setb/setb ../bin/chekr
#
chekr:
	rm -f ../bin/chekr
	make
