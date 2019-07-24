CFLAGS = -g
LIBS = ../clib/clib.a ../rtelb/rtelb.a -lrtx
OBJECTS = 

../bin/brk : brk.o $(OBJECTS)
	cc -o ../bin/brk brk.o $(OBJECTS) $(LIBS)
	../setb/setb ../bin/brk
