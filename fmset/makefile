OBJECTS = fmset.o asktime.o clear_scrn.o get4time.o getfmtime.o getvtime.o\
initvstr.o set4time.o setfmtime.o setvtime.o gets2time.o sets2time.o
#
CFLAGS =  -I/usr/include/ncurses
LIBES	= ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/fmset: $(OBJECTS)
	cc  -o ../bin/fmset $(OBJECTS) $(LIBES) -lm -lncurses
	strip ../bin/fmset
#
fmset:
	rm -f ../bin/fmset
	make
