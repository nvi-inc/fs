CFLAGS = 
LIBS =  ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = lgerr.o

../bin/lgerr : $(OBJECTS)
	cc -o ../bin/lgerr $(OBJECTS) $(LIBS)
	strip ../bin/lgerr
#
lgerr:
	rm -f ../bin/lgerr
	make
