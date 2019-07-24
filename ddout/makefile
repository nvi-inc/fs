LIBES = ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
OBJECTS = lineset.o printlo.o
#
../bin/ddout: ddout.o $(OBJECTS)
	cc -g -o ../bin/ddout ddout.o $(OBJECTS) $(LIBES)
	../setb/setb ../bin/ddout

ddout:
	rm -f ../bin/ddout
	make
#
