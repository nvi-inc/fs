CFLAGS = 
LIBS = ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/lognm : lognm.o $(OBJECTS)
	cc -o ../bin/lognm lognm.o $(OBJECTS) $(LIBS)
	strip ../bin/lognm
