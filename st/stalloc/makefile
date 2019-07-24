CFLAGS = -g
LIBS = ../../clib/clib.a ../stlib/stlib.a ../../rtelb/rtelb.a -lrtx

../bin/stalloc : stalloc.o $(OBJECTS)
	cc -o ../bin/stalloc stalloc.o $(OBJECTS) $(LIBS)
