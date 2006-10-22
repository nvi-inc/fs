#
LIBS=../../vex/vex.a -lf2c -lfl
OBJECTS=w.o
CC=gcc

FFLAGS = -c 
LIBES = ../port/port.a ../fslb/fslb.a ../lnfch/lnfch.a  \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../newlb/newlb.a\
../rtelb/rtelb.a
#
w: $(OBJECTS)
	$(FC)  -o w $(OBJECTS) $(LIBS)
