CFLAGS = 
LIBS = ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/run : run.o $(OBJECTS)
	cc -o ../bin/run run.o $(OBJECTS) $(LIBS)
	strip ../bin/run
