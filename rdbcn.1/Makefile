#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS = rdbcn.o
#
../bin/rdbcn: $(OBJECTS)
	cc  -o ../bin/rdbcn $(OBJECTS) $(LIBES)
	strip ../bin/rdbcn
#
rdbcn:
	rm -f ../bin/rdbcn
	make
