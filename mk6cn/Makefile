#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = mk6cn.o
#
../bin/mk6cn: $(OBJECTS)
	cc  -o ../bin/mk6cn $(OBJECTS) $(LIBES)
	strip ../bin/mk6cn
#
mk5cn:
	rm -f ../bin/mk6cn
	make
