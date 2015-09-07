#
LIBS=../../vex/vex.a -lf2c -lfl
OBJECTS1=w1.o
OBJECTS2=w2.o
CC=gcc

FFLAGS = -c 
LIBES = ../port/port.a ../fslb/fslb.a ../lnfch/lnfch.a  \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../newlb/newlb.a\
../rtelb/rtelb.a
#
all: w1 w2
#
w1: $(OBJECTS1)
	$(FC)  -o w1 $(OBJECTS1) $(LIBS)
#
w2: $(OBJECTS2)
	$(FC)  -o w2 $(OBJECTS2) $(LIBS)
