OBJECTS = fmset.o asktime.o get4time.o getfmtime.o getvtime.o\
initvstr.o set4time.o setfmtime.o setvtime.o gets2time.o sets2time.o asksure.o\
get5btime.o set5btime.o getfila10gtime.o setfila10gtime.o gfila10g_cfg.o\
ask_fila10g_cfg.o getRDBEtime.o setRDBEtime.o
#
CFLAGS =  -I/usr/include/ncurses
LIBES	= ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
ifdef FS_TINFO_LIB
LIBES := $(LIBES) -ltinfo
endif
#
../bin/fmset: $(OBJECTS)
	cc  -o ../bin/fmset $(OBJECTS) $(LIBES) -lm -lncurses
	strip ../bin/fmset
#
fmset:
	rm -f ../bin/fmset
	make
