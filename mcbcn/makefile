#
CFLAGS= 
LIBES = ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = mcbcn.o
#
../bin/mcbcn: $(OBJECTS)
	cc  -o ../bin/mcbcn $(OBJECTS) $(LIBES)
	strip ../bin/mcbcn
#
mcbcn:
	rm -f ../bin/mcbcn
	make
