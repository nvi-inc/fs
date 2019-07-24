OBJECTS = moon.o gd2xy.o moonp.o papvl.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a
#
../bin/moon: $(OBJECTS)
	gf77 -g -o ../bin/moon $(OBJECTS) $(LIBES) -lrtx
	../setb/setb ../bin/moon
