OBJECTS = fserr.o listinit.o hashcode.o
#
LIBES =  ../clib/clib.a ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/fserr: $(OBJECTS)
	cc -o ../bin/fserr $(OBJECTS) $(LIBES)
	strip ../bin/fserr
