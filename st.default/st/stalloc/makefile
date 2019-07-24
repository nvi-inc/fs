CFLAGS = -g
LIBS = ../stlib/stlib.a -lrtx

../bin/stalloc : stalloc.o $(OBJECTS)
	cc -o ../bin/stalloc stalloc.o $(OBJECTS) $(LIBS)
