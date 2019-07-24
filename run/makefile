CFLAGS = -g
LIBS = ../clib/clib.a ../rtelb/rtelb.a -lrtx
OBJECTS = 

../bin/run : run.o $(OBJECTS)
	cc -o ../bin/run run.o $(OBJECTS) $(LIBS)
	../setb/setb ../bin/run
