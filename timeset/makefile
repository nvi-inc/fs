OBJECTS = timeset.o asktime.o clear_scrn.o get4time.o getfmtime.o getvtime.o\
initvstr.o set4time.o setfmtime.o setvtime.o
#
CFLAGS = -g
LIBES	= ../clib/clib.a ../rtelb/rtelb.a
#
../bin/timeset: $(OBJECTS)
	cc -g -o ../bin/timeset $(OBJECTS) $(LIBES) -lm -lcurses -lrtx
	../setb/setb ../bin/timeset
#
timeset:
	rm -f ../bin/timeset
	make
