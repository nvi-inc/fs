CFLAGS = 
LIBS = ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/rack : rack.o $(OBJECTS)
	cc -o ../bin/rack rack.o $(OBJECTS) $(LIBS)
	strip ../bin/lognm
