LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/pcald: pcald.o $(OBJECTS)
	cc  -o ../bin/pcald pcald.o $(OBJECTS) $(LIBES)
	strip ../bin/pcald

pcald:
	rm -f ../bin/pcald
	make
#
