LIBES = ../poclb/poclb.a  ../clib/clib.a ../rtelb/rtelb.a
#
../bin/flagr: flagr.o $(OBJECTS)
	cc  -o ../bin/flagr flagr.o $(OBJECTS) $(LIBES)
	strip ../bin/flagr

flagr:
	rm -f ../bin/flagr
	make
#
