#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = mk5cn.o
#
../bin/mk5cn: $(OBJECTS)
	cc  -o ../bin/mk5cn $(OBJECTS) $(LIBES)
	strip ../bin/mk5cn
#
mk5cn:
	rm -f ../bin/mk5cn
	make
