CFLAGS = -g
LIBS = ../stlib/stlib.a
#
../bin/stalloc : stalloc.o $(OBJECTS)
	cc -o ../bin/stalloc stalloc.o $(OBJECTS) $(LIBS)
	strip ../bin/stalloc
