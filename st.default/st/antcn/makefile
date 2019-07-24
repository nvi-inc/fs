#
CFLAGS= -g
LIBES = ../stlib/stlib.a ../../fs/poclb/poclb.a ../../fs/clib/clib.a\
../../fs/rtelb/rtelb.a -lrtx 
#
OBJECTS = antcn.o 
#
../bin/antcn: $(OBJECTS)
	cc -g -o ../bin/antcn $(OBJECTS) $(LIBES) -lm
	../../fs/setb/setb ../bin/antcn
#
antcn:
	rm -f ../bin/antcn
	make
