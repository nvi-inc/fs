# Makefile for tacd
#
#LIBES = ../../stlib/stlib.a ../../fs/poclb/poclb.a ../../fs/clib/clib.a\
../../fs/rtelb/rtelb.a -lm
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a -lm
#
OBJECTS = \
tacd.o tacd_srv.o parse_it.o
#
../bin/tacd: $(OBJECTS)
	$(CC)  -o ../bin/tacd $(OBJECTS) $(LIBES) $(GPIB_LIBS)
	strip ../bin/tacd
#
tacd:
	rm -f ../bin/tacd
	make
