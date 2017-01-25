#
CFLAGS= 
LIBES = ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = fscom.o
#
../bin/fscom: $(OBJECTS)
	cc  -o ../bin/fscom $(OBJECTS) $(LIBES)
	strip ../bin/fscom
#
fscom:
	rm -f ../bin/fscom
	make
