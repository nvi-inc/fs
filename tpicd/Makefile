LIBES = ../clib/clib.a ../poclb/poclb.a ../rtelb/rtelb.a
#
../bin/tpicd: tpicd.o $(OBJECTS)
	cc  -o ../bin/tpicd tpicd.o $(OBJECTS) $(LIBES)
	strip ../bin/tpicd

tpicd:
	rm -f ../bin/tpicd
	make
#
