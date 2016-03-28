LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS =\
recover_log.o
#
../bin/ddout: ddout.o $(OBJECTS)
	cc  -o ../bin/ddout ddout.o $(OBJECTS) $(LIBES)
	strip ../bin/ddout

ddout:
	rm -f ../bin/ddout
	make
#
