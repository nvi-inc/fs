#
CFLAGS=
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS =\
dscon.o
#
../bin/dscon: $(OBJECTS) $(LIBES)
	cc -o ../bin/dscon $(OBJECTS) $(LIBES) -lm
	strip ../bin/dscon
#
dscon:
	rm -f ../bin/dscon
	make
