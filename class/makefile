LIBES = ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
../bin/class: class.o $(OBJECTS)
	cc -g -o ../bin/class class.o $(OBJECTS) $(LIBES)
	../setb/setb ../bin/class
#
