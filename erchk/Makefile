#
CFLAGS= -g
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = erchk.o get_err.o
#
../bin/erchk: $(OBJECTS)
	cc -g -o ../bin/erchk $(OBJECTS) $(LIBES) -lm
	strip ../bin/erchk
#
errchk:
	rm -f ../bin/erchk
	make
