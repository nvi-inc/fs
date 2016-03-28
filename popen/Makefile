CFLAGS = 
LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/popen : popen.o $(OBJECTS)
	cc -o ../bin/popen popen.o $(OBJECTS) $(LIBS)
	strip ../bin/popen
