CFLAGS = 
LIBS =  ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = inject_snap.o

../bin/inject_snap : $(OBJECTS)
	cc -o ../bin/inject_snap $(OBJECTS) $(LIBS)
	strip ../bin/inject_snap
#
fs:
	rm -f ../bin/inject_snap
	make
