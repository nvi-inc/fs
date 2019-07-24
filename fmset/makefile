OBJECTS = fmset.o asktime.o clear_scrn.o get4time.o getfmtime.o getvtime.o\
initvstr.o set4time.o setfmtime.o setvtime.o
#
CFLAGS = -g
LIBES	= ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/fmset: $(OBJECTS)
	cc -g -o ../bin/fmset $(OBJECTS) $(LIBES) -lm -lcurses -lrtx
	../setb/setb ../bin/fmset
#
fmset:
	rm -f ../bin/fmset
	make
