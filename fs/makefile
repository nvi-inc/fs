CFLAGS = -g
F77 = gf77
LIBS = ../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a\
-lrtx
OBJECTS = 

../bin/fs : fs.o $(OBJECTS)
	cc -o ../bin/fs fs.o $(OBJECTS) $(LIBS)
	../setb/setb ../bin/fs
#
fs:
	rm -f ../bin/fs
	make
