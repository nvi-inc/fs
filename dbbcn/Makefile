#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = dbbcn.o
#
../bin/dbbcn: $(OBJECTS)
	cc  -o ../bin/dbbcn $(OBJECTS) $(LIBES)
	strip ../bin/dbbcn
#
dbbcn:
	rm -f ../bin/dbbcn
	make
