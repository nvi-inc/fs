CFLAGS = -g
F77 = gf77
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a\
-lrtx
OBJECTS = 

all: ../bin/oprin ../bin/extin

../bin/oprin: oprin.o $(OBJECTS)
	cc -o ../bin/oprin oprin.o $(OBJECTS) $(LIBS)
	../setb/setb ../bin/oprin

../bin/extin: ../bin/oprin
	ln -f ../bin/oprin ../bin/extin
