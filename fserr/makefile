OBJECTS = fserr.o listinit.o hashcode.o
#
#FFLAGS = -c  -i2
FFLAGS = -c
LIBES = ../clib/clib.a ../rtelb/rtelb.a
#
../bin/fserr: $(OBJECTS)
	cc -o ../bin/fserr $(OBJECTS) $(LIBES)
	strip ../bin/fserr
