CFLAGS = 
LIBS = ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/go : go.o $(OBJECTS)
	cc -o ../bin/go go.o $(OBJECTS) $(LIBS)
	strip ../bin/go
