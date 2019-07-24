CFLAGS = -g
F77 = gf77
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a\
-lrtx
OBJECTS = 

../bin/fsalloc : fsalloc.o $(OBJECTS)
	cc -o ../bin/fsalloc fsalloc.o $(OBJECTS) $(LIBS)
	../setb/setb ../bin/fsalloc
#
fsalloc:
	rm -f ../bin/fsalloc
	make
