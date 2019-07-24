OBJECTS = timeset.o
#
CFLAGS = -g
LIBES	= libcposix.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/timeset: $(OBJECTS)
	cc -g -o ../bin/timeset $(OBJECTS) $(LIBES) -lm -lcurses -lrtx
	../setb/setb ../bin/timeset
#
timeset:
	rm -f ../bin/timeset
	make
