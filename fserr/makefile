OBJECTS = fserr.o listinit.o hashcode.o
#
#FFLAGS = -c -g -i2
FFLAGS = -c
LIBES = ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
../bin/fserr: $(OBJECTS)
	cc -o ../bin/fserr $(OBJECTS) $(LIBES)
	../setb/setb ../bin/fserr
