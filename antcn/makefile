#
CFLAGS= 
LIBES = ../../fs/poclb/poclb.a ../../fs/clib/clib.a\
../../fs/rtelb/rtelb.a -lm
#
OBJECTS = antcn.o 
#
../bin/antcn: $(OBJECTS)
	cc  -o ../bin/antcn $(OBJECTS) $(LIBES)
	strip ../bin/antcn
#
antcn:
	rm -f ../bin/antcn
	make
