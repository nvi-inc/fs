CFLAGS = 
LIBS = ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/brk : brk.o $(OBJECTS)
	cc -o ../bin/brk brk.o $(OBJECTS) $(LIBS)
	strip ../bin/brk
