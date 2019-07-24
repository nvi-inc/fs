#
CFLAGS= -g
LIBES = ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
OBJECTS = mcbcn.o
#
../bin/mcbcn: $(OBJECTS)
	cc -g -o ../bin/mcbcn $(OBJECTS) $(LIBES)
	../setb/setb ../bin/mcbcn
#
mcbcn:
	rm -f ../bin/mcbcn
	make
