OBJECTS = onoff.o jr2as.o tpi_mark.o tpget_mark.o get_samples.o ini_accum.o\
inc_accum.o red_accum.o savoff.o antcn.o onsor.o scmds.o gooff.o local.o\
tzero.o matcn.o wcounts.o tpget_vlba.o agc.o
#
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/onoff: $(OBJECTS)
	cc  -o ../bin/onoff $(OBJECTS) $(LIBES) -lm
	strip ../bin/onoff
#
onoff:
	rm -f ../bin/onoff
	make
