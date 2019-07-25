CFLAGS = 
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = 

../bin/fsalloc : fsalloc.o $(OBJECTS)
	cc -o ../bin/fsalloc fsalloc.o $(OBJECTS) $(LIBS)
	strip ../bin/fsalloc
#
fsalloc:
	rm -f ../bin/fsalloc
	make
