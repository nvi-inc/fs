LIBES = ../../fs/poclb/poclb.a ../../fs/clib/clib.a ../../fs/rtelb/rtelb.a
#
../bin/pcald: pcald.o $(OBJECTS)
	cc  -o ../bin/pcald pcald.o $(OBJECTS) $(LIBES)
	strip ../bin/pcald

pcald:
	rm -f ../bin/pcald
	make
#
