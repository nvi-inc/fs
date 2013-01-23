OBJECTS = holog.o jr2as.o savoff.o antcn.o onsor.o scmds.o gooff.o local.o\
next.o scmd.o
#
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/holog: $(OBJECTS)
	cc  -o ../bin/holog $(OBJECTS) $(LIBES) -lm
	strip ../bin/holog
#
holog:
	rm -f ../bin/holog
	make
