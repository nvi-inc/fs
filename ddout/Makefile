LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS =\
recover_log.o
#
CFLAGS += -g

../bin/ddout: ddout.o $(OBJECTS)
	cc  -o ../bin/ddout ddout.o $(OBJECTS) $(LIBES)

ddout:
	rm -f ../bin/ddout
	make
#
